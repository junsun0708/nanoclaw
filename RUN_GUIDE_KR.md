# Claude 및 NanoClaw 실행 방법 안내

## 1. Claude (Claude Code) 실행
Claude Code는 Anthropic에서 제공하는 CLI 도구입니다.

- **명령어**:
  ```bash
  npx claude
  ```
  (또는 전역 설치되어 있다면 `claude` 입력)

- **초기 설정**: `claude` 실행 후 프롬프트에서 아래 명령어를 입력하여 설치 및 설정을 진행하세요.
  ```
  /setup
  ```

---

## 2. NanoClaw 실행
NanoClaw는 Node.js 기반의 어시스턴트 프로세스입니다.

### 개발 모드 (실시간 반영)
코드를 수정하면서 바로 확인하고 싶을 때 사용합니다.
```bash
npm run dev
```

### 정식 실행 (Background)
시스템 서비스처럼 백그라운드에서 계속 실행하고 싶을 때 사용합니다.

1.  **빌드**: (최초 1회 또는 코드 수정 후)
    ```bash
    npm run build
    ```
2.  **실행**:
    ```bash
    ./start-nanoclaw.sh
    ```
3.  **로그 확인**:
    ```bash
    tail -f logs/nanoclaw.log
    ```

---

## 3. 주요 파일 및 디렉토리
- `src/index.ts`: 메인 오케스트레이터 코드
- `logs/`: 로그 파일이 저장되는 곳
- `groups/`: 그룹별 설정 및 데이터가 나뉘어 저장되는 곳

현재 폴더(`/PROJECT/0325120037_A/jyh/nanoclaw`)에서 위 명령어들을 실행하시면 됩니다. 추가로 궁금한 점이 있으면 말씀해 주세요!
