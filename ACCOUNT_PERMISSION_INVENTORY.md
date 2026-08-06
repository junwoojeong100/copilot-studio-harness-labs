# `junwoojeong@microsoft.com` 권한 및 포털 기능 확인

최종 확인: 2026-08-05

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
- Status: `Published` (`publishedon` = `2026-08-05T11:54:16Z`)
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
- Workflow publish와 직접 실행 완료
- Flow checker 0 errors / 0 warnings
- 직접 실행 149 ms, Succeeded

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

## 현재 실습 가능 범위

현재 리소스 상태는 **4종 생성 완료, 3종 Published, 1종 Draft**입니다.
Draft 리소스는 `Simple Issue Triage Standard`이며 tenant DLP 예외가 필요합니다.

| 단계 | 현재 상태 |
| --- | --- |
| Standard agent 생성 | 가능 |
| Standard agent flow 생성 | 가능 |
| GitHub Copilot harness agent 생성 | 가능 |
| GitHub Copilot harness workflow 생성 | 가능 |
| GitHub agent publish | 가능함을 기존 Published agent로 확인 |
| GitHub workflow publish/run | Published, direct run PASS |
| Standard agent publish | Tool 연결 완료, tenant DLP로 차단 |
| Standard agent flow publish/run | Published, direct run PASS (123 ms) |
| 웹 Test/Preview | 가능 |

## 남은 운영 작업

1. GitHub agent end-to-end Preview
2. Power Platform DLP 정책에서 `Skills with Copilot Studio` connector 허용 또는 환경 예외 승인
   (절차: [`ROLES_AND_PERMISSIONS.md` 6장](ROLES_AND_PERMISSIONS.md#6-dlp-심화-차단된-connector-해제))
3. Standard agent Publish와 end-to-end Preview

## 최종 판정

### 가능

- Standard agent
- Standard agent flow
- GitHub Copilot harness agent
- GitHub Copilot harness workflow

### 실제 확인 완료

- Standard native workflow `392d1a43-33d8-247c-fb53-b45dd60eb31c` publish
- Standard native workflow direct run: 123 ms, Succeeded
- Standard native workflow Run ID: `08584156703223952675185929598CU03`
- GitHub native workflow `a6666167-9cca-6bb0-ad80-8490bb022981` publish
- GitHub native workflow Flow checker 0 errors / 0 warnings
- GitHub native workflow direct run: 149 ms, Succeeded
- GitHub native workflow outputs: `bug`, `P0`, `Classified as bug with priority P0.`, `true`
- Standard agent tool `Classify Issue - Standard` 연결
- GitHub agent Published

### 추가 확인이 필요한 것

- `Simple Issue Triage Standard` Publish
- Standard agent + agent flow end-to-end run
- GitHub agent + workflow end-to-end Preview
- tenant DLP 예외 승인
