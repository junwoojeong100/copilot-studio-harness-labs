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

Agent:

| Name | Bot ID | State |
| --- | --- | --- |
| Simple Issue Triage Standard | `bbbb7d70-5fa8-4500-a2a1-d48ff91b71e2` | Draft: DLP blocked |
| Simple Issue Triage GitHub Harness | `7b3b35af-22a1-49b8-bd4d-a79576f51730` | Published |

Native workflow:

| Name | Portal flow ID | Dataverse workflow ID | State |
| --- | --- | --- | --- |
| Classify Issue - Standard | `24623d9d-bb90-f111-b8da-000d3a329d3b` | 동일 | Published, run PASS |
| Classify Issue - GitHub Harness | `8ce00fab-9db1-96fd-74b8-8fde4d78c522` | 동일 | Published, run PASS |

## 남은 확인

생성 자체는 완료됐습니다. 다음은 포털에서 사용자가 확인할 항목입니다.

1. Agents 목록에서 agent 두 개 확인
2. Flows/Workflows 목록에서 workflow 두 개 확인
3. Standard agent의 Tools에서 native Standard workflow 연결 확인
4. Power Platform DLP 예외 승인
5. Standard Publish와 Test/Preview 실행
6. GitHub agent에 native GitHub workflow 연결 후 재Publish

Standard publish의 CloudFlow `NotFound` 오류는 native tool 등록으로 해결됐습니다. 현재 남은 진단은 `DlpViolationError / BlockedConnector` 하나입니다. Dataverse `System Administrator` 역할만으로 tenant DLP를 변경할 수는 없습니다.
