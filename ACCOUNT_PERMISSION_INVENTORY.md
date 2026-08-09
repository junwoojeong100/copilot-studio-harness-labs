# `junwoojeong@microsoft.com` 권한 및 포털 기능 확인

최초 확인: 2026-08-05 · 리소스 실측 재확인: 2026-08-06

이 문서는 **실행 기록**입니다. 대상 계정으로 무엇이 가능한지, 실제로 무엇을
만들었는지를 남깁니다. 실습 절차는 [`PORTAL_CREATION_GUIDE.md`](PORTAL_CREATION_GUIDE.md),
현재 리소스 상태와 남은 작업은 이 문서가 기준입니다.

> **증거 표기**
> ✅ = 포털 또는 읽기 전용 API로 재확인
> 📄 = 최초 세션 기록값. 재현하지 못함

## 결론

**현재 계정으로 웹 Copilot Studio 포털에서 다음 네 가지를 모두 생성할 수 있습니다.**

| Harness | 구성 요소 | 웹 포털 확인 결과 |
| --- | --- | --- |
| Standard harness | Agent | 생성 메뉴 활성화 |
| Standard harness | Agent flow | `New agent flow` 메뉴 활성화 |
| GitHub Copilot harness | Agent | 생성 가능, 기존 agent가 Published 상태 |
| GitHub Copilot harness | Workflow | `New workflow` 메뉴 활성화 |

즉, 현재 계정으로 웹 포털 authoring이 가능합니다.

## 직접 확인한 증거

대상 환경:

```text
Name: Junwoo Jeong
Environment ID: e477cbf2-150c-eee7-a852-b29ac07f541d
Type: Developer
```

### GitHub Copilot harness agent

새 경험의 **Agents** 페이지에서 확인:

- Agent: `Simple Issue Triage GitHub Har` (입력값 34자 → **30자로 잘려 저장**)
- Bot ID: `4236d9a0-9d6e-42b3-9377-a65e1c188d00`
- Status: `Published` (`publishedon` = `2026-08-06T15:37:55Z`)
- Owner: `Junwoo Jeong`
- Powered by: `GitHub Copilot`
- 표시 문구: `This agent uses GitHub Copilot. It consumes Copilot Credits.`

판정:

- GitHub Copilot harness agent 생성 가능
- GitHub Copilot harness agent publish 가능
- 현재 계정에 실제로 유효한 author/publish 경로가 존재

정확한 경로가 M365 Copilot, Copilot Studio Per User, 내부 entitlement 또는 Copilot Studio authors tenant 설정 중 무엇인지는 라이선스 API 제한 때문에 구분하지 못했지만, **기능 사용 가능 여부는 포털에서 실증됐습니다.**

### GitHub Copilot harness workflow

새 경험의 **Workflows** 페이지에서 확인:

- `New workflow` 버튼 활성화
- `Create your first workflow` 버튼 활성화
- 페이지 접근 제한이나 라이선스 오류 없음

판정:

- GitHub Copilot harness workflow 생성 가능
- 5분류와 P0~P3 우선순위 규칙으로 수정·게시 완료 ✅
- 서로 다른 입력 5건을 직접 실행해 분기와 Boolean 출력을 확인 ✅
- 최종 Flow checker는 API가 없어 재조회 불가. 저장 정의와 실행 결과로 대체

### Standard harness agent

새 경험 토글을 끄고 이전 Copilot Studio 경험에서 확인:

- **Start building from scratch > Agent** 메뉴 활성화
- **Agents** navigation 활성화
- 자연어 authoring 입력 영역 활성화

판정:

- Standard harness agent 생성 가능
- Standard GenAI/non-GenAI 선택과 실제 publish는 agent 설정에 따라 달라짐

### Standard harness agent flow

이전 Copilot Studio 경험에서 확인:

- **Flows** navigation 활성화
- **Start building from scratch > New agent flow** 메뉴 활성화
- Home에서 Agent/Workflow authoring 선택 가능

판정:

- Standard harness agent flow 생성 가능
- 실제 flow ID: `392d1a43-33d8-247c-fb53-b45dd60eb31c`
- 직접 실행: 123 ms, Succeeded
- Run ID: `08584156703223952675185929598CU03`
- 2026-08-09에 출력 계약을 4개로 확장하고 Bug/Security 사례 재실행 완료

## 계정에 있는 것

### Microsoft 365

- `Microsoft 365 E5 (no Teams)`
- `Power Virtual Agents for Office 365`

이 entitlement는 classic/Teams 기반 Copilot Studio 접근을 제공합니다.

### Power Platform 환경 권한

`Junwoo Jeong` Developer 환경:

- Enabled
- Licensed
- Read-Write
- `Basic User`
- `System Administrator`

따라서 agent/workflow 생성과 편집에 필요한 환경 권한은 충분합니다.

### 추가 환경 역할

`Marketplace AI` Production 환경에서는 팀을 통해:

- `Basic User`
- `Environment Maker`
- `Microsoft Copilot User`
- `System Administrator`

### 디바이스

- Company Portal 로그인
- User Approved MDM
- 상태: `In compliance`

### Tenant capacity

Power Platform Licensing API 결과:

| Currency | Purchased | Allocated | Consumed |
| --- | ---: | ---: | ---: |
| `AI` | 505,495,000 | 144,151,549 | 207,856,551 |
| `MCSMessages` | 1,418,500,000 | 32,500,000 | 1,835,791 |
| `MCSSessions` | 2,000 | 0 | 18 |

Developer 환경의 개별 allocation API가 404였지만, GitHub Copilot agent가 실제로 생성·publish된 사실로 보아 tenant pool, internal entitlement 또는 다른 유효한 capacity 경로가 적용되고 있습니다.

## 계정에 없는 것으로 확인된 것

### PAYG billing policy

Power Platform Billing Policy API:

- Billing policy count: `0`

즉, 현재 기능 사용은 PAYG billing policy 기반이 아닙니다.

### FinanceServiceDesk 환경 membership

`FinanceServiceDesk(FinSup)`:

- Dataverse 응답: `The user is not a member of the organization`
- 해당 환경은 현재 사용 불가

## 정확한 SKU는 미확인

사용자 구독 화면에서 별도 이름으로 다음 항목은 보이지 않았습니다.

- `Microsoft Copilot Studio Per User`
- `Copilot Studio User License`

Microsoft 365 Copilot license의 정확한 SKU도 Graph token protection 때문에 API로 확정하지 못했습니다.

그러나 포털에서 GitHub Copilot agent가 Published 상태이므로, **SKU 이름이 무엇이든 현재 계정에 유효한 GitHub Copilot harness author/publish entitlement가 있다는 사실은 확인됐습니다.**

따라서 앞으로는 SKU 추정보다 실제 포털 기능을 기준으로 판단합니다.

## 만들어진 리소스 실측 (2026-08-06)

조회 방법은 [`VERIFICATION.md`](VERIFICATION.md)를 참고하세요.

### Agents (Dataverse `bots`)

| Name (저장된 값) | Bot ID | 상태 |
| --- | --- | --- |
| `Simple Issue Triage Standard` | `54edb8e6-c490-f111-b8da-000d3a329d3b` | Draft ✅ (`publishedon` = `null`) — DLP 차단 |
| `Simple Issue Triage GitHub Har` | `4236d9a0-9d6e-42b3-9377-a65e1c188d00` | Published ✅ `2026-08-06T15:37:55Z` |

> **Bot ID를 2026-08-06에 정정했습니다.**
> 이전 기록의 `bbbb7d70…` / `7b3b35af…`는 `bots` 테이블에 존재하지 않았습니다.
> GitHub agent 이름은 **30자 제한으로 잘려** 저장돼 있습니다
> (입력값 `Simple Issue Triage GitHub Harness` 34자 → 저장값 30자).

### Workflows (Dataverse `workflows`)

포털 flow ID와 Dataverse workflow ID는 **동일한 값**입니다.

| Name | Workflow ID | 상태 |
| --- | --- | --- |
| `Classify Issue - Standard` | `392d1a43-33d8-247c-fb53-b45dd60eb31c` | Published ✅ · 5분류/P0~P3 직접 실행 검증 ✅ · required tests 2/2 PASS ✅ |
| `Classify Issue - GitHub Harness` | `a6666167-9cca-6bb0-ad80-8490bb022981` | Published ✅ · 5분류/P0~P3 동적 출력 ✅ · required tests 3/3 PASS ✅ |
| `Classify Issue - GitHub Harness (API Reference)` | `48ed52fb-bc90-f111-b8da-000d3a329d3b` | Activated. **포털 목록에는 미표시** |

직접 실행 기록:

```text
Standard  : Run ID 08584156703223952675185929598CU03 · 123 ms · Succeeded
Standard bug: Run ID 08584153617269814249280112903CU08 · Succeeded
              bug / P2 / Classified as bug with priority P2. / false
Standard sec: Run ID 08584153617260037098913224510CU26 · Succeeded
              security / P1 / Classified as security with priority P1. / true
GitHub bug: Run ID 08584155756901025273018959107CU23 · 197 ms · Succeeded
            bug / P2 / Classified as bug with priority P2. / false
GitHub sec: Run ID 08584155756752622167908104751CU21 · 281 ms · Succeeded
            security / P1 / Classified as security with priority P1. / true
GitHub doc: Run ID 08584155756598719867553132378CU09 · 139 ms · Succeeded
            documentation / P3 / Classified as documentation with priority P3. / false
```

GitHub workflow의 Response는 앞 노드의 계산 결과와 연결돼 있습니다.
`needsHumanReview`는 `@equals(outputs('Compose_1'),'security')`로 저장해
문자열이 아닌 JSON Boolean을 반환합니다.

### Agent → tool 연결

`Simple Issue Triage Standard`의 Tools에 `Classify Issue - Standard` 연결을 완료했습니다.
2026-08-09에 tool 출력도 `text`, `text_1`, `text_2`, `boolean` 네 개로
동기화했습니다. 각 출력의 표시 이름은 flow Response의 `title`인
`category`, `priority`, `summary`, `needsHumanReview`입니다.

`Simple Issue Triage GitHub Har`의 workflow tool도 수정했습니다.

- 올바른 workflow ID `a6666167-9cca-6bb0-ad80-8490bb022981`로 재연결 ✅
- 출력 `category`, `priority`, `summary`, `needsHumanReview` 4개 동기화 ✅
- Tool description 추가 ✅
- Agent 재게시 완료 (`publishedon` = `2026-08-06T15:37:55Z`) ✅
- Preview 대화 검증은 macOS 세션 잠금으로 미실행

> 초기에 발생한 Standard publish의 CloudFlow `NotFound` 오류는
> **native tool로 등록**하면서 해결됐습니다.
> 현재 남은 차단 원인은 `DlpViolationError / BlockedConnector` 하나이며,
> 차단된 connector는 `Skills with Copilot Studio`(`PvaSkills`)입니다.
> Dataverse `System Administrator` 역할만으로는 tenant DLP를 변경할 수 없습니다.
> 해제 절차: [`ROLES_AND_PERMISSIONS.md` 6장](ROLES_AND_PERMISSIONS.md#6-dlp-심화-차단된-connector-해제)

## 추가 검증 (2026-08-09)

Playwright MCP 연결과 브라우저 조작은 정상입니다. Copilot Studio 로그인 화면까지
이동하고 계정 입력도 성공했지만, 별도 브라우저 세션의 FIDO 보안 인증에서 멈춰
GitHub agent Preview 대화는 완료하지 못했습니다.

브라우저 외 경로에서는 다음을 다시 확인했습니다.

- GitHub agentic runtime의 `/copilotstudio/agenticruntime/3p/.../conversations`
  엔드포인트가 존재하고 Published agent를 인식함
- 현재 Azure CLI 앱 토큰은 `CopilotStudio.Copilots.Invoke`와
  `All.All.ReadWrite` 위임 권한이 없어 runtime 호출이 HTTP 403으로 차단됨
- 자동 평가 API도 현재 앱에 `CopilotStudio.MakerOperations.Read`와
  `All.All.ReadWrite`가 없어 HTTP 403으로 차단됨
- GitHub workflow 저장 정의의 입력 2개, 출력 4개, 식, Boolean 형식이 유효함
- 기존 Bug와 Security 성공 실행의 실제 trigger body와 Response body가 가이드의
  기대 결과와 일치함
- Standard flow에 `Priority` 노드와 누락된 출력 3개를 추가하고, 실제 trigger
  URI로 Bug, Security, Documentation, Feature, Question, P0 사례를 실행해
  출력 4개와 JSON Boolean을 확인함
- 두 agent 모두 의도한 flow/workflow tool component를 저장하고 있음

Power Automate 관리 API의 `/triggers/manual/run`으로 만든 다음 세 smoke run은
엔진 실행 자체는 `Succeeded`였지만 Skills trigger 입력을 주입하지 못해
`question / P3`로 계산됐고 `Respond_to_the_agent`가 `Skipped`였습니다.
따라서 기능 성공 증거로 사용하지 않습니다.

```text
08584153628145226869506298288CU21
08584153627604946582465518805CU18
08584153627396252548042872152CU02
```

적용 중인 DLP 정책 `Personal Developer - (default)`은
2026-08-08에 다시 수정됐으며 기본 분류가 `Blocked`입니다.
`PvaSkills`(`Skills with Copilot Studio`)도 현재 `Blocked` 그룹에 있음을
정책 API로 재확인했습니다.

### 전체 재검증 (2026-08-09 12:17 KST)

수정 후 두 flow를 같은 여섯 사례로 다시 실행했습니다.

| 사례 | Standard | GitHub |
| --- | --- | --- |
| Bug | `bug / P2 / false` ✅ | `bug / P2 / false` ✅ |
| Security | `security / P1 / true` ✅ | `security / P1 / true` ✅ |
| Documentation | `documentation / P3 / false` ✅ | `documentation / P3 / false` ✅ |
| Feature | `feature / P2 / false` ✅ | `feature / P2 / false` ✅ |
| Question | `question / P3 / false` ✅ | `question / P3 / false` ✅ |
| Outage / data loss | `question / P0 / false` ✅ | `question / P0 / false` ✅ |

각 flow의 최신 실행 6건은 모두 `Succeeded`입니다. 두 agent의 tool이 올바른
flow/workflow ID와 출력 네 개를 참조하는 것도 재확인했습니다.

Playwright MCP의 탐색, 입력, 클릭, snapshot은 다시 정상 동작했습니다.
다만 별도 브라우저 세션은 `junwoojeong@microsoft.com`의 FIDO 보안 창에서
대기하므로 agent Preview는 완료할 수 없습니다. GitHub agentic runtime 직접
호출도 현재 Azure CLI 앱에 `CopilotStudio.Copilots.Invoke`와
`All.All.ReadWrite`가 없어 HTTP 403입니다. Standard agent publish는
`PvaSkills` DLP 차단이 계속 적용됩니다.

## 현재 실습 가능 범위

**4종 생성 완료, 3종 Published, 1종 Draft**입니다.
Draft 리소스는 `Simple Issue Triage Standard`이며 tenant DLP 예외가 필요합니다.

| 단계 | 현재 상태 |
| --- | --- |
| Standard agent 생성 | 가능 |
| Standard agent flow 생성 | 가능 |
| GitHub Copilot harness agent 생성 | 가능 |
| GitHub Copilot harness workflow 생성 | 가능 |
| GitHub agent publish | 가능 (Published agent로 확인) |
| GitHub workflow publish/run | Published, 5분류 required tests 3/3 PASS |
| GitHub agent workflow tool | 올바른 B-1 workflow와 출력 4개 연결, 재게시 완료 |
| Standard agent publish | Tool 연결 완료, tenant DLP로 차단 |
| Standard agent flow publish/run | Published, 출력 4개, 5분류/P0~P3 검증, required tests 2/2 PASS |
| 웹 Test/Preview | B-1 Test PASS. B-2 Preview는 Playwright 세션의 FIDO 인증으로 미확인 |

## 남은 작업

| 항목 | 상태 | 해결 방법 |
| --- | --- | --- |
| Lab B 최종 Flow checker 재확인 | 재현 불가 | API가 없어 정의 원본과 5건의 성공 실행으로 대체 |
| GitHub agent → workflow Preview | 미확인 | FIDO 로그인을 완료해 Preview하거나, Invoke 권한이 있는 public client 앱으로 agentic runtime 호출 |
| Standard agent → flow end-to-end 호출 | 미확인 | DLP 예외 승인 후 Standard Test 패널에서 실행 |
| `PvaSkills` 테넌트 DLP 예외 | 대기 | [`ROLES_AND_PERMISSIONS.md` 6장](ROLES_AND_PERMISSIONS.md#6-dlp-심화-차단된-connector-해제)의 요청 템플릿 사용 |
| `Classify Issue - GitHub Harness (API Reference)` 정리 | 미결정 | Dataverse에서 소유 관계와 참조를 확인한 뒤 정리 |

가이드의 목표 상태와 현재 테넌트 상태는 다릅니다. 새로 실습할 때는
[`PORTAL_CREATION_GUIDE.md`](PORTAL_CREATION_GUIDE.md)의 값만 따르고,
이 표는 기존 리소스를 정리할 때 사용하세요.
