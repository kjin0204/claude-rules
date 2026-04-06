# Git Rules

## 커밋 메시지

### 형식

```
[type] 한글로 요약한 50자 이하 제목

body: 이번 커밋에 대한 자세한 사항 (변경 이유, 내용 등)

footer: 관련 이슈 번호 등 (필요한 경우에만)
```

### 예시

```
[feat] 프로필 페이지 연락처 섹션 추가

연락처 정보를 표시하는 섹션을 추가함.
이메일, GitHub 링크 포함.

Closes #12
```

### type 목록

- `feat` — 새 기능
- `fix` — 버그 수정
- `style` — 스타일/UI 변경 (기능 무관)
- `refactor` — 리팩터링
- `docs` — 문서 변경
- `chore` — 빌드/설정 변경

## 브랜치 전략 (Git Flow)

### 브랜치 구조

| 브랜치 | 역할 |
|---|---|
| `main` | 배포 전용. 머지 시 반드시 tag 부착 |
| `develop` | 개발 통합 브랜치. 모든 기능은 여기서 합쳐짐 |
| `feat/<name>` | 기능 개발. `develop`에서 분기 → `develop`으로 머지 |
| `fix/<name>` | 버그 수정. `develop`에서 분기 → `develop`으로 머지 |
| `release/<version>` | 배포 준비. `develop`에서 분기 → `main` + `develop`으로 머지 |
| `hotfix/<name>` | 긴급 수정. `main`에서 분기 → `main` + `develop`으로 머지 |

### 배포 (main 머지) 규칙

- `main`에는 직접 커밋 금지 — `release` 또는 `hotfix` 브랜치를 통해서만 머지
- **`main`에 머지할 때는 반드시 tag를 달아야 함**
- tag 형식: `v<major>.<minor>.<patch>` (e.g. `v1.0.0`, `v1.2.3`)
- **`main` 머지 전에 tag 명칭을 반드시 사용자에게 확인할 것**

### 흐름 요약

```
feat/* ─┐
fix/*  ─┤─→ develop → release/* → main (tag)
        │                    ↘ develop
hotfix/* ──────────────────→ main (tag)
                         ↘ develop
```

## Push 정책

- `main`에 force push 금지
- **push 요청 시 Claude가 반드시 아래 절차를 수행한 후 사용자 확인을 받고 push한다**

### Push 전 필수 절차

push 요청을 받으면 즉시 push하지 않고, 다음 순서로 진행한다:

1. **민감 정보 검토** — 아래 항목을 스캔하여 이상 없는지 확인
   - API 키, 토큰, 비밀번호 패턴 (`sk-`, `Bearer `, `password`, `secret` 등)
   - 절대 경로 (`C:/Users/...`, `/home/...`, `/Users/...`)
   - `.env`, `credentials`, `secret` 등 민감 파일명
   - gitignore 대상 파일이 스테이징에 포함되어 있지는 않은지

2. **변경 사항 리포트** — 아래 형식으로 사용자에게 보고

   ```
   === Push 전 검토 리포트 ===

   브랜치: feat/xxx → origin/feat/xxx

   [변경 파일]
   - M  src/components/Header.tsx   (수정)
   - A  src/utils/helpers.ts        (추가)
   - D  src/old/legacy.ts           (삭제)

   [민감 정보 검토]
   - 이상 없음 / 또는 발견된 항목 명시

   push를 진행할까요?
   ```

3. **사용자 확인 후 push** — 사용자가 재확인하면 그때 push 실행

## 커밋 분리 원칙

- 커밋 요청 시 변경 사항이 여러 관심사(기능, 버그, 스타일 등)를 포함하면 논리적 단위로 분리하여 커밋할 것을 제안한다
- 제안 시 분리 기준과 순서를 함께 제시한다
- 사용자가 분리를 원하지 않으면 하나로 커밋한다

### 분리 기준 예시

| 상황 | 분리 방식 |
|---|---|
| 기능 추가 + 버그 수정이 섞임 | `[feat]` 커밋 / `[fix]` 커밋 분리 |
| 여러 독립 기능이 한 번에 변경됨 | 기능별로 각각 `[feat]` 커밋 |
| 리팩터링 + 기능 변경이 섞임 | `[refactor]` 먼저 / `[feat]` 나중 |
| 스타일 변경 + 로직 변경이 섞임 | `[style]` 커밋 / `[feat]` 커밋 분리 |

## 일반 원칙

- `.gitignore`에 없는 민감한 파일(`.env` 등)은 절대 커밋하지 않음
- `git add .` 대신 파일을 명시적으로 스테이징
- 커밋 단위는 하나의 논리적 변경으로 유지
