# Copilot Studio Harness Lab

Microsoft Copilot Studio의 개념·기능을 정리하고,
포털에서 **Standard harness**와 **GitHub Copilot harness**의 agent·workflow를
직접 만들어 비교하는 실습 저장소입니다.

## 문서 안내

### 개념

| 문서 | 내용 |
| --- | --- |
| [`COPILOT_STUDIO_CONCEPTS.md`](COPILOT_STUDIO_CONCEPTS.md) | Copilot Studio 전반 개념과 기능. agent 구성 요소, orchestration, tool, knowledge, multi-agent, 채널, 운영, 거버넌스, ALM, 용어집 |
| [`HARNESS_COMPARISON.md`](HARNESS_COMPARISON.md) | 세 가지 harness(GitHub Copilot / Standard / Copilot chat)의 차이, 산출물 매핑, 과금 모델, 선택 기준 |
| [`ROLES_AND_PERMISSIONS.md`](ROLES_AND_PERMISSIONS.md) | 개발·운영·관리를 위한 플랫폼별 역할과 권한. 플랫폼 지도, 역할 카탈로그, 작업별 권한 매트릭스, 페르소나 번들, DLP 심화 |

### 실습

| 문서 | 내용 |
| --- | --- |
| [`PORTAL_CREATION_GUIDE.md`](PORTAL_CREATION_GUIDE.md) | 포털에서 agent와 workflow를 생성하고 연결하는 실습 절차 |

### 실행 기록

| 문서 | 내용 |
| --- | --- |
| [`PORTAL_ACCOUNT_CAPABILITY.md`](PORTAL_ACCOUNT_CAPABILITY.md) | 대상 계정의 포털 기능 확인 결과 요약 |
| [`ACCOUNT_PERMISSION_INVENTORY.md`](ACCOUNT_PERMISSION_INVENTORY.md) | 계정, 환경 역할, 라이선스, capacity 현황 상세 |

## 읽는 순서

```text
처음이라면
  COPILOT_STUDIO_CONCEPTS.md  →  HARNESS_COMPARISON.md  →  PORTAL_CREATION_GUIDE.md

실습부터 하려면
  PORTAL_CREATION_GUIDE.md 의 "사전 준비 체크리스트"  →  실습

권한 문제로 막혔다면
  ROLES_AND_PERMISSIONS.md 의 "작업 → 필요 권한 매트릭스" 와 "DLP 심화"
```

## 실습 시나리오

동일한 **GitHub 이슈 분류** 시나리오를 두 harness로 각각 구현합니다.

```text
Lab A (Standard harness)
  A-1. Agent flow  : Classify Issue - Standard
  A-2. Agent       : Simple Issue Triage Standard

Lab B (GitHub Copilot harness)
  B-1. Workflow    : Classify Issue - GitHub Harness
  B-2. Agent       : Simple Issue Triage GitHub Harness
```

> **순서 주의**: flow/workflow를 먼저 만들어 **게시**한 뒤 agent에 tool로 연결합니다.
> 게시하지 않은 flow는 tool 목록에 나타나지 않습니다.

## 현재 검증 상태

기준: 대상 환경 `Junwoo Jeong` (`e477cbf2-150c-eee7-a852-b29ac07f541d`)

| 리소스 | 상태 | 검증 |
| --- | --- | --- |
| `Classify Issue - Standard` (agent flow) | Published | 직접 실행 123 ms, Succeeded |
| `Classify Issue - GitHub Harness` (workflow) | Published | checker 0/0, 직접 실행 149 ms, Succeeded |
| `Simple Issue Triage GitHub Harness` (agent) | Published | — |
| `Simple Issue Triage Standard` (agent) | **Draft** | 테넌트 DLP가 `Skills with Copilot Studio` connector 차단 |

**4종 생성 완료, 3종 게시 완료, 1종 Draft**입니다.

두 flow는 포털 연결과 응답 경로를 검증하는 **스모크 테스트 구성**입니다.
운영용 분류 규칙은 실습 가이드의 "확장: 운영용 분류 규칙"을 기준으로 추가합니다.

### 남은 작업

1. GitHub agent Preview에서 workflow end-to-end 호출 확인
2. `Skills with Copilot Studio` connector에 대한 테넌트 DLP 예외 승인
3. 예외 승인 후 Standard agent 게시 및 end-to-end 확인

## 범위

- 웹 포털 저작 경로만 다룹니다.
- 코드, CLI, solution package를 이용한 생성 경로는 포함하지 않습니다.
- harness는 자동화 산출물을 만들 수 있는 GitHub Copilot / Standard 두 가지를 실습합니다.
  Copilot chat harness는 개념 문서에서만 다룹니다.
