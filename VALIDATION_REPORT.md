# Validation Report

검증 일시: 2026-08-05

## 결론

에이전트·workflow 소스, solution 패키지, 분류 로직은 정상입니다. 두 native workflow는 새 포털 형식으로 Published 되었고 실제 HTTP 실행에서 `bug / P0 / true`를 반환했습니다. GitHub Copilot agent는 Published 상태입니다. Standard agent는 native workflow tool 연결까지 완료됐지만 조직 DLP가 Copilot Studio `Skills` connector를 차단해 Draft 상태입니다.

따라서 현재 판정은 다음과 같습니다.

| 범위 | 결과 |
| --- | --- |
| 로컬 분류 동작 | PASS |
| Agent source 유효성 | PASS |
| Workflow source 유효성 | PASS |
| Agent solution pack | PASS |
| Workflow solution pack | PASS |
| Workflow pack/unpack round-trip | PASS |
| ZIP 무결성 | PASS |
| Web portal authoring access | PASS |
| GitHub agent create/publish | PASS |
| Standard imported agent publish | BLOCKED: tenant DLP |
| GitHub imported agent publish | PASS |
| GitHub workflow create menu | PASS |
| Standard agent create menu | PASS |
| Standard agent flow create menu | PASS |
| Prepared solution live import | PASS |
| Native workflow publish/run | PASS |
| Standard workflow tool connection | PASS |
| GitHub workflow tool connection | NOT APPLIED: published agent 보존 |
| Prepared agent Preview response | NOT RUN |

## 통과한 자동 검사

실행 명령:

```bash
make verify
```

결과:

```text
OK standard: agent + workflow + tool link
OK github-harness: agent + workflow + tool link
OK test production-outage
OK test docs-typo
OK test possible-secret-exposure
OK test prompt-injection
OK test ambiguous-request
OK standard agent package
OK GitHub harness agent package
OK workflow package
OK skill package
All local checks passed.
```

## 실제 입력·출력 확인

실행 명령:

```bash
make demo
```

입력:

```text
Title: Checkout API returns 503 for all customers
Body: The incident started after deployment and there is no workaround.
```

출력:

```json
{
  "category": "bug",
  "priority": "P0",
  "summary": "Classified as bug with priority P0.",
  "needsHumanReview": true
}
```

## 패키지 확인

정상 생성된 import 파일:

```text
dist/TriageStandardAgent.zip
dist/TriageGitHubHarnessAgent.zip
dist/triage-workflows.zip
dist/issue-triage-skill.zip
```

`triage-workflows.zip`을 PAC CLI로 다시 unpack했을 때 다음 두 workflow가 복원됐습니다.

```text
Classify Issue - Standard
Classify Issue - GitHub Harness
```

두 agent ZIP 내부에 `Classify Issue`를 호출하도록 작성된 instructions도 포함되어 있습니다.

## Live runtime 현재 상태

확인 완료:

- Company Portal 로그인
- User Approved MDM enrollment
- Device status `In compliance`
- M365 E5의 `Power Virtual Agents for Office 365` 제한 entitlement 확인
- GitHub harness author/publish entitlement 실제 동작 확인
- Tenant AI/MCS capacity 존재 확인
- Developer 환경 allocation record 없음 확인
- Tenant PAYG billing policy 0개 확인
- Standard agent를 비-GenAI explicit-topic 구성으로 변경
- 웹 포털에서 기존 Published GitHub Copilot agent 확인
- 새 경험에서 New workflow 버튼 확인
- 이전 경험에서 Standard Agent와 New agent flow 메뉴 확인
- agent solution 2개와 workflow solution import 완료
- Standard/GitHub native workflow 생성 및 Published
- 두 native workflow를 직접 호출해 `bug / P0 / true` 확인
- Standard agent에 `Classify Issue - Standard` tool 추가
- Standard publish의 CloudFlow `NotFound` 오류 해결

진행 중/미완료:

```text
PAC auth profile: 없음
Standard agent publish: DLP 차단
GitHub agent: Published
Standard native workflow: Published, 실행 PASS
GitHub native workflow: Published, 실행 PASS
Standard agent Preview: publish 차단으로 미완료
GitHub workflow tool 연결: DLP 해결 후 수행
```

추가 필요:

1. Power Platform DLP 정책에서 Copilot Studio `Skills` connector를 허용하거나 이 Developer 환경을 승인된 예외 환경으로 지정
2. Standard agent Publish 후 Preview 실행
3. GitHub agent에 native GitHub workflow를 연결하고 다시 Publish
4. 두 agent의 activity trace에서 workflow 호출 확인

## Live 합격 기준

관리 디바이스에서 [`RUNBOOK.md`](RUNBOOK.md)의 5~7장을 수행하고 아래 결과를 모두 확인해야 최종 PASS입니다.

1. `triage-workflows.zip` import 성공
2. agent ZIP 두 개 import 성공
3. workflow 두 개 publish 성공
4. Standard agent에 workflow tool 연결
5. DLP 예외 승인
6. Standard agent Test에서 workflow 호출 확인
7. GitHub harness agent에 workflow tool 연결 및 Preview 확인
8. outage 입력이 `bug / P0 / true` 반환
9. token 노출 입력이 `security / P1 / true` 반환
