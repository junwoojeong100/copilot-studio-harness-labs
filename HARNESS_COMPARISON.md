# Harness 비교 가이드

Copilot Studio에서 만드는 모든 것은 **harness** 위에서 실행됩니다.
이 문서는 현재 제공되는 세 가지 harness의 차이와 선택 기준을 정리합니다.

기준 문서: [Choose a harness](https://learn.microsoft.com/microsoft-copilot-studio/harnesses-overview)

사실 확인: 2026-08-09

## Harness란 무엇인가

Harness는 **런타임**입니다. 아래 두 계층 사이에 위치합니다.

```text
[ 사용자가 만든 것 ]   agent / workflow / agent flow / topic / tool
          ↓
[ Harness = 런타임 ]   언제 모델을 호출할지, 무엇을 보낼지,
                      응답을 어떻게 해석할지, 어떤 tool을 호출할지 결정
          ↓
[ 모델 ]              추론과 생성
```

Harness가 결정하는 것:

| 항목 | 설명 |
| --- | --- |
| 실행 방식 | 정의된 규칙·분기를 따를지, 목표를 스스로 단계로 분해할지 |
| 자동화 범위 | 한 번에 끝낼 수 있는 프로세스의 길이와 복잡도 |
| 기본 제공 기능 | 파일 생성/편집, skills, memory, tool orchestration 지원 여부 |
| 과금 방식 | GitHub harness 사용량 과금인지 standard harness 라이선스·과금인지 |

즉 harness 선택은 **모델 선택보다 먼저 오는 아키텍처 결정**입니다.

## 세 가지 harness

### 1. GitHub Copilot harness

기능 범위가 가장 넓은 옵션입니다. 추론 중심의 다단계 비즈니스 프로세스에 적합합니다.

- 목표를 받아 단계로 분해하고, 실패하면 대체 경로를 찾아 재시도합니다.
- connector, knowledge, MCP, connected agent를 가로질러 tool을 호출합니다.
- Word, Excel, PowerPoint, PDF를 **네이티브로 생성·편집**합니다.
- [skills](https://learn.microsoft.com/microsoft-copilot-studio/agents-experience/skills-overview)와
  [memory](https://learn.microsoft.com/microsoft-copilot-studio/agents-experience/memory-overview)를 지원합니다.
- 각 작업을 Copilot Studio가 통제하는 **보안 샌드박스**에서 실행합니다.

만드는 산출물: **agent**, **workflow**

적합한 예: 송장을 읽어 발주서와 대조하고 예외 건을 승인 라인으로 보내는 미지급금(AP) 처리

### 2. Standard harness

규칙 기반 agent와 구조화된 대화용. 예측 가능성이 최우선일 때 선택합니다.

- classic orchestration에서는 topic과 경로를 직접 정의해 실행 흐름을 통제합니다.
- generative orchestration을 켜면 모델이 topic, tool, knowledge를 선택하므로
  응답이 항상 같다고 볼 수는 없습니다.
- 기존 prompt 라이브러리와 엔터프라이즈 knowledge를 그대로 활용합니다.
- classic orchestration(topic만 사용)과 generative orchestration을 모두 지원합니다.

만드는 산출물: **agent**, **agent flow**

적합한 예: 자주 묻는 질문에 답하고 단순 요청을 라우팅하는 사내 헬프데스크

### 3. Copilot chat harness

Microsoft 365 Copilot Chat을 조직 knowledge로 확장하는 harness입니다.

- 사내 콘텐츠에 근거한 답변을 M365 Copilot Chat 경험 안에서 제공합니다.
- 최신 chat 모델 위에서 동작하며 **내부 팀에만 게시**합니다.
- 정보 연결이 목적일 때 적합하고, 프로세스 자동화가 목적이면 부적합합니다.

만드는 산출물: **agent** (M365 Copilot 확장)

적합한 예: SharePoint knowledge에서 답하는 신규 입사자 온보딩 agent

## 한눈에 보는 비교표

| 고려 항목 | GitHub Copilot harness | Standard harness | Copilot chat harness |
| --- | --- | --- | --- |
| 최적 용도 | 복잡한 다단계 비즈니스 프로세스 | 규칙 기반 agent와 구조화된 대화 | 엔터프라이즈 knowledge로 M365 Copilot Chat 확장 |
| 동작 방식 | 목표를 스스로 단계별로 추론 | classic은 정의한 경로, generative는 모델이 경로 선택 | knowledge를 M365 Copilot Chat에 연결 |
| 오류 복구 | 자동 재시도 및 대체 경로 탐색 | 선택한 orchestration과 작성한 경로에 따름 | 해당 없음 |
| 파일 처리 | Word/Excel/PowerPoint/PDF 생성·편집·추론 | 해당 없음 | 해당 없음 |
| Skills / Memory | 지원 | 해당 없음 | 해당 없음 |
| 게시 대상 | 내부 팀 또는 외부 고객 | 내부 팀 또는 외부 고객 | 내부 팀 |
| 과금 | Copilot Credits 기반 사용량 과금 | Standard harness 라이선스·Copilot Credits | 소비 기반 또는 M365 Copilot USL에 포함 |

## 산출물 매핑

harness마다 부르는 이름과 만드는 위치가 다릅니다. 실습에서 가장 많이 헷갈리는 부분입니다.

| 자동화 산출물 | Harness | 포털 진입 경로 | 과금 단위 |
| --- | --- | --- | --- |
| **Workflow** | GitHub Copilot | **New experience = On** → 왼쪽 **Workflows** → **New workflow** | Copilot Credits |
| **Agent flow** | Standard | **Workflows** 페이지 → **New agent flow** (이전 경험에서는 **Flows**) | Standard harness 라이선스·Copilot Credits |
| **Agent** (GitHub) | GitHub Copilot | **New experience = On** → **Agents** → **New agent** | Copilot Credits |
| **Agent** (Standard) | Standard | **New experience = Off** 또는 Home의 **Other ways to build** | Standard harness 라이선스·Copilot Credits |

> **중요**: workflow와 agent flow는 서로 다른 형식입니다.
> Power Automate cloud flow는 agent flow로 변환할 수 있지만,
> **새 workflow 형식으로는 변환할 수 없습니다.** 변환은 되돌릴 수 없습니다.

두 형식 모두 **When an agent calls the flow** trigger를 사용하면 agent의 tool로 등록할 수 있습니다.

## 과금 모델 차이

가장 실무적인 차이입니다.

| 항목 | GitHub Copilot harness | Standard harness |
| --- | --- | --- |
| 과금 방식 | Copilot Credits 기반 사용량 과금 | Standard harness 라이선스와 Copilot Credits 요율 |
| **과금 시작 시점** | **빌드를 시작하는 순간부터** | **게시(publish) 이후부터** |
| 과금 대상 | LLM 토큰, tool(knowledge·MCP 포함), harness 자체 | 대화 및 action 실행 |
| 테스트 | Preview·테스트·평가도 credit을 사용할 수 있음 | Trial에서도 test chat 가능, 게시 불가 |
| 사용량 확인 | agent의 **Monitor** 페이지 | PPAC → **Licensing** → **Copilot Studio** |

> GitHub Copilot harness에서는 **만들고 테스트하는 것만으로도 credit이 소모**됩니다.
> Standard harness의 감각으로 접근하면 예산을 초과하기 쉽습니다.

Standard harness의 정확한 요율과 enforcement는
[공식 라이선스 문서](https://learn.microsoft.com/microsoft-copilot-studio/billing-licensing)를
기준으로 확인하세요.

## 선택 기준

```text
파일을 만들거나 편집해야 하는가?                      → GitHub Copilot harness
여러 tool을 순차 호출하며 결과에 따라 판단해야 하는가?  → GitHub Copilot harness
프로세스를 끝까지 자동화해야 하는가?                   → GitHub Copilot harness

동일 입력에 같은 경로와 출력 계약이 필요한가?            → Standard + classic orchestration
시나리오가 명확히 정의된 규칙 기반인가?                 → Standard harness
비용을 예측 가능하게 통제해야 하는가?                   → Standard harness

목적이 "정보 연결"이고 사용자가 M365 Copilot Chat에 있는가? → Copilot chat harness
별도 채널을 만들지 않고 사내 직원에게만 도달하면 되는가?     → Copilot chat harness
```

> Standard harness 자체가 응답의 결정론성을 보장하는 것은 아닙니다.
> 재현성이 필요하면 classic orchestration으로 경로를 고정하고,
> 계산은 deterministic agent flow에 두며, 생성형 prompt 사용을 제한하세요.

### 혼합 구성

harness는 배타적이지 않습니다. 실무에서는 조합이 일반적입니다.

- GitHub Copilot harness agent가 오케스트레이션을 담당하고,
  결정론적 계산은 standard harness agent flow에 위임
- Standard harness agent가 정형 대화를 처리하고,
  판단이 필요한 구간만 GitHub Copilot harness agent에 handoff

이 저장소의 실습은 **동일한 이슈 분류 시나리오를 두 harness로 각각 구현**해
차이를 직접 비교하도록 구성되어 있습니다.
자세한 내용은 [`PORTAL_CREATION_GUIDE.md`](PORTAL_CREATION_GUIDE.md)를 참고하세요.

## 두 harness 전환 방법

Copilot Studio 홈에서 **New experience** 토글로 전환합니다.

| 토글 | 결과 |
| --- | --- |
| On | GitHub Copilot harness (Agents / Workflows) |
| Off | Standard harness (기존 Copilot Studio 경험) |

Standard harness 산출물은 토글을 끄지 않고도 Home의 **Other ways to build**로 만들 수 있습니다.
GitHub Copilot harness에서 agent flow를 만들거나 편집하면 **새 브라우저 탭**으로 열립니다.

## 거버넌스 관점의 차이

| 항목 | 차이점 |
| --- | --- |
| DLP | Copilot Studio 가상 connector 정책은 harness와 무관하게 공통 적용 |
| 용량 통제 | GitHub Copilot harness는 agent 단위 credit 한도 설정 가능 (PPAC → Licensing → Copilot Studio) |
| 게시 승인 | Teams/M365 채널 게시는 harness와 무관하게 관리자 승인 필요 |
| 감사 | 두 harness 모두 Dataverse에 transcript 저장, `Bot Transcript Viewer` 역할로 접근 통제 |

권한과 역할의 전체 목록은 [`ROLES_AND_PERMISSIONS.md`](ROLES_AND_PERMISSIONS.md)를 참고하세요.

## 참고 문서

- [Choose a harness](https://learn.microsoft.com/microsoft-copilot-studio/harnesses-overview)
- [Agents overview](https://learn.microsoft.com/microsoft-copilot-studio/agents-overview)
- [Workflows overview](https://learn.microsoft.com/microsoft-copilot-studio/workflows-experience/flows-overview)
- [Agent flows overview](https://learn.microsoft.com/microsoft-copilot-studio/flows-overview)
- [Access standard harness agents and agent flows](https://learn.microsoft.com/microsoft-copilot-studio/agents-experience/switch-experiences)
- [Billing for the GitHub Copilot harness](https://learn.microsoft.com/microsoft-copilot-studio/agents-experience/billing-credit-overview)
- [Licensing for the standard harness](https://learn.microsoft.com/microsoft-copilot-studio/billing-licensing)
