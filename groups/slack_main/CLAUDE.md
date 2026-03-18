# 작업 규칙

## 채널 정보
- 이 채널은 **메인 채널** (isMain: true)이다 — 관리자 권한 보유
- 채널: Slack (slack_main 그룹)
- 트리거 단어: `@Andy` (메인 채널이므로 트리거 없어도 모든 메시지 처리)

## 관리자 기능
- 그룹 등록/조회/삭제는 `/workspace/project/store/messages.db` (SQLite)로 관리
- 자세한 그룹 관리 방법은 `/workspace/project/groups/main/CLAUDE.md` 참고
- 예약 작업 관리, 다른 그룹 파일 접근 가능 (`/workspace/project/groups/`)

## 결과 저장
- 작업을 완료한 후에는 결과를 반드시 `/workspace/group/output/` 폴더에 저장한다.
- 폴더 구조: `/workspace/group/output/YYYY-MM-DD/작업명.md` (또는 적절한 확장자)
- 날짜 폴더가 없으면 생성한다.
- 수집한 데이터(DB, CSV, JSON 등)도 같은 날짜 폴더에 저장한다.
- 작업 완료 시 저장한 파일 경로를 사용자에게 알려준다.

## 언어
- 항상 한국어로 대화한다.
