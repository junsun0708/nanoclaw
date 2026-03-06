/**
 * OAuth token auto-refresher for Claude Code credentials.
 * Reads ~/.claude/.credentials.json, refreshes the token when it's about
 * to expire, and updates .env with the new CLAUDE_CODE_OAUTH_TOKEN.
 */
import fs from 'fs';
import os from 'os';
import path from 'path';

import { logger } from './logger.js';

const CREDENTIALS_PATH = path.join(os.homedir(), '.claude', '.credentials.json');
const REFRESH_URL = 'https://platform.claude.com/v1/oauth/token';
const CLIENT_ID = '9d1c250a-e61b-44d9-88ed-5944d1962f5e';

/** Refresh when less than 30 minutes remain */
const REFRESH_THRESHOLD_MS = 30 * 60 * 1000;

interface ClaudeCredentials {
  claudeAiOauth: {
    accessToken: string;
    refreshToken: string;
    expiresAt: number;
    scopes?: string[];
    subscriptionType?: string;
    rateLimitTier?: string;
  };
}

function readCredentials(): ClaudeCredentials | null {
  try {
    return JSON.parse(fs.readFileSync(CREDENTIALS_PATH, 'utf-8'));
  } catch {
    return null;
  }
}

function updateEnvFile(token: string): void {
  const envPath = path.join(process.cwd(), '.env');
  let content = '';
  try {
    content = fs.readFileSync(envPath, 'utf-8');
  } catch {
    // .env doesn't exist
  }
  if (content.includes('CLAUDE_CODE_OAUTH_TOKEN=')) {
    content = content.replace(
      /^CLAUDE_CODE_OAUTH_TOKEN=.*/m,
      `CLAUDE_CODE_OAUTH_TOKEN=${token}`,
    );
  } else {
    content += `\nCLAUDE_CODE_OAUTH_TOKEN=${token}\n`;
  }
  fs.writeFileSync(envPath, content, 'utf-8');
}

export async function refreshTokenIfNeeded(): Promise<void> {
  const credentials = readCredentials();
  if (!credentials?.claudeAiOauth) return;

  const { accessToken, refreshToken, expiresAt } = credentials.claudeAiOauth;
  const timeLeft = expiresAt - Date.now();

  // Always sync current credentials to .env (covers manual re-login cases)
  updateEnvFile(accessToken);

  if (timeLeft > REFRESH_THRESHOLD_MS) {
    logger.debug(
      { expiresInMin: Math.round(timeLeft / 60000) },
      'OAuth token synced to .env, still fresh — skipping API refresh',
    );
    return;
  }

  logger.info(
    { expiresInMin: Math.round(timeLeft / 60000) },
    'OAuth token expiring soon, refreshing...',
  );

  try {
    const response = await fetch(REFRESH_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        grant_type: 'refresh_token',
        refresh_token: refreshToken,
        client_id: CLIENT_ID,
      }),
    });

    if (!response.ok) {
      const text = await response.text();
      logger.error(
        { status: response.status, body: text },
        'OAuth token refresh failed',
      );
      return;
    }

    const data = (await response.json()) as Record<string, unknown>;
    const newAccessToken =
      (data.access_token as string) || (data.accessToken as string);
    const newRefreshToken =
      (data.refresh_token as string) || (data.refreshToken as string);
    const expiresIn = data.expires_in as number | undefined;

    if (!newAccessToken) {
      logger.error({ data }, 'No access_token in refresh response');
      return;
    }

    // Update credentials file
    credentials.claudeAiOauth.accessToken = newAccessToken;
    if (newRefreshToken) credentials.claudeAiOauth.refreshToken = newRefreshToken;
    if (expiresIn) {
      credentials.claudeAiOauth.expiresAt = Date.now() + expiresIn * 1000;
    }
    fs.writeFileSync(CREDENTIALS_PATH, JSON.stringify(credentials, null, 2) + '\n');

    // Update .env so the next container spawn picks up the fresh token
    updateEnvFile(newAccessToken);

    logger.info('OAuth token refreshed successfully');
  } catch (err) {
    logger.error({ err }, 'Failed to refresh OAuth token');
  }
}

export function startTokenRefresher(): void {
  // Run immediately at startup
  refreshTokenIfNeeded().catch((err) =>
    logger.error({ err }, 'Token refresh error on startup'),
  );

  // Then check every 10 minutes
  setInterval(
    () =>
      refreshTokenIfNeeded().catch((err) =>
        logger.error({ err }, 'Token refresh error'),
      ),
    10 * 60 * 1000,
  );
}
