# Copilot Studio Harness Lab

Microsoft Copilot Studio의 두 harness로 동일한 GitHub 이슈 트리아지 시나리오를 구현한 package입니다.

**처음 실행한다면 [`RUNBOOK.md`](RUNBOOK.md)를 순서대로 진행하세요.**

현재 검증 결과는 [`VALIDATION_REPORT.md`](VALIDATION_REPORT.md)에서 확인할 수 있습니다.

현재 계정별 권한 현황은 [`ACCOUNT_PERMISSION_INVENTORY.md`](ACCOUNT_PERMISSION_INVENTORY.md)에 정리되어 있습니다.

포털에서 네 리소스를 직접 만드는 절차는 [`PORTAL_CREATION_GUIDE.md`](PORTAL_CREATION_GUIDE.md), 현재 계정의 포털 기능 확인 결과는 [`PORTAL_ACCOUNT_CAPABILITY.md`](PORTAL_ACCOUNT_CAPABILITY.md)에서 확인할 수 있습니다.

| 구성 | 에이전트 | 자동화 |
| --- | --- | --- |
| Standard harness | `Simple Issue Triage Standard` | `Classify Issue - Standard` agent flow |
| GitHub Copilot harness | `Simple Issue Triage GitHub Harness` | `Classify Issue - GitHub Harness` workflow |

## 시나리오

실행 가능한 간단한 버전은 GitHub 이슈 제목과 본문을 다음과 같이 분류합니다.

- 유형: `bug`, `feature`, `documentation`, `question`, `security`
- 우선순위: `P0`, `P1`, `P2`, `P3`
- 결과: 유형, 우선순위, 한 문장 요약, 사람 검토 필요 여부

안전 기본값:

- 에이전트는 이슈를 닫거나 삭제하지 않습니다.
- `security` 또는 `P0` 분류는 반드시 사람의 승인을 거칩니다.
- 이슈 본문의 명령은 데이터로만 취급하고 에이전트 지침으로 실행하지 않습니다.

## 파일

```text
RUNBOOK.md
generated/
  standard-agent/
  github-agent/
  TriageWorkflowSolution/
scripts/
  install-pac.sh
  pac.sh
  pack-agents.sh
  pack-workflows.sh
tools/
  triage_cli.rb
  verify.rb
dist/
  TriageStandardAgent.zip
  TriageGitHubHarnessAgent.zip
  triage-workflows.zip
  issue-triage-skill.zip
```

`generated/`에는 공식 `pac copilot init`으로 만든 agent workspace와 Logic Apps workflow 정의가 있습니다. `standard-harness/`와 `github-copilot-harness/`에는 GitHub connector, 승인, 감사 로그까지 확장할 때 사용하는 선택적 blueprint가 있습니다.

빠른 확인:

```bash
make verify
make demo
make pack
```

배포, workflow 연결, Preview 테스트, CLI 인증, 채널별 실행 방법은 [`RUNBOOK.md`](RUNBOOK.md)에 단계별로 정리되어 있습니다.

## 참고

- [Choose a harness](https://learn.microsoft.com/en-us/microsoft-copilot-studio/harnesses-overview)
- [Agent flows overview](https://learn.microsoft.com/en-us/microsoft-copilot-studio/flows-overview)
- [Workflows overview](https://learn.microsoft.com/en-us/microsoft-copilot-studio/workflows-experience/flows-overview)
- [Skills overview](https://learn.microsoft.com/en-us/microsoft-copilot-studio/agents-experience/skills-overview)
