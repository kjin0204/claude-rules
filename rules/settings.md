# Settings 관리 규칙

## settings.json vs settings.local.json

Claude Code는 두 파일을 자동으로 머지하며, `settings.local.json`이 더 높은 우선순위를 가진다.

| 파일 | git 추적 | 용도 |
|---|---|---|
| `settings.json` | O (공유) | 모든 PC에 공통 적용할 설정 |
| `settings.local.json` | X (gitignore) | 이 PC에만 적용할 설정 |

## 어디에 넣을지 판단 기준

**`settings.json` (공유)에 넣을 것:**
- `model` — 기본 모델 설정
- `language` — 응답 언어
- `effortLevel` — 기본 작업 강도
- `autoUpdatesChannel` — 업데이트 채널
- `permissions` — 공통 권한 정책

**`settings.local.json` (로컬)에 넣을 것:**
- `statusLine.command` — 절대 경로 포함 (PC마다 다름)
- 특정 PC의 디렉토리 경로를 참조하는 모든 설정
- API 키, 토큰 등 민감 정보
- 개인 테스트용 임시 설정 오버라이드

## Claude가 설정을 수정할 때 규칙

설정 변경 요청 시, 아래 순서로 판단하여 파일을 선택한다:

1. **절대 경로가 포함되는가?** → `settings.local.json`
2. **PC마다 달라질 수 있는가?** → `settings.local.json`
3. **민감 정보(키, 토큰, 비밀번호)인가?** → `settings.local.json`
4. **위 3가지 모두 아니면** → `settings.json`
