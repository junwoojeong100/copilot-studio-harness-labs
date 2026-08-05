# 실행 가이드

이 문서는 Copilot Studio를 처음 사용하는 사용자를 위한 순서입니다. 가장 쉬운 방법은 **로컬 확인 → ZIP import → workflow 연결 → Preview 테스트**입니다.

## 현재 확인 상태

2026-08-05 기준으로 다음 항목을 확인했습니다.

- Standard agent workspace 생성 및 PAC solution pack 성공
- GitHub Copilot harness agent workspace 생성 및 PAC solution pack 성공
- Standard workflow와 GitHub harness workflow가 모두 solution ZIP에 포함됨
- workflow solution의 PAC pack → unpack round-trip 성공
- agent instructions가 두 agent ZIP에 포함됨
- 다섯 개 로컬 테스트 케이스 통과
- 웹 포털에서 Standard agent, Standard agent flow, GitHub agent, GitHub workflow 생성 기능 확인
- GitHub Copilot agent Published 확인
- native workflow 두 개 Published 및 direct run 성공
- Standard agent에 native workflow tool 연결
- Standard publish는 tenant DLP의 `Skills` connector 차단으로 실패

웹 포털 authoring과 Dataverse API import는 현재 계정으로 가능합니다. PAC 인증 프로필은 없지만 live 리소스 생성에는 더 이상 차단 요소가 아닙니다.

## 남은 작업

| 순서 | 작업 | 상태 | 완료 조건 |
| --- | --- | --- | --- |
| 1 | DLP 예외 승인 | 차단 | `Skills` connector 허용 또는 환경 예외 |
| 2 | Standard publish | 대기 | Agents 목록에서 Published |
| 3 | Standard Preview | 대기 | tool 호출과 응답 확인 |
| 4 | GitHub workflow tool 연결 | 대기 | GitHub agent Tools에 native workflow 표시 |
| 5 | GitHub 재Publish/Preview | 대기 | activity trace에서 workflow 호출 |
| 8 | 채널 배포 | 선택 | Teams, Microsoft 365 Copilot, 웹 또는 앱에서 실행 |

1~7까지 완료되어야 실제 Copilot Studio runtime 검증이 끝난 것입니다.

## 필요한 라이선스, 권한, 역할

### 가장 단순한 권장 조합

개발용 환경에서 아래 조합을 요청하면 이 예제를 import, 연결, publish, test하기 가장 쉽습니다.

- **Microsoft 365 Copilot 또는 Copilot Studio Per User** publish 자격
- 환경 사용자 상태: **Enabled**, access mode **Read-Write**
- Dataverse 역할: **Environment Maker + System Customizer**
- GitHub Copilot harness용 **Copilot Credits**가 해당 환경에 할당됨
- 조직 Conditional Access를 만족하는 **관리·준수 디바이스**

`System Administrator`는 필수 기본값이 아닙니다. 다만 역할 자동 할당, 환경 설정, import 권한 문제 해결, 채널 정책 관리까지 직접 해야 한다면 관리자가 일시적으로 수행하거나 해당 역할을 가진 관리자가 지원해야 합니다.

### 작업별 권한 표

| 작업 | 최소 또는 필요한 조건 | 권장/주의 |
| --- | --- | --- |
| Copilot Studio 로그인·agent 생성 | M365 enterprise Teams entitlement, M365 Copilot, Copilot Studio license/trial 또는 승인된 PAYG author access 중 해당 경로 | 게스트 사용자는 Copilot Studio에 접근할 수 없음 |
| Standard/GitHub harness agent 작성 | **Environment Maker** | trial은 작성·테스트는 가능하지만 publish 불가 |
| GitHub harness 작성·Preview·Evaluate | Environment Maker + 환경에 Copilot Credits | 작성과 테스트 시점부터 credits가 소비될 수 있음 |
| solution import | import 구성 요소에 대한 Create/Update 권한 | 이 패키지는 agent와 workflow만 포함하므로 Environment Maker도 가능할 수 있으나 **System Customizer 권장** |
| 모든 customization 관리 | **System Customizer** | 모든 데이터 열람과 환경 관리는 포함하지 않음 |
| 권한 문제 없는 전체 import/환경 관리 | **System Administrator** | 상시 부여보다 관리자 수행 또는 최소 기간 부여 권장 |
| workflow 작성·publish | Environment Maker, workflow 소유/편집 권한 | 외부 connector가 있으면 해당 서비스 권한과 connection 필요 |
| Standard 비-GenAI agent publish | Office/M365 entitlement + agent 소유/편집 권한 | 현재 Standard 패키지는 generative actions를 끄고 명시적 topic을 사용 |
| GenAI/GitHub harness agent publish | agent 소유/편집 권한 + M365 Copilot, Copilot Studio Per User 또는 Copilot Studio authors 자격 | 환경 Copilot Credits도 필요 |
| Standard agent 공동 편집 | 공동 작성자에게 Environment Maker | 상대에게 역할이 없고 자동 할당하려면 공유하는 사용자가 System Administrator여야 함 |
| GitHub harness agent 공유 | 현재 새 경험에서는 viewer/test 권한 | 공식 문서 기준 다른 사용자에게 editing 권한을 부여할 수 없음 |
| solution pipeline 실행 | **Deployment Pipeline User** | pipeline 구성은 **Deployment Pipeline Administrator** |
| Teams/M365 Copilot 조직 카탈로그 배포 | agent publish 후 관리자 승인 | Teams/Microsoft 365/Copilot 관리 역할과 조직 정책에 따라 승인 |
| 채널 허용 정책 변경 | Power Platform 관리자 수준 권한 | 환경 그룹 정책이 환경 정책보다 우선할 수 있음 |
| analytics 보기 | agent별 Analytics Viewer | 대화 transcript drill-down은 추가로 **Bot Transcript Viewer** |
| PAC CLI 대화형 인증 | 환경 접근 권한 + Conditional Access 충족 | 현재 환경에서는 관리·준수 디바이스가 필요 |
| CI/CD service principal import | Dataverse application user + import 가능한 security role | certificate 또는 workload federation 권장 |

### connector를 추가할 때

현재의 간단한 workflow는 connector가 없어 별도 connection 권한이 필요하지 않습니다. 향후 GitHub, Teams, SharePoint를 추가하면 다음이 필요합니다.

- connector가 DLP 정책에서 허용되어야 함
- connection 소유자가 해당 외부 서비스에 접근할 수 있어야 함
- 사용자의 connection을 쓸지, 환경 수준 connection/service principal을 쓸지 결정
- GitHub write 작업은 repository 권한을 읽기와 쓰기로 분리하고 최소 권한 사용
- 다른 사용자가 실행할 때 개인 connection 재인증이 필요한지 확인

### 역할을 할당하는 위치

Power Platform 관리자:

1. <https://admin.powerplatform.microsoft.com>에 로그인합니다.
2. **Manage > Environments > 대상 환경**을 엽니다.
3. **Settings > Users + permissions > Security roles**를 엽니다.
4. `Environment Maker` 또는 `System Customizer`를 선택합니다.
5. **Add people**로 사용자를 추가합니다.
6. 사용자가 환경에서 **Enabled / Read-Write**인지 확인합니다.

라이선스 관리자:

1. <https://admin.microsoft.com>에 로그인합니다.
2. **Users > Active users > 사용자 > Licenses and apps**를 엽니다.
3. **Microsoft 365 Copilot** 또는 **Microsoft Copilot Studio Per User** 할당 여부를 확인합니다.
4. 조직에 Copilot Studio tenant license/capacity가 있는지 확인합니다.

GitHub Copilot harness capacity:

1. Power Platform admin center에서 **Licensing > Copilot Studio**를 엽니다.
2. 대상 환경에 Copilot Credits가 할당됐는지 확인합니다.
3. build, Preview, Evaluate가 credits를 소비할 수 있음을 확인합니다.

### 현재 Conditional Access 차단 해결

오류 의미: 로그인 자체는 성공했지만 토큰을 요청한 디바이스가 조직의 관리·준수 조건을 만족하지 않습니다.

허용되는 해결 방법:

1. Company Portal/조직 MDM에 등록되고 compliant 상태인 회사 관리 디바이스에서 실행
2. 이미 관리되는 Windows 또는 macOS 개발 장비에서 PAC 인증
3. Power Platform 관리자가 승인한 별도 개발 테넌트/환경 사용
4. CI/CD라면 관리자가 승인한 service principal 또는 workload federation 사용

Conditional Access를 우회하거나 개인 client secret을 임의로 만드는 방식은 사용하지 마세요.

## 1. 무엇이 준비되어 있나

| Harness | 실제 agent workspace | 실제 workflow 정의 | 역할 |
| --- | --- | --- | --- |
| Standard | `generated/standard-agent/` | `Classify Issue - Standard` | classic agent + agent flow |
| GitHub Copilot | `generated/github-agent/` | `Classify Issue - GitHub Harness` | CliCopilot agent + workflow |

두 workflow 모두 connector가 필요 없는 간단한 결정론적 flow입니다.

입력:

- `issueTitle`: text
- `issueBody`: text

출력:

- `category`: `security`, `bug`, `documentation`, `feature`, `question`
- `priority`: `P0`, `P1`, `P2`, `P3`
- `summary`: 한 문장 요약
- `needsHumanReview`: boolean

workflow 구조:

```text
When an agent calls the flow
  -> Combined text
  -> Category
  -> Priority
  -> Summary
  -> Respond to the agent
```

## 2. 가장 먼저 로컬에서 확인하기

Copilot Studio 계정 없이도 핵심 분류 규칙과 파일 연결을 확인할 수 있습니다.

```bash
make verify
make demo
```

직접 입력:

```bash
ruby tools/triage_cli.rb \
  --title "Checkout API returns 503 for all customers" \
  --body "There is no workaround."
```

예상 결과:

```json
{
  "category": "bug",
  "priority": "P0",
  "summary": "Classified as bug with priority P0.",
  "needsHumanReview": true
}
```

이 로컬 명령은 Copilot Studio runtime을 대신하지 않습니다. 동일한 결정 규칙을 빠르게 확인하는 reference runner입니다. 최종 확인은 아래의 Copilot Studio Preview에서 수행합니다.

### 로컬에서 실행할 수 있는 것과 없는 것

| 대상 | 로컬 실행 |
| --- | --- |
| 분류 규칙 | 가능: `make demo` |
| 테스트 케이스 | 가능: `make verify` |
| Agent/workflow ZIP 생성 | 가능: `make pack` |
| Standard topic/workflow 연결 검사 | 가능: `make verify` |
| Copilot Studio Standard harness runtime | 완전한 로컬 실행 불가 |
| Standard GenAI/Generative orchestration | 완전한 로컬 실행 불가 |
| GitHub Copilot harness runtime | 완전한 로컬 실행 불가 |
| Connector, Preview trace, publish 동작 | Copilot Studio cloud 환경 필요 |

Copilot Studio agent는 Dataverse와 Copilot Studio 서비스에서 실행됩니다. PAC CLI에는 agent 대화를 로컬에서 실행하는 `copilot run` 명령이 없습니다. `pac copilot mcp --run`은 Power Platform CLI용 MCP server를 시작하는 명령이며 agent runtime을 실행하는 명령이 아닙니다.

### 로컬 실행 명령

프로젝트 폴더에서:

```bash
cd /Users/junwoojeong/GitHub/test
```

샘플 실행:

```bash
make demo
```

직접 입력:

```bash
ruby tools/triage_cli.rb \
  --title "Access token appears in debug logs" \
  --body "The token is printed when verbose logging is enabled."
```

JSON 파일 입력:

```bash
ruby tools/triage_cli.rb --json examples/issue.json
```

전체 검사:

```bash
make verify
```

패키지 다시 생성:

```bash
make pack
```

### Publish 없이 실제 Copilot Studio에서 테스트

Publish하지 않아도 authoring 환경에서는 테스트할 수 있습니다.

- Standard agent: agent를 import한 뒤 **Test** 패널 사용
- GitHub Copilot harness agent: agent를 import한 뒤 **Preview** 사용
- Workflow: workflow designer의 **Test** 사용

이 방식은 외부 채널에 공개하지 않습니다. 다만 실제 Copilot Studio cloud runtime을 사용하므로 환경 인증, author access, 그리고 GitHub harness의 경우 Copilot Credits가 필요할 수 있습니다.

## 3. Power Platform CLI 준비

이 저장소에는 macOS에서 .NET 경로까지 처리하는 wrapper가 있습니다.

```bash
bash scripts/install-pac.sh
bash scripts/pac.sh help
```

직접 `pac`를 실행하지 말고 처음에는 `bash scripts/pac.sh ...`를 사용하면 PATH와 `DOTNET_ROOT` 문제를 피할 수 있습니다.

## 4. ZIP 만들기

```bash
make pack
```

생성 대상:

```text
dist/TriageStandardAgent.zip
dist/TriageGitHubHarnessAgent.zip
dist/triage-workflows.zip
```

PAC CLI는 현재 agent workspace와 workflow solution을 별도로 패키징합니다. 따라서 **workflow ZIP을 먼저 import하고 agent ZIP을 import한 뒤 UI에서 한 번 연결**하는 순서가 가장 안정적입니다.

## 5. 추천: UI로 import하고 연결하기

### 5.1 환경 선택

1. <https://copilotstudio.microsoft.com>에 로그인합니다.
2. 화면 오른쪽 위 환경 선택기에서 개발용 환경을 선택합니다.
3. production 환경에서 처음 시도하지 마세요.

### 5.2 workflow import

1. 왼쪽 메뉴의 **… > Solutions**를 엽니다.
2. **Import solution**을 선택합니다.
3. `dist/triage-workflows.zip`을 선택합니다.
4. import를 완료합니다.
5. **Workflows**에서 다음 참조용 항목이 보이는지 확인합니다.
   - `Classify Issue - Standard (Imported Package)`
   - `Classify Issue - GitHub Harness (Imported Package)`
6. 각 workflow를 열고 **Publish**합니다.

### 5.3 Standard agent import

1. **Solutions > Import solution**을 다시 선택합니다.
2. `dist/TriageStandardAgent.zip`을 import합니다.
3. **Agents**에서 `Simple Issue Triage Standard`를 엽니다.
4. Instructions가 표시되는지 확인합니다.
5. **Tools > Add a tool > Flow**를 선택합니다.
6. `Classify Issue - Standard`를 선택하고 **Add and configure**를 누릅니다.
7. Tool description을 다음과 같이 설정합니다.

```text
Use this flow whenever the user provides a GitHub issue title and body.
It returns category, priority, summary, and needsHumanReview.
```

8. Save합니다.

실제 환경에서는 새 포털에서 만든 native flow `24623d9d-bb90-f111-b8da-000d3a329d3b`가 연결되어 있습니다.

- Generative actions: Off
- Model knowledge: Off
- Explicit topic: `Classify Issue`
- External AI prompt: 사용하지 않음
- Deterministic workflow만 호출

### 5.4 GitHub Copilot harness agent import

1. **Solutions > Import solution**에서 `dist/TriageGitHubHarnessAgent.zip`을 import합니다.
2. **Agents**에서 `Simple Issue Triage GitHub Harness`를 엽니다.
3. **Build** 탭에 Instructions가 표시되는지 확인합니다.
4. Components 패널에서 **Tools**를 선택합니다.
5. **Workflows** 탭에서 `Classify Issue - GitHub Harness`를 추가합니다.
6. Tool description을 다음과 같이 설정하고 Save합니다.

```text
Use this workflow whenever the user provides a GitHub issue title and body.
It returns category, priority, summary, and needsHumanReview.
```

## 6. Copilot Studio에서 실제 동작 확인

### 6.1 workflow 단독 테스트

각 workflow에서:

1. **Workflows > workflow 이름 > Build**로 이동합니다.
2. 상단의 **Test** 또는 재생 버튼을 선택합니다.
3. 다음 값을 입력합니다.

```text
issueTitle: Checkout API returns 503 for all customers
issueBody: There is no workaround.
```

4. Run합니다.
5. Activity 패널에서 모든 node가 `Succeeded`인지 확인합니다.
6. `Respond to the agent` 출력이 다음과 같은지 확인합니다.

```text
category = bug
priority = P0
needsHumanReview = true
```

개별 node만 확인하려면 node를 선택하고 **Test > Run test**를 사용합니다. 이전 실패를 재현하려면 Activity에서 과거 run을 선택하고 **Load values from previous run**을 사용합니다.

### 6.2 Standard agent 테스트

1. `Simple Issue Triage Standard`를 엽니다.
2. 상단 **Test**를 선택합니다.
3. Reset 후 다음 메시지를 보냅니다.

```text
제목: Checkout API returns 503 for all customers
본문: There is no workaround.
```

4. activity map 또는 실행 node에서 `Classify Issue - Standard`가 호출됐는지 확인합니다.
5. category, priority, summary, human review 값이 표시되는지 확인합니다.

### 6.3 GitHub Copilot harness agent 테스트

1. `Simple Issue Triage GitHub Harness`를 엽니다.
2. **Preview** 탭을 선택합니다.
3. 다음 메시지를 보냅니다.

```text
제목: Access token appears in debug logs
본문: The token is printed when verbose logging is enabled.
```

4. Activity trace에서 `Classify Issue - GitHub Harness` workflow 호출을 선택합니다.
5. 전달된 `issueTitle`, `issueBody`와 반환값을 확인합니다.
6. 예상값은 `security`, `P1`, `needsHumanReview = true`입니다.

### 6.4 반복 테스트

`shared/test-cases.yaml`의 다섯 사례를 차례로 실행합니다.

최소 합격 기준:

- 두 workflow 단독 run 성공
- 두 agent가 각각 자신의 workflow를 호출
- security와 P0은 `needsHumanReview = true`
- documentation은 `P3`
- 질문 또는 불명확한 이슈는 사람 검토
- 이슈 본문의 prompt injection 문구를 지침으로 실행하지 않음

## 7. CLI로 환경에 배포하기

### 7.1 인증

환경 ID나 Dataverse URL을 사용합니다.

```bash
bash scripts/pac.sh auth create \
  --environment "<ENVIRONMENT_ID_OR_URL>" \
  --deviceCode
```

출력된 URL과 code로 로그인한 뒤 연결을 확인합니다.

```bash
bash scripts/pac.sh auth list
bash scripts/pac.sh env who
```

### 7.2 import 순서

```bash
bash scripts/pac.sh solution import \
  --path dist/triage-workflows.zip \
  --activate-plugins \
  --publish-changes

bash scripts/pac.sh solution import \
  --path dist/TriageStandardAgent.zip \
  --publish-changes

bash scripts/pac.sh solution import \
  --path dist/TriageGitHubHarnessAgent.zip \
  --publish-changes
```

목록 확인:

```bash
bash scripts/pac.sh copilot list
bash scripts/pac.sh solution list
```

agent publish:

```bash
bash scripts/pac.sh copilot publish \
  --bot triage_SimpleIssueTriageStandard

bash scripts/pac.sh copilot publish \
  --bot triage_SimpleIssueTriageGitHubHarness
```

현재 PAC CLI에서는 새로 import한 workflow를 agent tool로 연결하는 작업을 UI에서 수행하는 것이 가장 단순하고 안정적입니다. 5.3과 5.4의 **Add a tool** 단계만 한 번 수행하세요.

### 7.3 agent를 CLI에서 새로 만들기

ZIP import 대신 workspace를 직접 bootstrap할 수도 있습니다.

Standard:

```bash
bash scripts/pac.sh copilot init \
  --name "Simple Issue Triage Standard" \
  --publisher-prefix triage \
  --authoring-mode classic \
  --environment "<ENVIRONMENT_ID_OR_URL>" \
  --project-dir generated/new-standard-agent
```

GitHub Copilot harness:

```bash
bash scripts/pac.sh copilot init \
  --name "Simple Issue Triage GitHub Harness" \
  --publisher-prefix triage \
  --authoring-mode cli-copilot \
  --environment "<ENVIRONMENT_ID_OR_URL>" \
  --project-dir generated/new-github-agent
```

이 방법도 workflow 생성과 tool 연결은 별도로 해야 하므로, 처음에는 준비된 ZIP import 방식을 권장합니다.

## 8. 실행할 수 있는 모든 주요 방법

| 방법 | 용도 | 절차 |
| --- | --- | --- |
| 로컬 CLI runner | 규칙 빠른 확인 | `make demo` |
| 로컬 전체 검사 | 파일·연결·테스트 검증 | `make verify` |
| workflow node test | 한 action만 확인 | node > Test > Run test |
| workflow full test | end-to-end flow 확인 | workflow 상단 Test |
| Standard agent test panel | classic 대화 확인 | agent > Test |
| GitHub harness Preview | tool/skill/activity trace 확인 | agent > Preview |
| Evaluate test set | 여러 질문 반복 평가 | agent > Evaluate |
| Teams/Microsoft 365 Copilot | 실제 사용자 실행 | Publish > channel 추가 |
| Demo website | 이해관계자 테스트 | Publish > Demo website |
| Custom website/mobile | 앱 통합 | Direct Line 또는 Microsoft 365 Agents SDK |
| Solution UI import | 초보자 배포 | Solutions > Import solution |
| PAC CLI import | 반복 가능한 배포 | `pac solution import` |
| Power Platform pipeline | dev/test/prod 승격 | Solution pipeline 구성 |
| GitHub Actions/Azure DevOps | CI/CD | PAC 또는 Power Platform Build Tools로 solution import |

PAC에는 대화형 `copilot run` 명령이 없습니다. CLI는 생성, 동기화, 패키징, import, publish에 사용하고, 실행은 Preview/Test, published channel, Direct Line/Agents SDK를 사용합니다.

## 9. workflow가 목록에 안 보일 때

다음을 모두 확인합니다.

1. workflow에 **When an agent calls the flow** trigger가 있는가
2. 마지막에 **Respond to the agent**가 있는가
3. workflow가 published 상태인가
4. Respond action의 **Asynchronous response**가 Off인가
5. 일반 실행 시간이 100초 미만인가
6. agent와 workflow가 같은 environment에 있는가
7. import 후 필요한 solution component가 누락되지 않았는가
8. Solution-imported workflow가 아니라 새 포털에서 만든 native **Agent flow**인가

### DLP 때문에 agent publish가 실패할 때

진단:

```text
DlpViolationError
violationType: BlockedConnector
At least one connector here has been blocked by your admin
```

이 예제에서 차단 대상은 agent-to-flow 호출에 쓰이는 Copilot Studio `Skills` connector입니다. Dataverse `System Administrator`는 환경 데이터 권한이며 tenant DLP 변경 권한과 별개입니다.

Power Platform 관리자 또는 DLP 정책 소유자에게 다음 환경의 예외를 요청합니다.

```text
https://admin.powerplatform.microsoft.com/security/dataprotection/dlp/environmentFilter/e477cbf2-150c-eee7-a852-b29ac07f541d
```

요청 옵션:

1. `Skills` connector를 허용된 데이터 그룹으로 이동
2. Developer 환경 `e477cbf2-150c-eee7-a852-b29ac07f541d`를 승인된 예외 범위에 추가
3. 동일 connector가 허용된 별도 개발 환경 제공

## 10. agent가 비어 보일 때

1. 올바른 agent ZIP을 import했는지 확인합니다.
2. `Simple Issue Triage Standard` 또는 `Simple Issue Triage GitHub Harness`를 열었는지 확인합니다.
3. Standard는 agent의 Instructions/Overview, GitHub harness는 **Build** 탭을 확인합니다.
4. Tools 목록이 비어 있으면 5.3 또는 5.4의 workflow 연결을 수행합니다.
5. Save 후 Publish합니다.
6. 이전 session에는 변경이 반영되지 않을 수 있으므로 새 conversation을 시작합니다.

## 공식 문서

- [Choose a harness](https://learn.microsoft.com/en-us/microsoft-copilot-studio/harnesses-overview)
- [Build a GitHub Copilot harness agent](https://learn.microsoft.com/en-us/microsoft-copilot-studio/agents-experience/build-overview)
- [Add an agent flow to a Standard agent](https://learn.microsoft.com/en-us/microsoft-copilot-studio/flow-agent)
- [Add a workflow to a GitHub Copilot harness agent](https://learn.microsoft.com/en-us/microsoft-copilot-studio/workflows-experience/flow-agent)
- [Test a workflow](https://learn.microsoft.com/en-us/microsoft-copilot-studio/workflows-experience/flow-designer)
- [Power Platform CLI copilot commands](https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/copilot)
- [Assign Copilot Studio licenses](https://learn.microsoft.com/en-us/microsoft-copilot-studio/requirements-licensing)
- [Configure environment security roles](https://learn.microsoft.com/en-us/power-platform/admin/database-security-configure)
- [Dataverse customization roles](https://learn.microsoft.com/en-us/power-apps/maker/model-driven-apps/privileges-required-customization)
- [Share Standard harness agents](https://learn.microsoft.com/en-us/microsoft-copilot-studio/admin-share-bots)
- [Share GitHub Copilot harness agents](https://learn.microsoft.com/en-us/microsoft-copilot-studio/agents-experience/authoring-share-agent)
- [GitHub Copilot harness billing](https://learn.microsoft.com/en-us/microsoft-copilot-studio/agents-experience/billing-credit-overview)
