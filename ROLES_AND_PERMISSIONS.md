# 개발·운영·관리를 위한 플랫폼별 역할과 권한

Copilot Studio는 단독 제품이 아니라 **Power Platform 위의 애플리케이션**입니다.
따라서 하나의 작업을 끝내려면 여러 포털의 서로 다른 역할이 동시에 필요할 수 있습니다.

이 문서는 "무엇을 하려면 / 어디에서 / 어떤 역할과 라이선스가 필요한가"를 정리합니다.

## 1. 관여하는 플랫폼 지도

| 플랫폼 | URL | 관할 범위 |
| --- | --- | --- |
| **Copilot Studio** | <https://copilotstudio.microsoft.com> | agent/workflow 저작, 게시, 공유, 채널 구성, 테스트, analytics |
| **Power Platform 관리 센터 (PPAC)** | <https://admin.powerplatform.microsoft.com> | 환경, DLP 데이터 정책, capacity·라이선스, PAYG, Managed Environments, 테넌트 설정 |
| **Microsoft 365 관리 센터** | <https://admin.microsoft.com> | 사용자 계정, 라이선스 할당, 관리자 역할 부여, Copilot 설정, Integrated apps |
| **Microsoft Entra 관리 센터** | <https://entra.microsoft.com> | 디렉터리 역할, 보안 그룹, 앱 등록, 조건부 액세스, PIM |
| **Microsoft Teams 관리 센터** | <https://admin.teams.microsoft.com> | Teams 앱 승인("Built for your org"), 앱 설정 정책 |
| **Azure Portal** | <https://portal.azure.com> | PAYG 청구 정책용 구독, Application Insights, Azure RBAC |

> **핵심 원칙**: 테넌트 관리자 역할(Entra)과 환경 보안 역할(Dataverse)은 **별개**입니다.
> Power Platform 관리자여도 자동으로 환경의 System Administrator가 되지는 않습니다.
> 현재는 **self-elevation**을 거쳐야 System Administrator 권한을 얻습니다.

## 2. 역할 카탈로그

### 2.1 테넌트 관리자 역할 (Microsoft Entra ID / M365 관리 센터에서 부여)

| 역할 | Copilot Studio 관점에서 할 수 있는 일 |
| --- | --- |
| **Global Administrator** | 아래 모든 것 + 사용자 생성, 라이선스 추가, 보안 역할 추가 |
| **Power Platform Administrator** | 모든 환경 관리(보안 그룹 멤버십에 **영향받지 않음**), 환경 생성/삭제/백업/복원, capacity 할당, 테넌트·환경 데이터 정책 관리, PPAC의 Copilot 페이지 조회 |
| **Dynamics 365 Administrator** | Power Platform 관리자와 거의 동일. 단 환경에 보안 그룹이 지정되어 있으면 **그 그룹에 포함되어야** 관리 가능 |
| **AI Administrator** | M365 관리 센터의 Copilot 페이지·Copilot 보고서 관리, Microsoft Copilot connector 설정, Copilot Dashboard 위임 |
| **License Administrator** | 라이선스 할당/해제만 가능. 환경·DLP는 불가 |
| **Teams Administrator** | Teams 앱 스토어 "Built for your org" 섹션의 agent 제출 승인/거부 |
| **Privileged Role Administrator** | 위 관리자 역할을 다른 사용자에게 **부여**하는 데 필요 |
| **Application Administrator** / **Cloud Application Administrator** | agent 수동 인증용 Entra 앱 등록 관리 |
| **Global Reader** | 모든 관리 설정 읽기 전용 |

**Power Platform 관리자와 Dynamics 365 관리자가 할 수 없는 것**:
사용자 계정 관리, 구독 관리, Exchange/SharePoint 등 M365 앱 설정 접근.

> 서비스 관리자 역할은 **사용자에게 직접 할당**해야 합니다.
> 보안 그룹을 통한 상속은 완전히 지원되지 않습니다.

### 2.2 환경 보안 역할 (Dataverse)

| 역할 | 범위 | 할 수 있는 일 |
| --- | --- | --- |
| **System Administrator** | 환경 1개 | 전체 관리 + 데이터 접근. 보안 역할 생성/수정/할당. 환경 수준 DLP 정책 생성 |
| **System Customizer** | 환경 1개 | 테이블·폼 등 커스터마이징. solution 가져오기 |
| **Environment Maker** | 환경 1개 | agent, flow, 연결, 커스텀 API 생성. **agent 공동 저작에 필수** |
| **Basic User** | 환경 1개 | 앱 실행 및 데이터 상호작용 |
| **Bot Transcript Viewer** | 환경 1개 | 대화 transcript(세션 상세) 접근 |

Dataverse가 없는 환경에서는 **Environment Admin** / **Environment Maker** 두 가지만 존재합니다.

### 2.3 Copilot Studio 내부의 공유 역할 (agent 단위)

| 역할 | 부여 위치 | 할 수 있는 일 |
| --- | --- | --- |
| **Co-author (공동 저작자)** | Copilot Studio → agent → **Share** | 조회, 편집, 구성, 공유, 게시. **삭제는 불가** |
| **User (대화만)** | Copilot Studio → agent → **Share** | 대화만 가능. 저작 불가 |
| **Analytics viewer** | Copilot Studio → agent → **Share** → **Analytics viewer** | 해당 agent의 **Analytics 페이지 읽기 전용**. 편집·공유·게시 불가. **개인에게만 부여 가능(그룹 불가)** |

핵심 규칙 3가지:

1. agent는 **Copilot Studio 사용자별 라이선스가 있는 사용자에게만** 공유할 수 있습니다.
2. 공동 저작자는 **Environment Maker** Dataverse 역할이 있어야 합니다.
   상대가 없으면, 공유하는 쪽이 **System Administrator**여야 Copilot Studio가 대신 부여합니다.
3. 환경에서 agent와 대화하려면 **ChatBotReaders** 권한이 필요합니다.
   `Environment Maker` 역할에 이 권한이 포함되어 있어 공유 시 자동 할당됩니다.
   관리자는 ChatBotReaders 권한만 가진 **커스텀 보안 역할**을 만들어 미리 부여할 수도 있습니다.

> Analytics viewer로 지표는 볼 수 있지만 **세션 단위 데이터와 transcript는 볼 수 없습니다.**
> 그건 환경 수준의 `Bot Transcript Viewer` 보안 역할이 따로 필요합니다.

### 2.4 라이선스/엔타이틀먼트 (역할과 별개)

| 항목 | 필요한 상황 |
| --- | --- |
| **Copilot Studio 사용자별 라이선스** | agent 저작, agent 공유 대상 |
| **Copilot Studio 평가판** | 생성·테스트는 가능, **게시 불가**. 만료 후 90일간 agent는 계속 동작 |
| **Copilot Studio for Teams** (일부 M365 구독 포함) | classic orchestration + Teams 게시만. generative orchestration, 프리미엄 connector, 임의 채널 게시 불가 |
| **Microsoft 365 Copilot USL** | Copilot chat harness, M365 Copilot 확장 |
| **Copilot Credits (선불 또는 PAYG)** | GitHub Copilot harness의 모든 사용 |
| **Azure 구독** | PAYG 청구 정책 생성 |

## 3. 작업 → 필요 권한 매트릭스

### 3.1 개발 (Maker)

| # | 작업 | 플랫폼 | 최소 역할 | 라이선스 |
| --- | --- | --- | --- | --- |
| 1 | Standard harness agent 생성 | Copilot Studio | Environment Maker | Copilot Studio 사용자 라이선스 |
| 2 | GitHub Copilot harness agent/workflow 생성 | Copilot Studio | Environment Maker | Copilot Credits (**생성 시점부터 과금**) |
| 3 | Agent flow 생성 | Copilot Studio | Environment Maker | Copilot Studio capacity |
| 4 | 기존 agent 편집 | Copilot Studio | Environment Maker 또는 해당 agent의 Co-author | 위와 동일 |
| 5 | Test chat 실행 | Copilot Studio | Environment Maker | 평가판으로도 가능 |
| 6 | Connector를 tool로 추가 | Copilot Studio | Environment Maker | 프리미엄 connector는 해당 라이선스. **DLP 허용 필요** |
| 7 | MCP 서버 연결 | Copilot Studio | Environment Maker | Copilot Studio 라이선스. DLP·connector 정책 적용 |
| 8 | REST API tool 추가 | Copilot Studio | Environment Maker | `HTTP` connector가 DLP에서 허용되어야 함 |
| 9 | Knowledge source 추가 | Copilot Studio | Environment Maker | 소스별 DLP 가상 connector 허용 필요 |
| 10 | Agent 인증을 수동(Entra 앱)으로 구성 | Copilot Studio + Entra | Environment Maker + **Application Administrator**(앱 등록 시) | — |
| 11 | Agent 게시 | Copilot Studio | Environment Maker / Co-author | 정식 라이선스 (**평가판 불가**) + 대상 채널 DLP 허용 |
| 12 | Solution 내보내기 | Copilot Studio / Power Apps | Environment Maker 또는 System Customizer | — |
| 13 | Solution 가져오기 | 대상 환경 | System Customizer 이상 | — |

### 3.2 운영 (Operator)

| # | 작업 | 플랫폼 | 최소 역할 | 비고 |
| --- | --- | --- | --- | --- |
| 14 | agent와 대화 | 채널 | `ChatBotReaders` 권한 (보통 Environment Maker로 부여) | 공유 대상은 Copilot Studio 사용자 라이선스 필요 |
| 15 | Analytics 지표 조회 | Copilot Studio | Analytics viewer (agent 단위) | 개인에게만 부여 가능 |
| 16 | 세션 상세·transcript 조회 | Copilot Studio | Analytics viewer + **Bot Transcript Viewer** (환경 수준) | PPAC에서 부여 |
| 17 | Copilot Credits 사용량 조회 (agent 단위) | Copilot Studio → **Monitor** | Co-author / Owner | GitHub Copilot harness |
| 18 | 환경·테넌트 전체 capacity 조회 | PPAC → Licensing → Copilot Studio | Power Platform Admin / Dynamics 365 Admin / Global Admin | 테넌트 설정에 따라 환경 관리자에게 허용 가능 |
| 19 | Flow 실행 기록 확인 | Copilot Studio → flow 상세 | Environment Maker (flow 소유자) | — |
| 20 | Application Insights 텔레메트리 확인 | Azure Portal | Azure `Reader` 이상 | DLP에서 `Application Insights in Copilot Studio` 허용 필요 |
| 21 | Evaluation(품질 평가) 실행 | Copilot Studio | Environment Maker | 인증 계정 기반 자동 평가는 `Microsoft Copilot Studio` connector 허용 필요 |

### 3.3 관리·거버넌스 (Admin)

| # | 작업 | 플랫폼 | 최소 역할 | 비고 |
| --- | --- | --- | --- | --- |
| 22 | 환경 생성/삭제/백업 | PPAC | Power Platform Admin / Global Admin / Dynamics 365 Admin | Dynamics 365 Admin은 보안 그룹 멤버십 영향을 받음 |
| 23 | 환경 보안 역할 할당 | PPAC 또는 Dataverse | 해당 환경의 **System Administrator** | 테넌트 관리자는 self-elevation 필요 |
| 24 | **테넌트 수준 DLP 정책 생성/수정** | PPAC → Security → Data and privacy → Data policy | Power Platform Admin / Global Admin / Dynamics 365 Admin | — |
| 25 | **환경 수준 DLP 정책 생성/수정** | PPAC | 해당 환경의 System Administrator (또는 Environment Admin) | 다른 환경에는 영향 없음 |
| 26 | 차단된 connector 해제 / 환경 예외 추가 | PPAC → Data policy → Edit policy | 위 24·25와 동일 | 상세는 6장 참고 |
| 27 | Copilot Studio capacity를 환경에 할당 | PPAC → Licensing → Copilot Studio | Power Platform Admin / Global Admin | 선불 capacity 보유 필요 |
| 28 | agent별 Copilot Credit 한도 설정 | PPAC → Licensing → Copilot Studio | Power Platform Admin / Global Admin | 월 한도, 하드 스톱, 알림 |
| 29 | PAYG(종량제) 청구 정책 생성 | PPAC + Azure | PPAC 측 관리자 역할 + **Azure 구독의 Contributor 또는 Owner** | Azure 구독 필수 |
| 30 | Managed Environment 활성화 | PPAC | Power Platform Admin / Global Admin | 독립형 라이선스에 포함 |
| 31 | 테넌트 설정 변경 (agent 생성 허용 대상 등) | PPAC → Tenant settings | Power Platform Admin / Global Admin / Dynamics 365 Admin | `Copilot Studio authors` 보안 그룹 지정 포함 |
| 32 | Copilot Studio 라이선스 할당 | M365 관리 센터 | License Administrator / Global Admin | — |
| 33 | 관리자 역할 부여 | M365 관리 센터 → Users → Manage roles | **Privileged Role Administrator** | 서비스 관리자 역할은 직접 할당 필요 |
| 34 | Teams 앱 스토어 게시 승인 | Teams 관리 센터 → Manage apps | **Teams Administrator** | "Built for your org" 섹션 |
| 35 | M365 Copilot 설정·보고서 관리 | M365 관리 센터 → Copilot | **AI Administrator** | Copilot chat harness 관련 |
| 36 | Entra 앱 등록 (agent 인증용) | Entra 관리 센터 | Application Administrator / Cloud Application Administrator | — |
| 37 | Power Platform Pipelines 구성 | PPAC / Pipelines 앱 | 호스트 환경의 System Administrator | 커스텀 호스트는 Managed Environments 필요 |
| 38 | 셀프서비스 평가판 가입 차단 | M365 관리 센터 / PowerShell | Global Administrator | `AllowAdHocSubscriptions` |

## 4. 페르소나별 권장 역할 번들 (최소 권한 우선)

### A. 개발자 / Maker

```text
필수
├── Copilot Studio 사용자 라이선스        (M365 관리 센터에서 할당)
└── Environment Maker (Dataverse 보안 역할) (대상 환경, System Admin이 부여)

상황별
├── Application Administrator (Entra)     → 수동 인증용 앱 등록이 필요할 때
└── System Customizer                     → solution 가져오기가 필요할 때
```

가능한 일: agent/workflow/agent flow 생성·편집·테스트·게시, tool 추가, 공유, 자기 agent의 analytics 조회.

### B. 운영자 / Operator

```text
필수
├── Copilot Studio 사용자 라이선스
├── Basic User 또는 ChatBotReaders 권한을 가진 커스텀 역할
└── Analytics viewer (agent 단위, agent 소유자가 부여)

상황별
├── Bot Transcript Viewer (환경 수준)     → 세션 상세·transcript 조회
├── Power Platform Administrator          → 테넌트 전체 capacity 모니터링
└── Azure Reader                          → Application Insights 조회
```

> 운영자에게 Environment Maker를 통째로 주는 것은 과다 권한입니다.
> `ChatBotReaders` 권한만 가진 커스텀 보안 역할 + `Analytics viewer` 조합을 권장합니다.

### C. 관리자 / Admin

```text
필수
├── Power Platform Administrator (Entra)  → 환경, DLP, capacity, 테넌트 설정
└── System Administrator (환경별)          → self-elevation 후 보안 역할 관리

상황별
├── Azure Contributor/Owner (구독)        → PAYG 청구 정책
├── Teams Administrator                   → Teams 앱 승인
├── AI Administrator                      → M365 Copilot 설정·보고서
├── Application Administrator             → Entra 앱 등록
└── License Administrator                 → 라이선스 할당
```

> **Global Administrator는 위 전부를 포함하지만 최소 권한 원칙에 위배됩니다.**
> `Power Platform Administrator` + 필요한 범위의 개별 역할 조합을 권장하고,
> 고권한 역할은 Entra PIM으로 시간 제한 활성화하세요.

## 5. Harness별 권한·라이선스 차이

| 항목 | GitHub Copilot harness | Standard harness | Copilot chat harness |
| --- | --- | --- | --- |
| 저작에 필요한 환경 역할 | Environment Maker | Environment Maker | Environment Maker |
| 필요한 엔타이틀먼트 | Copilot Credits (선불/PAYG) | Copilot Studio 라이선스 + capacity | M365 Copilot USL 또는 소비 기반 |
| **과금 시작** | **빌드·테스트·평가 시점부터** | 게시 이후 | 게시 이후 |
| 평가판 | 생성·테스트 가능, 게시 불가 | 생성·테스트 가능, 게시 불가 | M365 Copilot 라이선스 필요 |
| Credit 한도 통제 | PPAC에서 agent 단위 설정 가능 | capacity 소진 시 실행 차단 | 해당 없음 |
| 게시 대상 | 내부/외부 | 내부/외부 | 내부 전용 |
| DLP 적용 | 공통 적용 | 공통 적용 | 공통 적용 |

> 실무상 가장 큰 차이는 **GitHub Copilot harness는 만들고 테스트하는 것만으로 과금**된다는 점입니다.
> 실습·PoC 환경에는 agent 단위 credit 한도를 먼저 설정하세요.

## 6. DLP 심화: 차단된 connector 해제

이 저장소 실습에서 실제로 발생한 차단 사례를 기준으로 정리합니다.

### 6.1 증상

Standard harness agent를 게시할 때 다음 오류가 발생합니다.

```text
DlpViolationError / BlockedConnector
```

원인: agent가 agent flow를 tool로 호출하기 위해 **skill 메커니즘**을 사용하는데,
DLP 정책이 `Skills with Copilot Studio` connector를 **Blocked** 그룹에 넣어 두었기 때문입니다.

> 정확한 connector 이름은 `Skills`가 아니라 **`Skills with Copilot Studio`** 입니다.
> PPAC에서 검색할 때 이 이름을 그대로 사용하세요.

### 6.2 누가 해제할 수 있나

| 차단 위치 | 필요한 역할 |
| --- | --- |
| 테넌트 수준 정책 | Power Platform Administrator / Global Administrator / Dynamics 365 Administrator |
| 환경 수준 정책 | 해당 환경의 System Administrator (Dataverse 없는 환경은 Environment Admin) |

> 환경의 Dataverse `System Administrator`만으로는 **테넌트 수준 DLP를 변경할 수 없습니다.**
> Copilot Studio 안에 우회 수단도 없습니다.

### 6.3 해제 절차

**PPAC 접근 경로**

```text
Power Platform 관리 센터
└── Security
    └── Data and privacy
        └── Data policy
```

**방법 A — 정책에서 connector를 허용 그룹으로 이동**

1. Power Platform 관리자로 PPAC에 로그인합니다.
2. **Security → Data and privacy → Data policy**로 이동합니다.
3. 차단 중인 정책을 찾습니다. **테넌트 수준 정책부터** 확인하세요.
4. 정책을 선택하고 **Edit Policy**를 누릅니다.
5. **Assign connectors** 페이지에서 `Skills with Copilot Studio`를 검색합니다.
6. 해당 connector를 **Business** 또는 **Non-business**로 이동합니다.
   이때 **agent가 사용하는 다른 connector와 같은 그룹**에 두어야 합니다.
7. 마법사를 끝까지 진행하고 **Update Policy**로 저장합니다.

**방법 B — 환경 예외 적용**

테넌트 정책을 바꿀 수 없다면 대상 환경만 정책 범위에서 제외합니다.

1. 차단 중인 테넌트 정책의 환경 범위에서 대상 환경을 **제외 목록**으로 옮깁니다.
2. 그 환경 전용 환경 수준 정책을 만들고 `Skills with Copilot Studio`를 허용 그룹에 둡니다.

> 환경 수준 정책은 테넌트 수준 차단을 **덮어쓰지 못합니다.**
> 반드시 테넌트 정책에서 환경을 제외한 뒤 환경 정책으로 통제해야 합니다.

**방법 C — 데이터 그룹 정합성 확인**

차단 그룹에 없더라도, agent가 쓰는 connector들이 **서로 다른 데이터 그룹**에 흩어져 있으면
그룹 간 데이터 공유가 거부됩니다. 사용 중인 connector를 모두 같은 그룹으로 맞추세요.

### 6.4 반영 시간

정책 변경은 비동기로 전파됩니다.

```text
정책 저장 → 환경으로 전파 → 환경이 모든 agent 재평가
→ 위반 agent 일시 중지 → 연결 비활성화
```

일반적으로 **1시간 이내**, 대규모 테넌트에서는 **최대 24시간**까지 걸릴 수 있습니다.

### 6.5 Copilot Studio DLP 가상 connector 전체 목록

| 차단하려는 동작 | PPAC의 connector 이름 |
| --- | --- |
| skill 사용 (agent → flow 호출) | `Skills with Copilot Studio` |
| 인증 없는 agent 게시 | `Chat without Microsoft Entra ID authentication in Copilot Studio` |
| HTTP 요청 사용 | `HTTP` (엔드포인트 필터링 지원) |
| 문서 knowledge source | `Knowledge source with documents in Copilot Studio` |
| 공개 웹사이트 knowledge source | `Knowledge source with public websites and data in Copilot Studio` |
| SharePoint/OneDrive knowledge source | `Knowledge source with SharePoint and OneDrive in Copilot Studio` |
| Demo/커스텀 웹사이트·모바일 앱 게시 | `Direct Line channels in Copilot Studio` |
| Teams 및 M365 채널 게시 | `Microsoft Teams + Microsoft 365 Channel in Copilot Studio` |
| Facebook 채널 게시 | `Facebook channel in Copilot Studio` |
| SharePoint 채널 게시 | `SharePoint channel in Copilot Studio` |
| WhatsApp 채널 게시 | `WhatsApp channel in Copilot Studio` |
| Dynamics 365 Customer Service 채널 게시 | `Omnichannel in Copilot Studio` |
| Application Insights 연동 | `Application Insights in Copilot Studio` |
| event trigger·인증 기반 자동 평가 | `Microsoft Copilot Studio` |

> 어떤 채널도 허용되지 않으면 agent를 **아예 게시할 수 없습니다.**
> Direct Line 채널은 기본적으로 허용되어 있습니다.

### 6.6 관리자 요청 템플릿

```text
Environment: <환경 이름>
Environment ID: <환경 ID>
Request: Allow the "Skills with Copilot Studio" connector for agent-to-flow calls,
         or exclude this environment from the blocking tenant DLP policy
         and govern it with a dedicated environment-level policy.
Business purpose: <용도. 예: deterministic GitHub issue triage; no external connectors>
Scope: This environment only. No production data is involved.
```

## 7. 트러블슈팅 빠른 참조

| 증상 | 유력한 원인 | 확인 위치 |
| --- | --- | --- |
| `DlpViolationError / BlockedConnector` | DLP가 connector 차단 | PPAC → Data policy |
| 게시 버튼은 되는데 채널이 안 보임 | 채널 connector가 DLP에서 차단 | PPAC → Data policy |
| agent 공유가 안 됨 | 상대에게 Copilot Studio 사용자 라이선스 없음 | M365 관리 센터 → 라이선스 |
| 공동 저작자 초대 실패 | 본인이 System Administrator가 아님 | PPAC → 환경 → 사용자 |
| 공유했는데 대화가 안 됨 | `ChatBotReaders` 권한 없음 | 환경 보안 역할 |
| Analytics는 보이는데 transcript가 없음 | `Bot Transcript Viewer` 역할 없음 | PPAC → 환경 → 보안 역할 |
| 평가판인데 게시 불가 | 평가판은 **게시 불가** | 라이선스 |
| Flow 실행이 갑자기 차단됨 | Copilot Studio capacity 소진 | PPAC → Licensing → Copilot Studio |
| GitHub harness 비용이 예상보다 큼 | **빌드·테스트도 과금됨** | Copilot Studio → Monitor |
| 관리자인데 환경이 안 보임 | Dynamics 365 Admin이 환경 보안 그룹 미포함 | Entra 보안 그룹 |
| PPAC 관리자인데 보안 역할 할당 불가 | System Administrator self-elevation 미수행 | PPAC → 환경 |

## 8. 참고 문서

- [Use service admin roles to manage your tenant](https://learn.microsoft.com/power-platform/admin/use-service-admin-role-manage-tenant)
- [Role-based security roles for Dataverse](https://learn.microsoft.com/power-platform/admin/database-security)
- [Share agents with other users](https://learn.microsoft.com/microsoft-copilot-studio/admin-share-bots)
- [Configure data policies for agents](https://learn.microsoft.com/microsoft-copilot-studio/admin-data-loss-prevention)
- [Data loss prevention policies](https://learn.microsoft.com/power-platform/admin/wp-data-loss-prevention)
- [Connector classification](https://learn.microsoft.com/power-platform/admin/dlp-connector-classification)
- [Get access to Copilot Studio](https://learn.microsoft.com/microsoft-copilot-studio/requirements-licensing-subscriptions)
- [Assign licenses and manage access](https://learn.microsoft.com/microsoft-copilot-studio/requirements-licensing)
- [Manage Copilot Studio capacity](https://learn.microsoft.com/power-platform/admin/manage-copilot-studio-messages-capacity)
- [Billing for the GitHub Copilot harness](https://learn.microsoft.com/microsoft-copilot-studio/agents-experience/billing-credit-overview)
- [Manage high privileged admin roles with PIM](https://learn.microsoft.com/power-platform/admin/manage-high-privileged-admin-roles)
