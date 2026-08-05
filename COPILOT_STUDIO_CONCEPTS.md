# Copilot Studio 개념 및 기능 정리

Microsoft Copilot Studio의 전반적인 개념, 구성 요소, 기능을 한 문서로 정리했습니다.
실습([`PORTAL_CREATION_GUIDE.md`](PORTAL_CREATION_GUIDE.md))에 들어가기 전에 읽으면 좋습니다.

## 1. Copilot Studio란

**AI agent와 workflow를 만들고 관리하는 그래픽 기반 로우코드 스튜디오**입니다.

- 접속: <https://copilotstudio.microsoft.com>
- agent 생성·관리와 workflow 생성·관리가 **하나의 스튜디오**에 통합되어 있습니다.
- 로우코드지만 프로 개발자가 필요로 하는 깊이(Power Fx, REST API, MCP, 커스텀 connector)도 제공합니다.
- Power Platform 위에서 동작하므로 **환경(environment), Dataverse, solution, DLP** 개념을 그대로 상속합니다.

이 마지막 항목이 중요합니다. Copilot Studio를 "채팅봇 도구"로만 이해하면
권한·거버넌스·배포에서 반드시 막힙니다. 실제로는 **Power Platform 애플리케이션**입니다.

## 2. 무엇을 만들 수 있나

세 가지 빌딩 블록이 있고, 서로를 호출할 수 있습니다.

| 빌딩 블록 | 정의 | 성격 |
| --- | --- | --- |
| **Agent** | 대화를 처리하고 작업을 수행하는 AI 어시스턴트 | 비결정론적, 추론 기반 |
| **Workflow** | GitHub Copilot harness의 자동화. 재설계된 시각적 캔버스, 네이티브 AI action, agent handoff, node 단위 테스트 | 결정론적 경로 + AI 단계 |
| **Agent flow** | Copilot Studio 네이티브의 기존 flow 형식. Power Automate와 유사한 저작 경험 | 결정론적 |

조합 예: workflow가 중간 단계에서 agent를 호출하거나, agent가 workflow를 tool로 호출합니다.

## 3. Harness

만든 것이 실제로 실행되는 **런타임**입니다. 현재 세 가지가 있습니다.

| Harness | 산출물 | 성격 | 과금 |
| --- | --- | --- | --- |
| GitHub Copilot harness | agent, workflow | 추론 중심, 다단계, 파일 처리, skills/memory | Copilot Credits |
| Standard harness | agent, agent flow | 규칙 기반, 예측 가능 | Copilot Studio capacity |
| Copilot chat harness | agent | M365 Copilot Chat 확장 | 소비 기반 또는 M365 Copilot USL 포함 |

상세 비교는 [`HARNESS_COMPARISON.md`](HARNESS_COMPARISON.md)를 참고하세요.

## 4. Agent의 구성 요소

agent 하나는 다음 요소로 이루어집니다.

```text
Agent
├── Instructions   행동 지침 · 페르소나 (자연어)
├── Knowledge      근거 데이터 (grounding)
├── Tools          외부 시스템에 대한 동작
├── Topics         정해진 대화 흐름 (standard harness)
├── Skills         재사용 가능한 작업별 지침 (GitHub Copilot harness)
├── Memory         대화 간 컨텍스트 유지 (GitHub Copilot harness)
├── Triggers       사람 없이 시작되는 이벤트
└── Channels       사용자가 만나는 접점
```

### 4.1 Instructions

agent의 전반적 행동과 성격을 정의합니다. GitHub Copilot harness에서는
instruction이 곧 오케스트레이션의 기준이 되므로 품질 영향이 가장 큽니다.

### 4.2 Topics (standard harness)

**topic**은 직접 설계하는 대화의 한 조각입니다. 노드(질문, 조건, 메시지, action)를 연결해 만듭니다.

- **Trigger phrases**: 어떤 발화가 이 topic을 여는지 정의합니다.
- **System topics**: `Conversation Start`, `Fallback`, `Conversational boosting` 등 기본 제공 topic.
- classic orchestration에서는 agent가 **topic으로만** 응답합니다.

### 4.3 Knowledge (grounding)

agent가 답변의 근거로 사용하는 데이터입니다.

| 소스 | 위치 | 인증 |
| --- | --- | --- |
| Public website | 외부 | 없음 (Bing 검색 후 지정 사이트 결과만 반환) |
| Documents | 내부 (Dataverse 업로드) | 없음 |
| SharePoint | 내부 | 사용자의 Entra ID 인증 |
| Dataverse | 내부 | 사용자의 Entra ID 인증 |
| Microsoft Copilot connector 기반 엔터프라이즈 데이터 | 내부 | 사용자의 Entra ID 인증 |

핵심 설정 두 가지:

- **Allow ungrounded responses**: 끄면 knowledge/tool을 쓰지 않은 턴의 응답을 차단합니다.
  단, 모델이 knowledge 결과와 일반 지식을 섞는 것까지 막지는 못합니다.
- 인증 기반 소스는 **질문한 사용자가 접근 가능한 콘텐츠만** 노출합니다.

> 근거 인용(citation)이 없으면 답변이 보류될 수 있습니다.
> "항상 출처를 인용하라"는 instruction을 넣고, JSON 강제 같은 경직된 출력 형식은 피하세요.

### 4.4 Tools

agent가 외부 시스템과 상호작용하는 수단입니다.

| Tool 종류 | 설명 |
| --- | --- |
| **Connector** | Power Platform connector로 API·서비스 연결 (기본 제공 / 커스텀) |
| **Agent flow / Workflow** | 결정론적 자동화를 호출하고 결과를 되돌려 받음 |
| **Prompt** | 단일 턴 모델 프롬프트. knowledge 참조와 데이터 분석 코드 생성 가능 |
| **REST API** | 엔드포인트와 메서드를 tool로 등록 |
| **MCP (Model Context Protocol)** | MCP 서버의 tool과 resource 사용 |
| **Computer use** | GUI가 있는 웹사이트·데스크톱 앱을 화면 조작으로 사용 |
| **Azure Bot Service skills** | Bot Service를 통해 노출된 tool 묶음 |
| **Client tools** | 클라이언트에 event를 보내 동작을 수행시키고 응답을 받음 |

Tool 설정에서 중요한 항목:

- **Description**: generative orchestration이 tool 선택 근거로 사용합니다. 가장 중요한 필드입니다.
- **Allow agent to decide dynamically when to use the tool**: 끄면 topic에서 명시 호출할 때만 실행됩니다.
- **Ask the end user before running**: 실행 전 사용자 확인 (기본 No).
- **Authentication**: `End user` 자격 증명 vs `Maker-provided` 자격 증명.
- **Inputs → Fill using**: 기본값 `Dynamically fill with AI`. `Custom value`로 고정할 수 있습니다.
- **Completion → After running**: 미응답 / 생성 응답 / 지정 응답 / adaptive card.

한도: generative orchestration은 agent당 최대 **128개** tool.
권장은 **25~30개 이하**입니다. child agent는 자체 orchestration으로 각각 128개를 가집니다.

### 4.5 Skills와 Memory (GitHub Copilot harness)

- **Skill**: 이름 + 설명 + Markdown 지침으로 구성된 재사용 가능한 능력.
  agent의 "모드" 또는 "역할"에 가깝습니다. `SKILL.md` + 부속 파일을 ZIP 패키지로 내보내고
  다른 agent에서 재사용할 수 있습니다.
- **Memory**: 대화를 넘어 컨텍스트를 유지합니다.

| 구성 요소 | 목적 | 관리 대상 |
| --- | --- | --- |
| Instructions | 전반적 행동과 성격 | identity 설정 |
| Knowledge | 참조 데이터 | knowledge source |
| Tools | 외부 서비스를 통한 동작 | connector, API, MCP |
| Skills | 재사용 가능한 작업별 능력 | Markdown 기반 skill 파일/패키지 |

> 여기서 말하는 skill은 standard harness의 **Bot Framework skill**과 다른 개념입니다.
> DLP connector 이름 `Skills with Copilot Studio`는 **Bot Framework skill 쪽**을 가리킵니다.

## 5. Orchestration

요청이 들어왔을 때 무엇으로 응답할지 결정하는 방식입니다.

### Classic orchestration

- topic만으로 응답합니다. 자연어 이해로 발화를 topic에 매칭합니다.
- topic 안에서 tool을 명시적으로 호출할 수 있습니다.
- knowledge 소스 개수에 제한이 있습니다 (SharePoint URL 4개, 웹사이트 4개, Dataverse 소스 2개 등).
- **동작이 예측 가능**하고 비용이 통제됩니다.

### Generative orchestration

- 모델이 topic, tool, knowledge 중 **무엇을 어떤 순서로 쓸지 스스로 결정**합니다.
- tool 입력 수집 질문도 자동 생성합니다. 질문 노드를 직접 만들 필요가 없습니다.
- knowledge 소스가 25개를 넘으면 내부 GPT 모델이 필터링합니다.
- custom data source와 Bing Custom Search는 지원하지 않습니다
  (필요하면 topic의 generative answers 노드 안에 넣어야 합니다).

선택 기준: **감사 가능성과 재현성이 최우선이면 classic**, **커버리지와 유연성이 최우선이면 generative**.

## 6. Multi-agent

agent 하나로 모든 것을 처리하지 않습니다.

| 방식 | 설명 |
| --- | --- |
| **Child agent** | 같은 솔루션 안에서 관리되는 하위 agent. 자체 orchestration과 tool 보유 |
| **Connected agent** | 다른 팀·조직이 소유하는 독립 agent에 위임 |
| **A2A (Agent2Agent) 프로토콜** | 개방 표준으로 외부 agent와 연동 |
| **Handoff** | 다른 agent 또는 사람 상담원에게 대화를 넘김 |

주의점: connected agent는 **권한과 knowledge 범위가 다를 수 있습니다.**
연결된 agent 전체를 하나의 신뢰 경계로 보고 거버넌스와 감사 통제를 적용해야 합니다.
부모 orchestrator에는 언제 위임할지 명확한 기준을 기술하세요.

## 7. Autonomous agent와 trigger

사용자 프롬프트를 기다리지 않고 동작하는 agent입니다.

- 이벤트를 감지하고 판단하여 작업을 실행합니다.
- 데이터 모니터링, 이벤트 분류, 후속 조치 개시 같은 상시 업무에 적합합니다.
- 범위가 지정된 권한, 명시적 의사결정 경계, 감사 가능한 프로세스 안에서만 동작합니다.

generative orchestration의 커스텀 trigger 예: **On Plan Complete**
(계획이 모두 실행되고 응답이 전달된 뒤 발생. 종료 topic이나 설문으로 연결할 때 사용)

> DLP에서 `Microsoft Copilot Studio` connector를 차단하면 **event trigger 사용과
> 인증 계정 기반 자동 평가가 모두 막힙니다.**

## 8. 채널과 게시

### 게시 개념

- 게시는 **연결된 모든 채널에 일괄 적용**됩니다.
- 최소 한 개 채널에 게시한 뒤 다른 채널을 추가할 수 있습니다.
- 변경 후 다시 게시하지 않으면 사용자는 이전 버전을 계속 사용합니다.
- 진행 중인 대화를 방해하지 않기 위해 **새 세션부터** 최신 콘텐츠가 적용됩니다.
  대부분 채널에서 30분 무활동 시 세션이 종료됩니다. Teams처럼 대화가 지속되는 채널에서는
  `start over`를 입력해 즉시 새 세션을 시작할 수 있습니다.

### 채널 목록

Teams 및 Microsoft 365 Copilot, SharePoint, WhatsApp, Demo Website, Custom Website,
Mobile App, Facebook, Azure Bot Service 채널(Slack, Telegram, Twilio, Email 등).

### 인증

| 옵션 | 설명 |
| --- | --- |
| **Authenticate with Microsoft** (기본) | Teams, Power Apps, M365 Copilot에서 Entra ID 인증 자동 적용 |
| **Authenticate manually** | 다른 채널에서 인증을 유지하려는 경우. Entra 앱 등록 필요 |
| **No authentication** | 링크를 가진 누구나 대화 가능. **tool에 사용자 자격 증명을 쓸 수 없음** |

> **Test chat vs Demo website**
> Test chat(**Test agent** 패널)은 빌드 중 검증용이고,
> Demo website는 팀·이해관계자 피드백 수집용입니다. **운영용이 아닙니다.**

## 9. 운영과 모니터링

| 기능 | 설명 |
| --- | --- |
| **Analytics** | 성능 모니터링, 커스텀 지표 추적, 세션 결과 분석 |
| **Monitor** (GitHub Copilot harness) | agent가 소모한 Copilot Credits 확인 |
| **Evaluations** | 테스트 세트와 공용 grader 라이브러리로 게시 전후 품질 검증 |
| **Transcripts** | 대화 기록. Dataverse에 저장되며 `Bot Transcript Viewer` 역할로 접근 |
| **Agent inventory** | 조직 전체 agent 목록·보안·관리 |
| **Application Insights** | 텔레메트리 연동 (DLP connector로 차단 가능) |

## 10. 거버넌스

Copilot Studio 거버넌스는 대부분 **Power Platform 관리 센터(PPAC)** 에서 수행됩니다.

| 통제 수단 | 대상 |
| --- | --- |
| **Data policy (DLP)** | connector 및 Copilot Studio 가상 connector를 Business / Non-business / Blocked로 분류 |
| **Managed Environments** | 환경 단위 거버넌스 기능 활성화 |
| **Tenant settings** | agent 생성 가능 대상, 환경 생성 권한, Copilot Studio authors 그룹 |
| **Capacity 관리** | 환경별 capacity 할당, agent별 credit 한도 |
| **Endpoint filtering** | HTTP, 공개 웹사이트, SharePoint knowledge의 엔드포인트 허용/차단 |

Copilot Studio 전용 DLP 가상 connector 예:

| 차단하려는 동작 | Connector 이름 |
| --- | --- |
| skill 사용 (agent-to-flow 호출) | `Skills with Copilot Studio` |
| 인증 없는 agent 게시 | `Chat without Microsoft Entra ID authentication in Copilot Studio` |
| Teams/M365 채널 게시 | `Microsoft Teams + Microsoft 365 Channel in Copilot Studio` |
| Demo/커스텀 웹사이트 등 게시 | `Direct Line channels in Copilot Studio` |
| event trigger 및 인증 기반 자동 평가 | `Microsoft Copilot Studio` |
| Application Insights 연동 | `Application Insights in Copilot Studio` |

> 2019년 이후 도입된 connector는 대개 기본 그룹인 **Non-business**에 들어갑니다.
> 많은 조직이 Non-business를 자동 차단하므로, 원인 불명의 차단이 생기면
> **해당 connector가 어느 데이터 그룹에 있는지부터** 확인하세요.

전체 역할·권한 정리는 [`ROLES_AND_PERMISSIONS.md`](ROLES_AND_PERMISSIONS.md)를 참고하세요.

## 11. ALM (개발 → 운영 이행)

- agent flow와 agent는 **solution**에 포함됩니다. solution 안에서 draft, 버전 관리,
  내보내기/가져오기, 커스터마이징이 가능합니다.
- 환경 분리(dev / test / prod)와 **Power Platform Pipelines**로 배포를 자동화합니다.
- Power Automate cloud flow는 agent flow로 **일방향 변환**이 가능합니다
  (과금이 Power Automate에서 Copilot Studio로 바뀌므로 되돌릴 수 없습니다).

## 12. Capacity와 과금 요약

| harness | 과금 단위 | 과금 시작 |
| --- | --- | --- |
| GitHub Copilot | Copilot Credits (LLM 토큰 + tool + harness) | **빌드 시작 시점** |
| Standard | Copilot Studio capacity | **게시 이후** |
| Copilot chat | 소비 기반 또는 M365 Copilot USL 포함 | 게시 이후 |

Standard harness에서 flow를 실행할 때의 계산:

- topic에서 flow 실행 → **Classic answer 1건 + flow action 수**
- generative orchestration에서 flow 실행 → **Autonomous action 1건 + flow action 수**
- 테스트 채팅/디자이너에서 실행 → **미과금**

Capacity 소진 시 새 flow 실행이 차단됩니다. 실행 중인 flow는 완료되고,
M365 Copilot 라이선스 사용자와 테스트 실행은 영향받지 않습니다.

## 13. 용어집

| 용어 | 의미 |
| --- | --- |
| Harness | agent/workflow가 실행되는 런타임 |
| Agent | 대화하고 작업을 수행하는 AI 어시스턴트 |
| Workflow | GitHub Copilot harness의 자동화 산출물 |
| Agent flow | Standard harness의 자동화 산출물 |
| Topic | 직접 설계하는 대화 흐름 조각 |
| Trigger phrase | topic을 여는 발화 예시 |
| Tool | agent가 외부 시스템에 수행하는 동작 |
| Skill | 재사용 가능한 Markdown 기반 능력 (GitHub Copilot harness) |
| Knowledge source | 답변 근거로 쓰이는 데이터 소스 |
| Grounding | 응답을 knowledge에 근거시키는 것 |
| Orchestration | 무엇으로 응답할지 결정하는 방식 (classic / generative) |
| Generative answers | knowledge에서 답을 생성하는 기능 |
| Channel | agent가 노출되는 접점 (Teams, 웹 등) |
| Environment | Power Platform의 리소스 격리 단위 |
| Solution | ALM 단위 패키지 |
| DLP / Data policy | connector 사용을 통제하는 정책 |
| Copilot Credits | GitHub Copilot harness의 사용량 과금 단위 |
| MCP | Model Context Protocol. 외부 tool/resource 표준 |
| A2A | Agent2Agent 프로토콜 |

## 14. 참고 문서

- [Copilot Studio overview](https://learn.microsoft.com/microsoft-copilot-studio/fundamentals-what-is-copilot-studio)
- [Agents overview](https://learn.microsoft.com/microsoft-copilot-studio/agents-overview)
- [Choose a harness](https://learn.microsoft.com/microsoft-copilot-studio/harnesses-overview)
- [Add tools to custom agents](https://learn.microsoft.com/microsoft-copilot-studio/advanced-plugin-actions)
- [Knowledge sources summary](https://learn.microsoft.com/microsoft-copilot-studio/knowledge-copilot-studio)
- [Skills overview](https://learn.microsoft.com/microsoft-copilot-studio/agents-experience/skills-overview)
- [Multi-agent orchestration patterns](https://learn.microsoft.com/microsoft-copilot-studio/guidance/multi-agent-patterns)
- [Design autonomous agent capabilities](https://learn.microsoft.com/microsoft-copilot-studio/guidance/autonomous-agents)
- [Publish and deploy your agent](https://learn.microsoft.com/microsoft-copilot-studio/publication-fundamentals-publish-channels)
- [Configure data policies for agents](https://learn.microsoft.com/microsoft-copilot-studio/admin-data-loss-prevention)
