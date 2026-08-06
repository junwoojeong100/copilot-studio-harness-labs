# Copilot Studio Harness Lab

Microsoft Copilot Studio의 개념·기능을 정리하고,
포털에서 **Standard harness**와 **GitHub Copilot harness**의 agent·workflow를
직접 만들어 비교하는 실습 저장소입니다.

## 문서 안내

### 개념

| 문서 | 내용 |
| --- | --- |
| [`COPILOT_STUDIO_CONCEPTS.md`](COPILOT_STUDIO_CONCEPTS.md) | Copilot Studio 전반 개념과 기능. agent 구성 요소, orchestration, tool, knowledge, multi-agent, 채널, 운영, 거버넌스, ALM, 용어집 |
| [`HARNESS_COMPARISON.md`](HARNESS_COMPARISON.md) | 세 가지 harness(GitHub Copilot / Standard / Copilot chat)의 차이, 산출물 매핑, 과금 모델, 선택 기준 |
| [`ROLES_AND_PERMISSIONS.md`](ROLES_AND_PERMISSIONS.md) | 개발·운영·관리를 위한 플랫폼별 역할과 권한. 플랫폼 지도, 역할 카탈로그, 작업별 권한 매트릭스, 페르소나 번들, DLP 심화 |

### 실습

| 문서 | 내용 |
| --- | --- |
| [`PORTAL_CREATION_GUIDE.md`](PORTAL_CREATION_GUIDE.md) | 포털에서 agent와 workflow를 생성하고 연결하는 실습 절차 |
| [`VERIFICATION.md`](VERIFICATION.md) | 읽기 전용 API로 실습 결과를 결정적으로 검증하는 방법 |

### 실행 기록

| 문서 | 내용 |
| --- | --- |
| [`ACCOUNT_PERMISSION_INVENTORY.md`](ACCOUNT_PERMISSION_INVENTORY.md) | 대상 계정으로 확인한 포털 기능, 환경 역할, 라이선스, capacity, 실제 생성된 리소스 실측값 |

## 읽는 순서

```text
처음이라면
  COPILOT_STUDIO_CONCEPTS.md  →  HARNESS_COMPARISON.md  →  PORTAL_CREATION_GUIDE.md

실습부터 하려면
  PORTAL_CREATION_GUIDE.md 의 "사전 준비 체크리스트"  →  실습
  만든 결과를 확인할 때는  VERIFICATION.md

권한 문제로 막혔다면
  ROLES_AND_PERMISSIONS.md 의 "작업 → 필요 권한 매트릭스" 와 "DLP 심화"

이 저장소에서 실제로 무엇이 만들어졌는지 궁금하다면
  아래 "현재 검증 상태"  →  ACCOUNT_PERMISSION_INVENTORY.md
```

> **문서 성격 구분**
> `PORTAL_CREATION_GUIDE.md`는 **따라 만드는 절차**입니다.
> 절차 안에 "현재 테넌트에 저장된 값" 블록이 섞여 있는데, 이는 **참고 기록**이며
> 따라 만들 대상이 아닙니다. 각 블록에 명시해 두었습니다.

## 실습 시나리오

동일한 **GitHub 이슈 분류** 시나리오를 두 harness로 각각 구현합니다.

```text
Lab A (Standard harness)
  A-1. Agent flow  : Classify Issue - Standard
  A-2. Agent       : Simple Issue Triage Standard

Lab B (GitHub Copilot harness)
  B-1. Workflow    : Classify Issue - GitHub Harness
  B-2. Agent       : Simple Issue Triage GitHub
```

> **순서 주의**: flow/workflow를 먼저 만들어 **게시**한 뒤 agent에 tool로 연결합니다.
> 게시하지 않은 flow는 tool 목록에 나타나지 않습니다.

> **이름 주의**: agent 이름은 **30자를 넘기면 경고 없이 잘립니다.**
> `Simple Issue Triage GitHub`는 26자로 안전합니다.

## 현재 검증 상태

기준: 대상 환경 `Junwoo Jeong` (`e477cbf2-150c-eee7-a852-b29ac07f541d`)

✅ = 2026-08-06 **포털 또는 읽기 전용 API로 재확인** / 📄 = 기록값(재현 안 함)

| 리소스 | 상태 | 검증 |
| --- | --- | --- |
| `Classify Issue - Standard` (workflow) | Published ✅ | Succeeded 3건 ✅ (123 / 120 / 141 ms, Flow API) · 출력 1개 ✅ (정의 원본) |
| `Classify Issue - GitHub Harness` (workflow) | Published ✅ | Succeeded ✅ (149 ms, Flow API) · 출력 4개 ✅ (정의 원본, **전부 고정 상수**) · checker 0/0 📄 |
| `Simple Issue Triage GitHub Har` (agent) | Published ✅ | `publishedon` = `2026-08-05T11:54:16Z` ✅ |
| `Simple Issue Triage Standard` (agent) | Draft ✅ | `publishedon` = `null` ✅ · DLP `PvaSkills` = Blocked ✅ (BAP 정책 API) |

**4종 생성 완료, 3종 게시 완료, 1종 Draft**입니다.

> **API 실측에서 드러난 사실**
> 1. `Respond to the agent 2`의 출력은 **1개**입니다.
>    저장된 **키는 `text`**, agent에 보이는 **이름(title)은 `category`** 로 서로 다릅니다.
> 2. Lab A의 `Category` 노드에는 이미 **5분류 규칙이 완성**돼 있습니다.
>    스모크 테스트가 아니라 동작하는 분류기입니다.
> 3. Lab B의 첫 Compose는 **`@` 접두사가 빠져** 식이 아니라 문자열로 저장돼 있습니다.
>    결과적으로 분류 조건이 항상 거짓이며, Respond가 값을 상수로 반환해 가려져 있습니다.
> 4. Agent 이름은 **30자에서 잘립니다.** 포털의 `…`는 UI 말줄임이 아니라 실제 저장값입니다.
> 5. Dataverse에는 `Classify Issue*` workflow가 **3개** 있습니다(포털 목록은 2개).
> 6. 두 flow 모두 Dataverse `category: 5`(Modern Flow)입니다.
>    포털의 modern/classic 구분은 **UI 표시 수준**입니다.
>
> 검증 방법은 [`VERIFICATION.md`](VERIFICATION.md)에, 항목별 대조표는
> 실습 가이드의 "실측으로 정정된 항목"에 있습니다.

### 남은 작업

**이 표가 남은 작업의 유일한 기준입니다.** 다른 문서는 여기를 참조합니다.

| 항목 | 상태 | 해결 방법 |
| --- | --- | --- |
| Lab B 첫 Compose의 `@` 누락 수정 | 미해결 | 디자이너에서 식 앞에 `@` 추가 후 재게시 |
| Lab B Respond를 앞 노드 결과에 연결 | 미해결 | 고정 상수 4개를 `@{outputs(...)}`로 교체 (가이드 B-1의 "만들 값") |
| `Respond to the agent 2`에 출력 3개 추가 | 미해결 | 실습 가이드 A-1의 출력 계약 표 참고 |
| Lab A `Priority` 판정 노드 추가 | 미해결 | 가이드 A-1의 `Priority` 입력식 사용 |
| Lab B Flow checker 0/0 재확인 | 재현 불가 | API 없음. 정의 원본 점검으로 대체 |
| agent → flow end-to-end 호출 | 미확인 | DLP 예외 승인 후 Standard agent Test 패널 (Preview는 Credits 소모) |
| `PvaSkills` 테넌트 DLP 예외 승인 | 대기 | `ROLES_AND_PERMISSIONS.md` §6의 요청 템플릿 사용 |
| `Classify Issue - GitHub Harness (API Reference)` 정리 | 미결정 | Dataverse에만 남은 잔여 workflow |

## 범위

- 웹 포털 저작 경로만 다룹니다.
- 코드, CLI, solution package를 이용한 생성 경로는 포함하지 않습니다.
- harness는 자동화 산출물을 만들 수 있는 GitHub Copilot / Standard 두 가지를 실습합니다.
  Copilot chat harness는 개념 문서에서만 다룹니다.
