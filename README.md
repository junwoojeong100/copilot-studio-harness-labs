# Copilot Studio Harness Lab

Microsoft Copilot Studio 포털에서 Standard harness와 GitHub Copilot harness의
agent 및 workflow를 직접 생성하는 실습 문서입니다.

## 현재 검증 상태

- 필수 리소스 4종은 모두 생성됨
- 배포 상태: 3종 Published, Standard agent 1종 Draft
- 미배포 리소스: `Simple Issue Triage Standard` (tenant DLP 차단)
- Standard flow: `Classify Issue - Standard`
  (`392d1a43-33d8-247c-fb53-b45dd60eb31c`)
- Standard flow 직접 실행: `Login fails` / `503 error`, 123ms, `Succeeded`
- Standard agent Tool 연결 완료
- GitHub workflow: `Classify Issue - GitHub Harness`
  (`a6666167-9cca-6bb0-ad80-8490bb022981`)
- GitHub workflow checker: 오류 0, 경고 0
- GitHub workflow 직접 실행: `503 error` / `urgent`, 149ms, `Succeeded`

두 flow는 현재 포털 연결과 응답 경로를 검증하는 간단한 smoke-test 구성입니다.
운영용 분류 규칙은 가이드의 확장 규칙을 기준으로 추가합니다.

## 문서

- [`PORTAL_CREATION_GUIDE.md`](PORTAL_CREATION_GUIDE.md): 포털에서 agent와 workflow를 생성하고 연결하는 절차
- [`PORTAL_ACCOUNT_CAPABILITY.md`](PORTAL_ACCOUNT_CAPABILITY.md): 현재 계정의 포털 기능 확인 결과
- [`ACCOUNT_PERMISSION_INVENTORY.md`](ACCOUNT_PERMISSION_INVENTORY.md): 계정, 환경 역할, 라이선스 및 capacity 현황

코드, CLI, solution package를 이용한 생성 경로는 포함하지 않습니다.
