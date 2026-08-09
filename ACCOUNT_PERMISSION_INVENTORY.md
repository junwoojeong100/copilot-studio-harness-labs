# 실습 환경 실행 기록

이 문서는 특정 Developer 환경에서 실습 리소스를 만들고 검증한 결과만 기록합니다.
일반 절차는 [`PORTAL_CREATION_GUIDE.md`](PORTAL_CREATION_GUIDE.md), 권한과 DLP는
[`ROLES_AND_PERMISSIONS.md`](ROLES_AND_PERMISSIONS.md)를 기준으로 합니다.

최종 확인: 2026-08-09 18:14 KST

## 환경

```text
Name: Junwoo Jeong
Environment ID: e477cbf2-150c-eee7-a852-b29ac07f541d
Type: Developer
```

확인된 환경 역할:

- `Basic User`
- `Environment Maker`
- `System Administrator`

이 역할로 agent, agent flow, workflow를 생성·편집·테스트할 수 있습니다.
테넌트 수준 DLP 정책은 환경 역할만으로 변경할 수 없습니다.

## 현재 리소스

### Agents

| 이름 | Bot ID | 상태 |
| --- | --- | --- |
| `Simple Issue Triage Standard` | `54edb8e6-c490-f111-b8da-000d3a329d3b` | Draft · Preview PASS · DLP로 게시 차단 |
| `Simple Issue Triage GitHub Har` | `4236d9a0-9d6e-42b3-9377-a65e1c188d00` | Published · Preview PASS |

GitHub agent는 입력한 이름이 30자를 넘어
`Simple Issue Triage GitHub Har`로 잘려 저장됐습니다.

### Flows and workflows

| 이름 | ID | 상태 |
| --- | --- | --- |
| `Classify Issue - Standard` | `392d1a43-33d8-247c-fb53-b45dd60eb31c` | Published · required tests PASS |
| `Classify Issue - GitHub Harness` | `a6666167-9cca-6bb0-ad80-8490bb022981` | Published · required tests PASS |
| `Classify Issue - GitHub Harness (API Reference)` | `48ed52fb-bc90-f111-b8da-000d3a329d3b` | Activated · 포털 목록에는 미표시 |

## 필수 테스트 결과

### Standard flow

2026-08-09에 포털에서 다시 실행했습니다.

| 사례 | 출력 | 상태 |
| --- | --- | --- |
| Bug | `bug / P2 / Classified as bug with priority P2. / false` | Succeeded · 151 ms |
| Security | `security / P1 / Classified as security with priority P1. / true` | Succeeded · 241 ms |

### GitHub workflow

| 사례 | Run ID | 출력 |
| --- | --- | --- |
| Bug | `08584153403644278788340244435cU14` | `bug / P2 / Classified as bug with priority P2. / false` |
| Security | `08584153402683891072064956844CU08` | `security / P1 / Classified as security with priority P1. / true` |

두 자동화 모두 다음 계약을 반환합니다.

```text
category
priority
summary
needsHumanReview
```

## Agent Preview 결과

### Standard agent

입력:

```text
Issue title: Login fails
Issue description: 503 error
```

확인 결과:

- Agent가 `Classify Issue - Standard` tool을 선택함
- Tool 입력 `Text=Login fails`, `Text 1=503 error`
- 출력 `bug / P2 / Classified as bug with priority P2. / false`
- Tool action 상태 `Completed`

Maker Preview의 agent-to-flow 호출은 정상입니다.

### GitHub agent

런타임 순서:

```text
사용자
  → Simple Issue Triage GitHub Har
  → Classify Issue - GitHub Harness
  → agent 응답
```

| 사례 | Workflow 입력 | Workflow 출력 | Latency |
| --- | --- | --- | ---: |
| Bug | `text=Login fails`, `text_1=503 error` | `bug / P2 / false` | 264 ms |
| Security | `text=Access token appears in logs`, `text_1=vulnerability with no workaround` | `security / P1 / true` | 369 ms |

Preview trace에서 workflow 선택, 입력 두 개, 출력 JSON을 모두 확인했습니다.

## Standard agent 게시 차단

`Simple Issue Triage Standard`는 Preview에서 정상 동작하지만 Publish 버튼이
비활성화됩니다. Tool description을 수정·저장해 실제 게시 변경을 만든 뒤에도
상태가 같았습니다.

적용 중인 테넌트 DLP 정책:

```text
Policy: Personal Developer - (default)
Default connector classification: Blocked
Blocked connector: Skills with Copilot Studio
Connector ID: PvaSkills
```

Microsoft 문서에 따르면 DLP 위반이 있으면 Publish 버튼을 사용할 수 없게 됩니다.
현재 차단은 agent가 flow를 skill로 호출하는 기능에 적용됩니다.

필요한 조치:

1. `Power Platform Administrator`, `Global Administrator`, 또는
   `Dynamics 365 Administrator`가 테넌트 정책을 수정합니다.
2. `Skills with Copilot Studio`를 agent가 사용하는 다른 connector와 같은 허용
   그룹인 **Business** 또는 **Non-business**로 이동합니다.
3. 정책의 기본 분류가 `Blocked`이므로 Blocked 목록에서 제거만 하지 말고 허용
   그룹에 명시적으로 배치합니다.
4. 정책 반영 후 Standard agent를 다시 게시합니다.

환경의 `System Administrator` 역할만으로는 이 테넌트 정책을 바꿀 수 없습니다.
자세한 절차는
[`ROLES_AND_PERMISSIONS.md` 6장](ROLES_AND_PERMISSIONS.md#6-dlp-심화-차단된-connector-해제)을
참고하세요.

## 완료 상태

| 단계 | 상태 |
| --- | --- |
| A-1 Standard agent flow | Published · Bug/Security PASS |
| A-2 Standard agent | Preview PASS · 게시만 DLP 차단 |
| B-1 GitHub workflow | Published · Bug/Security PASS |
| B-2 GitHub agent | Published · Bug/Security Preview와 trace PASS |
| C-1 Edge headed Playwright | PASS |

## 남은 작업

| 작업 | 담당 |
| --- | --- |
| 테넌트 DLP에서 `PvaSkills` 허용 | Power Platform 관리자 |
| Standard agent 다시 게시 | Maker |
| 사용하지 않는 `API Reference` workflow의 참조 확인 후 정리 | 리소스 소유자 |
