#!/bin/bash
# setup-new-server.sh — NanoClaw 새 서버 설치 스크립트
# 사용법: bash setup-new-server.sh

set -euo pipefail

REPO_URL="$(git remote get-url origin 2>/dev/null || echo '')"
INSTALL_DIR="${1:-/PROJECT/0325120037_A/jyh/nanoclaw}"

echo "=============================="
echo " NanoClaw 새 서버 설치 시작"
echo "=============================="

# 1. Node.js 확인
if ! command -v node &>/dev/null; then
  echo "[오류] Node.js가 설치되어 있지 않습니다."
  echo "  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -"
  echo "  sudo apt-get install -y nodejs"
  exit 1
fi
echo "[✓] Node.js $(node -v)"

# 2. Docker 확인
if ! command -v docker &>/dev/null; then
  echo "[오류] Docker가 설치되어 있지 않습니다."
  echo "  https://docs.docker.com/engine/install/"
  exit 1
fi
echo "[✓] Docker $(docker --version | cut -d' ' -f3 | tr -d ',')"

# 3. .env 확인
if [ ! -f "$INSTALL_DIR/.env" ]; then
  echo ""
  echo "[!] .env 파일이 없습니다. 아래 내용으로 생성해주세요:"
  echo ""
  echo "  CLAUDE_CODE_OAUTH_TOKEN=sk-ant-oat01-..."
  echo "  SLACK_BOT_TOKEN=xoxb-..."
  echo "  SLACK_APP_TOKEN=xapp-..."
  echo ""
  echo "  기존 서버에서 복사:"
  echo "  scp 기존서버:/PROJECT/0325120037_A/jyh/nanoclaw/.env $INSTALL_DIR/.env"
  echo ""
  read -p ".env 파일 생성 후 Enter를 눌러 계속하세요..."
fi
echo "[✓] .env 확인됨"

# 4. npm 의존성 설치
echo ""
echo "[→] npm 패키지 설치 중..."
cd "$INSTALL_DIR"
npm install

# 5. TypeScript 빌드
echo ""
echo "[→] 빌드 중..."
npm run build
echo "[✓] 빌드 완료"

# 6. Docker 컨테이너 이미지 빌드
echo ""
echo "[→] 에이전트 컨테이너 이미지 빌드 중... (수분 소요)"
./container/build.sh
echo "[✓] 컨테이너 이미지 빌드 완료"

# 7. DB 복원 안내
echo ""
echo "=============================="
echo " DB 복원 (슬랙 그룹 등록 정보)"
echo "=============================="
if [ ! -f "$INSTALL_DIR/store/messages.db" ]; then
  echo "[!] store/messages.db 가 없습니다."
  echo "  기존 서버에서 복사:"
  echo "  mkdir -p $INSTALL_DIR/store"
  echo "  scp 기존서버:/PROJECT/0325120037_A/jyh/nanoclaw/store/messages.db $INSTALL_DIR/store/"
  echo ""
  echo "  DB가 없으면 슬랙 채널을 다시 등록해야 합니다."
else
  echo "[✓] DB 확인됨"
fi

# 8. 서비스 시작
echo ""
echo "=============================="
echo " 서비스 시작"
echo "=============================="
bash "$INSTALL_DIR/start-nanoclaw.sh"

echo ""
echo "=============================="
echo " 설치 완료!"
echo "=============================="
echo ""
echo "로그 확인:"
echo "  tail -f $INSTALL_DIR/logs/nanoclaw.log"
echo ""
echo "슬랙에서 @Andy 멘션으로 테스트하세요."
