# Copilot Studio agent flow 생성 프롬프트

`Classify GitHub Issue`라는 agent flow를 만들어 줘.

트리거는 `When an agent calls the flow`를 사용하고 다음 입력을 받게 해 줘.

- repository: text, required
- issueNumber: number, required
- issueTitle: text, required
- issueBody: text, optional

flow는 입력값을 정규화하고, 고정된 label policy와 함께 AI prompt에 전달해 JSON 분류 결과를 받아야 해. JSON을 파싱한 다음 아래 검증을 적용해.

- confidence가 0.75 미만이면 team을 `needs-triage`로 설정하고 needsHumanReview를 true로 설정
- type이 security이거나 priority가 P0이면 needsHumanReview를 true로 설정
- 허용 목록에 없는 type, priority, team 또는 label이 있으면 flow를 실패 처리

마지막에 `Respond to the agent`로 type, priority, team, labels, summary, reasoning, confidence, needsHumanReview, followUpQuestions를 반환해 줘. 외부 시스템을 변경하는 action은 추가하지 마.

