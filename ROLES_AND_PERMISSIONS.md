# 실습에 필요한 역할, 라이선스, DLP

이 문서는 이 저장소의 Lab A와 Lab B를 만들고 테스트하고 게시하는 데 필요한
권한만 설명합니다.

사실 확인: 2026-08-09

## 1. 빠른 결론

| 작업 | 필요한 항목 |
| --- | --- |
| Agent, flow, workflow 생성·편집 | 대상 환경의 `Environment Maker` |
| 자신이 소유한 agent 테스트 | `Environment Maker`와 Copilot Studio 접근 권한 |
| Agent 게시 | `Environment Maker` 또는 Co-author, 게시 가능한 라이선스, DLP 허용 |
| 테넌트 DLP 수정 | `Power Platform Administrator` 등 테넌트 관리자 |
| 환경 DLP 수정 | 해당 환경의 `Environment Admin` 또는 Dataverse `System Administrator` |

환경 역할과 테넌트 관리자 역할은 별개입니다. 환경의 `System Administrator`여도
테넌트 수준 DLP 정책은 수정할 수 없습니다.

## 2. 역할

### 환경 역할

| 역할 | 이 실습에서 하는 일 |
| --- | --- |
| `Environment Maker` | Agent, agent flow, workflow, connection 생성·편집 |
| `System Administrator` | Dataverse 환경 관리, 환경 역할 할당, 환경 수준 DLP 관리 |
| `Basic User` | Dataverse 기반 리소스 사용 |

Dataverse가 없는 환경은 `Environment Admin`과 `Environment Maker` 역할을
사용합니다. Dataverse가 있는 환경에서는 `System Administrator`가 환경 관리
역할을 수행할 수 있습니다.

### Agent 공유 역할

| 역할 | 권한 |
| --- | --- |
| Owner | 조회, 편집, 공유, 게시, 삭제 |
| Co-author | 조회, 편집, 구성, 공유, 게시. 삭제는 불가 |
| User | 대화만 가능 |
| Analytics viewer | 해당 agent의 Analytics 읽기 전용 |

Co-author는 대상 환경의 `Environment Maker` 역할도 필요합니다. 공유하는 사용자가
환경 `System Administrator`이면 Copilot Studio에서 역할을 함께 할당할 수 있습니다.

### 테넌트 관리자 역할

테넌트 수준 DLP 정책은 일반 Maker가 수정할 수 없습니다. 최소 권한 관점에서는
`Power Platform Administrator`가 적합합니다. `Global Administrator`와
`Dynamics 365 Administrator`도 Power Platform 관리 작업을 수행할 수 있습니다.

## 3. 라이선스와 과금

역할이 있어도 Copilot Studio 접근 권한과 테넌트의 과금 구성이 필요합니다.

| 항목 | 의미 |
| --- | --- |
| Copilot Studio 사용자 라이선스 또는 author 설정 | Maker의 Copilot Studio 접근 |
| Copilot Studio trial | 생성·test chat 가능, 게시 불가 |
| Copilot Credits | Copilot Studio 사용량의 공통 통화 |
| Prepaid 또는 PAYG | Copilot Credits 구매 방식 |
| Microsoft 365 Copilot | M365 Copilot 안에서 agent를 만들고 사용하는 경로 |

GitHub Copilot harness는 만들기, Preview, 테스트, 평가 단계부터 Copilot Credits를
사용할 수 있습니다. Standard harness는 게시 이후의 사용에 standard harness
라이선스와 요율이 적용됩니다.

정확한 최신 요율은
[Microsoft의 standard harness 라이선스 문서](https://learn.microsoft.com/microsoft-copilot-studio/billing-licensing)와
[GitHub Copilot harness 과금 문서](https://learn.microsoft.com/microsoft-copilot-studio/agents-experience/billing-credit-overview)를
기준으로 확인하세요.

## 4. 작업별 최소 권한

| 작업 | 최소 역할 | 추가 조건 |
| --- | --- | --- |
| Standard agent 생성 | `Environment Maker` | Copilot Studio 접근 권한 |
| Standard agent flow 생성 | `Environment Maker` | Standard harness 라이선스·Copilot Credits |
| GitHub agent/workflow 생성 | `Environment Maker` | Copilot Credits |
| Test 또는 Preview | `Environment Maker` | GitHub harness는 credit 사용 가능 |
| Flow/workflow를 tool로 추가 | `Environment Maker` | 해당 connector가 DLP에서 허용 |
| Agent 게시 | `Environment Maker` 또는 Co-author | Trial 불가, 필요한 채널과 connector가 DLP에서 허용 |
| 테넌트 DLP 변경 | `Power Platform Administrator` 등 | PPAC 접근 |
| 환경 DLP 변경 | `Environment Admin` 또는 `System Administrator` | 테넌트 정책을 완화할 수는 없음 |

## 5. 이 환경의 게시 차단

`Simple Issue Triage Standard`는 Preview에서 agent flow를 정상 호출하지만 Publish
버튼이 비활성화됩니다.

확인된 정책:

| 항목 | 값 |
| --- | --- |
| 정책 이름 | `Personal Developer - (default)` |
| 범위 | 테넌트 수준 정책 |
| 기본 connector 분류 | `Blocked` |
| 차단 connector | `Skills with Copilot Studio` |
| Connector ID | `PvaSkills` |

Microsoft 문서에 따르면 DLP 위반이 있으면 Publish 버튼을 사용할 수 없게 됩니다.
이 환경에서는 agent-to-flow 호출에 필요한 `PvaSkills`가 차단되어 있습니다.

## 6. DLP 심화: 차단된 connector 해제

### 6.1 그룹 이름

<a id="dlp-group-naming"></a>

| PPAC 화면 | 정책 API 값 | 사용 가능 여부 |
| --- | --- | --- |
| Business | `Confidential` | 허용 |
| Non-business | `General` | 허용 |
| Blocked | `Blocked` | 차단 |

Business와 Non-business는 모두 허용 그룹이지만, 서로 다른 그룹의 connector는 같은
agent에서 데이터를 주고받지 못할 수 있습니다. Agent가 함께 사용하는 connector는
같은 허용 그룹에 두세요.

### 6.2 누가 변경할 수 있나

| 정책 범위 | 필요한 역할 |
| --- | --- |
| 테넌트 수준 | `Power Platform Administrator`, `Global Administrator`, 또는 `Dynamics 365 Administrator` |
| 환경 수준 | `Environment Admin` 또는 Dataverse `System Administrator` |

환경 정책은 테넌트 정책보다 더 제한적으로 만들 수 있지만, 테넌트 차단을
덮어써서 허용할 수는 없습니다.

### 6.3 해제 절차

```text
Power Platform 관리 센터
  → Security
  → Data and privacy
  → Data policy
```

1. `Personal Developer - (default)` 정책을 엽니다.
2. 정책이 대상 환경에 적용되는지 확인합니다.
3. **Assign connectors**에서 `Skills with Copilot Studio`를 찾습니다.
4. Agent가 사용하는 다른 connector와 같은 **Business** 또는
   **Non-business** 그룹으로 이동합니다.
5. **Update Policy**로 저장합니다.
6. 정책 반영 후 Copilot Studio를 새로 열고 agent를 다시 게시합니다.

이 정책은 기본 분류가 `Blocked`입니다. `PvaSkills`를 Blocked 목록에서 제거만 하면
미분류 connector로 다시 차단될 수 있으므로 허용 그룹에 명시적으로 넣어야 합니다.

테넌트 전체 정책을 바꾸기 어렵다면:

1. 대상 환경을 테넌트 정책의 제외 목록에 넣습니다.
2. 대상 환경 전용 정책을 만듭니다.
3. 환경 정책에서 `PvaSkills`를 허용 그룹에 둡니다.

### 6.4 확인 방법

정책은 비동기로 반영됩니다. 반영 후 다음을 확인합니다.

1. [`VERIFICATION.md` 5장](VERIFICATION.md#5-dlp-정책-확인)으로 정책을 다시 조회합니다.
2. `PvaSkills`가 `Confidential` 또는 `General`인지 확인합니다.
3. Standard agent의 Publish 버튼이 활성화되는지 확인합니다.
4. 게시 후 새 대화에서 agent flow를 호출합니다.

### 6.5 관리자 요청 템플릿

```text
Environment: Junwoo Jeong
Environment ID: e477cbf2-150c-eee7-a852-b29ac07f541d
Blocking policy: Personal Developer - (default)

Request:
Move "Skills with Copilot Studio" (PvaSkills) from Blocked to the same allowed
data group as the other connectors used by this agent, or exclude this
Developer environment from the tenant policy and apply an environment policy.

Reason:
The Standard harness lab agent calls a deterministic agent flow. Maker Preview
works, but the DLP violation disables Publish.

Scope:
Developer environment only. No production data.
```

## 7. 빠른 문제 해결

| 증상 | 원인 | 조치 |
| --- | --- | --- |
| Publish 버튼 비활성화 | DLP 위반 | Channels의 위반 상세와 PPAC Data policy 확인 |
| `DlpViolationError / BlockedConnector` | Connector가 Blocked | 해당 connector를 허용 그룹으로 이동 |
| 공동 저작자 추가 실패 | Co-author에게 `Environment Maker` 없음 | 환경 역할 할당 |
| Trial에서 게시 불가 | Trial 제한 | 게시 가능한 라이선스 사용 |
| GitHub harness 비용 증가 | 빌드·Preview·테스트도 과금 가능 | Agent Monitor와 PPAC에서 사용량 확인 |

## 8. 공식 문서

- [Choose a harness](https://learn.microsoft.com/microsoft-copilot-studio/harnesses-overview)
- [Licensing for agents powered by the standard harness](https://learn.microsoft.com/microsoft-copilot-studio/billing-licensing)
- [Billing for agents powered by the GitHub Copilot harness](https://learn.microsoft.com/microsoft-copilot-studio/agents-experience/billing-credit-overview)
- [Share agents with other users](https://learn.microsoft.com/microsoft-copilot-studio/admin-share-bots)
- [Configure data policies for agents](https://learn.microsoft.com/microsoft-copilot-studio/admin-data-loss-prevention)
- [Manage Power Platform data policies](https://learn.microsoft.com/power-platform/admin/wp-data-loss-prevention)
- [Use service admin roles](https://learn.microsoft.com/power-platform/admin/use-service-admin-role-manage-tenant)
