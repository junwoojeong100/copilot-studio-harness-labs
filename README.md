# Copilot Studio Harness Lab

Microsoft Copilot Studio에서 같은 GitHub 이슈 분류기를
**Standard harness**와 **GitHub Copilot harness**로 각각 만들고,
GitHub Copilot CLI와 Playwright MCP로 검증하는 실습입니다.

## 빠른 시작

1. [`PORTAL_CREATION_GUIDE.md`의 사전 준비 체크리스트](PORTAL_CREATION_GUIDE.md#사전-준비-체크리스트)를 확인합니다.
2. Standard 또는 GitHub Copilot Lab을 선택해 flow부터 만듭니다.
3. Flow를 게시한 뒤 agent에 tool로 연결합니다.
4. [`VERIFICATION.md`](VERIFICATION.md)로 저장 정의와 실행 결과를 확인합니다.

| 목표 | 바로 시작 |
| --- | --- |
| Standard harness만 실습 | [`A-1. Agent flow 만들기`](PORTAL_CREATION_GUIDE.md#a-1-agent-flow-만들기) |
| GitHub Copilot harness만 실습 | [`B-1. Workflow 만들기`](PORTAL_CREATION_GUIDE.md#b-1-workflow-만들기) |
| 두 harness 비교 | A-1 → A-2 → B-1 → B-2 |
| Playwright MCP로 검증 | [`C-1. Playwright MCP로 Preview 테스트`](PORTAL_CREATION_GUIDE.md#c-1-playwright-mcp로-preview-테스트) |

처음 접하는 경우에는 다음 순서로 읽으세요.

```text
COPILOT_STUDIO_CONCEPTS.md
  → HARNESS_COMPARISON.md
  → PORTAL_CREATION_GUIDE.md
  → VERIFICATION.md
```

## 실습 결과

Lab A와 Lab B는 같은 입력과 분류 규칙을 사용하며 출력 계약도 같습니다.

| 계약 | 필드 |
| --- | --- |
| 입력 | Issue title, issue body |
| 출력 | `category`, `priority`, `summary`, `needsHumanReview` |

```text
Lab A — Standard harness
  Agent flow: Classify Issue - Standard
  Agent:      Simple Issue Triage Standard

Lab B — GitHub Copilot harness
  Workflow:   Classify Issue - GitHub Harness
  Agent:      Simple Issue Triage GitHub

Lab C — GitHub Copilot CLI + Playwright MCP
  Verify:     Lab A/B agent Preview and Activity trace
```

> Flow 또는 workflow를 먼저 게시해야 agent의 tool 목록에 나타납니다.
> Agent 이름은 30자를 넘기지 마세요.

## 문서 안내

| 문서 | 목적 |
| --- | --- |
| [`COPILOT_STUDIO_CONCEPTS.md`](COPILOT_STUDIO_CONCEPTS.md) | Agent, tool, knowledge, orchestration, 채널, 거버넌스 개념 |
| [`HARNESS_COMPARISON.md`](HARNESS_COMPARISON.md) | Harness 차이, 과금, 선택 기준 |
| [`PORTAL_CREATION_GUIDE.md`](PORTAL_CREATION_GUIDE.md) | 포털에서 그대로 따라 하는 실습 절차 |
| [`VERIFICATION.md`](VERIFICATION.md) | 읽기 전용 API 검증 명령 |
| [`ROLES_AND_PERMISSIONS.md`](ROLES_AND_PERMISSIONS.md) | 역할, 라이선스, 작업별 권한, DLP 해제 |
| [`ACCOUNT_PERMISSION_INVENTORY.md`](ACCOUNT_PERMISSION_INVENTORY.md) | 특정 계정의 실제 리소스, 실행 기록, 남은 작업 |

## 문제가 생겼을 때

| 상황 | 먼저 볼 문서 |
| --- | --- |
| Tool 목록에 flow가 없음, 출력이 비어 있음 | [`PORTAL_CREATION_GUIDE.md#트러블슈팅`](PORTAL_CREATION_GUIDE.md#트러블슈팅) |
| `DlpViolationError / BlockedConnector` | [`ROLES_AND_PERMISSIONS.md` 6장](ROLES_AND_PERMISSIONS.md#6-dlp-심화-차단된-connector-해제) |
| 화면과 저장 결과가 다름 | [`VERIFICATION.md`](VERIFICATION.md) |
| 현재 테넌트에 무엇이 만들어졌는지 확인 | [`ACCOUNT_PERMISSION_INVENTORY.md`](ACCOUNT_PERMISSION_INVENTORY.md) |

## 범위

- 웹 포털 저작 경로만 다룹니다.
- 코드, CLI, solution package를 이용한 생성은 포함하지 않습니다.
- Standard와 GitHub Copilot harness를 실습합니다.
- Copilot chat harness는 개념과 비교 문서에서만 다룹니다.
