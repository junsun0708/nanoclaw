#!/bin/bash
# export-for-migration.sh — 새 서버 이전용 파일 패키징
# 사용법: bash export-for-migration.sh
# 결과: nanoclaw-migration.tar.gz 생성

set -euo pipefail

cd "$(dirname "$0")"
OUTPUT="nanoclaw-migration.tar.gz"

echo "=============================="
echo " NanoClaw 이전 패키지 생성"
echo "=============================="

tar -czf "$OUTPUT" \
  .env \
  store/messages.db \
  groups/slack_main/CLAUDE.md \
  2>/dev/null || true

# 실제로 존재하는 파일만 포함
FILES=()
[ -f ".env" ]                        && FILES+=(".env")
[ -f "store/messages.db" ]           && FILES+=("store/messages.db")
[ -f "groups/slack_main/CLAUDE.md" ] && FILES+=("groups/slack_main/CLAUDE.md")

if [ ${#FILES[@]} -eq 0 ]; then
  echo "[오류] 이전할 파일이 없습니다."
  exit 1
fi

tar -czf "$OUTPUT" "${FILES[@]}"

echo ""
echo "[✓] 생성 완료: $OUTPUT"
echo ""
echo "포함된 파일:"
for f in "${FILES[@]}"; do
  echo "  - $f"
done

echo ""
echo "=============================="
echo " 새 서버에서 복원 방법"
echo "=============================="
echo ""
echo "1. 새 서버에 git clone"
echo "   git clone <repo_url> nanoclaw && cd nanoclaw"
echo ""
echo "2. 이 파일을 새 서버로 복사"
echo "   scp $OUTPUT 새서버:~/nanoclaw/"
echo ""
echo "3. 새 서버에서 압축 해제"
echo "   cd ~/nanoclaw && tar -xzf $OUTPUT"
echo ""
echo "4. 설치 스크립트 실행"
echo "   bash setup-new-server.sh"
