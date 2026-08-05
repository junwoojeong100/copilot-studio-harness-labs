# Portal Capability Check: `junwoojeong@microsoft.com`

확인 일시: 2026-08-05

대상 환경:

```text
Junwoo Jeong
e477cbf2-150c-eee7-a852-b29ac07f541d
Developer
```

## 결론

현재 계정은 웹 Copilot Studio 포털에서 다음 네 가지를 모두 생성할 수 있습니다.

| Capability | 확인 결과 | 근거 |
| --- | --- | --- |
| Standard agent | 가능 | 이전 경험의 Agent 생성 메뉴 활성화 |
| Standard agent flow | 가능 | Flows 페이지와 New agent flow 메뉴 활성화 |
| GitHub Copilot harness agent | 가능 | 기존 GitHub Copilot agent가 Published 상태 |
| GitHub Copilot harness workflow | 가능 | Workflows 페이지의 New workflow 버튼 활성화 |

## 실제 계정 역할

Developer 환경 직접 역할:

- Basic User
- System Administrator

상태:

- Enabled
- Licensed
- Read-Write

판정:

- Agent/workflow 생성 권한 충분

## 디바이스 상태

- Company Portal 로그인
- User Approved MDM
- In compliance

## Capacity

Tenant 전체 AI/MCS capacity는 존재합니다.

GitHub Copilot agent가 실제 Published 상태이므로 이 환경에서 GitHub harness author/publish 경로가 유효하게 동작한 사실이 확인됐습니다.

## 실제 생성 검증

리소스 4종의 생성은 완료됐습니다. 배포는 Standard agent를 제외한 3종이
완료됐으며, `Simple Issue Triage Standard`는 DLP 차단으로 Draft 상태입니다.

Agent:

| Name | Bot ID | State |
| --- | --- | --- |
| Simple Issue Triage Standard | `bbbb7d70-5fa8-4500-a2a1-d48ff91b71e2` | Draft: DLP blocked |
| Simple Issue Triage GitHub Harness | `7b3b35af-22a1-49b8-bd4d-a79576f51730` | Published |

Native workflow:

| Name | Portal flow ID | Dataverse workflow ID | State |
| --- | --- | --- | --- |
| Classify Issue - Standard | `392d1a43-33d8-247c-fb53-b45dd60eb31c` | 동일 | Published, run PASS (123 ms) |
| Classify Issue - GitHub Harness | `a6666167-9cca-6bb0-ad80-8490bb022981` | 동일 | Published, checker 0/0, run PASS (149 ms) |

Standard flow 직접 검증:

```text
Input 1: Login fails
Input 2: 503 error
Run ID: 08584156703223952675185929598CU03
Status: Succeeded
Duration: 123 ms
All nodes: Succeeded
```

GitHub workflow 직접 검증:

```text
Input 1: 503 error
Input 2: urgent
Run ID: 08584156712497958263468546463CU12
Status: Succeeded
Duration: 149 ms
Outputs: bug / P0 / Classified as bug with priority P0. / true
```

Agent flows 목록에는 Standard와 GitHub Harness flow가 각각 하나씩 존재합니다.
Standard agent의 Tools에도 `Classify Issue - Standard` 연결을 완료했습니다.

## 남은 운영 작업

리소스 생성과 workflow 직접 실행은 완료됐습니다. Standard agent 배포는
아직 완료되지 않았습니다.

1. GitHub agent end-to-end Preview
2. Power Platform DLP 예외 승인
3. Standard agent Publish 및 end-to-end Test

Standard publish의 CloudFlow `NotFound` 오류는 native tool 등록으로 해결됐습니다.
현재 남은 차단 원인은 `DlpViolationError / BlockedConnector`이며,
차단된 connector는 `Skills with Copilot Studio`입니다. Dataverse
`System Administrator` 역할만으로 tenant DLP를 변경할 수는 없습니다.
해제 절차는 [`ROLES_AND_PERMISSIONS.md` 6장](ROLES_AND_PERMISSIONS.md#6-dlp-심화-차단된-connector-해제)을 참고하세요.
