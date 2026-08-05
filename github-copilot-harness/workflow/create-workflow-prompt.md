# Copilot Studio workflow 생성 프롬프트

GitHub Copilot harness 기반 `Execute GitHub Issue Triage` workflow를 만들어 줘.

`When an agent calls the flow` 트리거로 repository, issueNumber, dryRun, type, priority, team, confidence, labelsToAdd, proposedComment, duplicateCandidates를 입력받아.

다음 순서를 구현해.

1. 입력 스키마와 허용 값을 검증한다.
2. GitHub에서 이슈의 최신 labels와 상태를 다시 읽는다.
3. dryRun이면 외부 변경 없이 계획만 반환한다.
4. security, P0, confidence 0.75 미만 또는 team이 needs-triage이면 Teams approval을 요청한다.
5. 승인 거절 또는 timeout이면 변경하지 않고 사람이 검토해야 한다고 반환한다.
6. 승인되었거나 승인이 필요 없으면 저장소에 존재하는 labels만 추가한다.
7. proposedComment가 비어 있지 않으면 트리아지 요약 댓글을 추가한다.
8. 이슈를 닫거나 삭제하거나 자동으로 duplicate 표시하지 않는다.
9. SharePoint 또는 Dataverse에 실행 ID, 저장소, 이슈 번호, 이전 labels, 추가 labels, 승인자, 결과와 timestamp를 기록한다.
10. `Respond to the agent`로 status, appliedLabels, commentAdded, approvalRequired, approvalOutcome, auditId, message를 반환한다.

각 GitHub write action은 한 번만 재시도하고, 일부만 성공한 경우 성공한 변경과 실패한 변경을 구분해서 반환해.

