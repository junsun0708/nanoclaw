# NanoClaw 타 서버 이전 및 실행 가이드

> 현재 기준: 2026-03-06
> 채널: Slack (slack_main 그룹)
> 실행 방식: nohup 백그라운드 (systemd 없음)

---

## 사전 요건 (새 서버)

| 항목 | 버전 / 비고 |
|------|------------|
| Node.js | 20.x 이상 |
| Docker | 설치 및 실행 중 |
| Git | 프로젝트 clone 용 |

```bash
# Node.js 20 설치 (Ubuntu/Debian)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt-get install -y nodejs

# Docker 설치
# https://docs.docker.com/engine/install/ubuntu/
```

---

## 1단계: 기존 서버에서 이전 파일 패키징

기존 서버의 프로젝트 루트에서 실행:

```bash
cd /PROJECT/0325120037_A/jyh/nanoclaw
bash export-for-migration.sh
```

`nanoclaw-migration.tar.gz` 파일이 생성됩니다. 포함 내용:
- `.env` — API 토큰 (Claude, Slack)
- `store/messages.db` — 채팅 기록 및 그룹 등록 정보
- `groups/slack_main/CLAUDE.md` — slack_main 그룹 메모리

---

## 2단계: 새 서버에 코드 받기

```bash
git clone <repo_url> /PROJECT/0325120037_A/jyh/nanoclaw
cd /PROJECT/0325120037_A/jyh/nanoclaw
```

> 저장소 URL 확인: `git remote get-url origin` (기존 서버에서 실행)

---

## 3단계: 이전 파일 복사 및 복원

기존 서버에서 새 서버로 전송:

```bash
scp nanoclaw-migration.tar.gz 새서버주소:~/
```

새 서버에서 압축 해제:

```bash
cd /PROJECT/0325120037_A/jyh/nanoclaw
tar -xzf ~/nanoclaw-migration.tar.gz
```

복원 확인:

```bash
ls -la .env store/messages.db groups/slack_main/CLAUDE.md
```

---

## 4단계: 의존성 설치 및 빌드

```bash
cd /PROJECT/0325120037_A/jyh/nanoclaw
npm install
npm run build
```

빌드 결과는 `dist/` 디렉토리에 생성됩니다.

---

## 5단계: 에이전트 컨테이너 이미지 빌드

**중요: 새 서버에서 반드시 새로 빌드해야 합니다. 이미지는 이전 파일에 포함되지 않습니다.**

```bash
./container/build.sh
```

수 분 소요됩니다. 완료 후 확인:

```bash
docker images | grep nanoclaw-agent
```

---

## 6단계: .env 확인

```bash
cat .env
```

다음 항목이 모두 있어야 합니다:

```env
CLAUDE_CODE_OAUTH_TOKEN=sk-ant-oat01-...
SLACK_BOT_TOKEN=xoxb-...
SLACK_APP_TOKEN=xapp-...
```

토큰이 바뀐 경우 직접 수정:

```bash
nano .env
```

---

## 7단계: NanoClaw 시작

```bash
bash start-nanoclaw.sh
```

프로세스 시작 확인:

```bash
cat nanoclaw.pid          # PID 확인
tail -f logs/nanoclaw.log # 실시간 로그
```

정상 시작 시 로그에 아래와 같은 메시지 출력:
```
NanoClaw running (trigger: @Andy)
```

---

## 8단계: 동작 확인

Slack에서 `slack_main` 채널에 메시지 전송:

```
@Andy 테스트
```

응답이 오면 이전 완료.

---

## 서비스 관리 명령어

```bash
# 시작
bash start-nanoclaw.sh

# 중지
kill $(cat nanoclaw.pid)

# 재시작
bash start-nanoclaw.sh  # 기존 PID 자동 종료 후 재시작

# 실시간 로그
tail -f logs/nanoclaw.log

# 에러 로그
tail -f logs/nanoclaw.error.log

# 프롬프트 로그 (날짜별)
ls logs/prompts/
tail -f logs/prompts/$(date +%Y-%m-%d).md
```

---

## 문제 해결

### NanoClaw가 시작되지 않는 경우

```bash
# 에러 로그 확인
tail -50 logs/nanoclaw.error.log

# 빌드 파일 확인
ls dist/index.js

# Node 버전 확인
node -v  # 20.x 이상이어야 함
```

### Slack 연결이 안 되는 경우

```bash
# 로그에서 Slack 관련 에러 확인
grep -i slack logs/nanoclaw.log | tail -20

# .env 토큰 확인
grep SLACK .env
```

### 에이전트(컨테이너)가 응답하지 않는 경우

```bash
# 실행 중인 컨테이너 확인
docker ps | grep nanoclaw

# 최근 컨테이너 로그 확인
ls -lt groups/slack_main/logs/ | head -5
tail -100 groups/slack_main/logs/<최근파일>.log

# 컨테이너 이미지 존재 확인
docker images nanoclaw-agent
```

### DB 없이 시작한 경우 (그룹 재등록)

`store/messages.db`가 없으면 Slack 그룹 등록 정보가 초기화됩니다.
이 경우 Claude Code에서 `/setup` 또는 `/add-slack` 스킬을 다시 실행해 그룹을 재등록하세요.

---

## 주요 파일 경로 요약

| 경로 | 내용 |
|------|------|
| `.env` | API 토큰 |
| `store/messages.db` | SQLite DB (메시지, 그룹 등록, 세션) |
| `groups/slack_main/CLAUDE.md` | slack_main 그룹 메모리 |
| `groups/slack_main/logs/` | 컨테이너 실행 로그 |
| `logs/nanoclaw.log` | 서비스 메인 로그 |
| `logs/nanoclaw.error.log` | 서비스 에러 로그 |
| `logs/prompts/` | 날짜별 프롬프트/응답 로그 |
| `dist/index.js` | 빌드된 실행 파일 |
| `nanoclaw.pid` | 실행 중인 PID |
| `container/` | 에이전트 Docker 설정 |
| `start-nanoclaw.sh` | 서비스 시작 스크립트 |
