# 검증 방법: 포털 UI 없이 실습 결과 확인하기

이 실습의 결과물은 **포털 화면을 눈으로 보는 것만으로는 정확히 검증되지 않습니다.**
화면은 표시 이름만 보여주고, 실제로 저장되는 것은 내부 이름과 식(expression)이기 때문입니다.

이 문서는 **읽기 전용 API로 결정적으로 검증하는 방법**을 정리합니다.
과금이 없고, 리소스를 변경하지 않으며, 스크립트로 반복 가능합니다.

## 왜 API 검증이 필요한가

실제로 이 실습 문서에서 **포털 화면만 보고 놓쳤던 오류**들입니다.

| 놓친 것 | 화면에 보이던 것 | 정의 원본의 실제 값 |
| --- | --- | --- |
| Respond 출력 개수 | 라벨 `category` 1줄 | 키 `text` / title `category` — 키와 라벨이 다름 |
| Lab A 분류 규칙 | 노드 이름 `Category` | security/bug/documentation/feature/question 5분류 완성본 |
| Lab B 1번 노드 | 정상 노드로 보임 | `@` 누락 → 식이 아니라 **문자열 리터럴** |
| Agent 이름 | `Simple Issue Triage GitHub Har…` | 말줄임이 아니라 **30자에서 잘린 실제 값** |
| Workflow 개수 | `2 items` | Dataverse에는 **3개** |
| 노드 타입 | 팔레트 라벨 `Function` | 저장 타입은 `Compose` |

즉 **표시 계층과 저장 계층이 다릅니다.** 저장 계층을 봐야 합니다.

## 0. 준비

Azure CLI로 로그인하면 별도 설치 없이 세 개의 API를 쓸 수 있습니다.

```bash
az login
az account show --query user.name -o tsv
```

| API | 리소스 URI | 용도 |
| --- | --- | --- |
| Power Platform BAP | `https://api.bap.microsoft.com/` | 환경 목록, Dataverse URL, DLP 정책 |
| Power Automate | `https://service.flow.microsoft.com/` | flow 실행 이력 |
| Dataverse | `https://<org>.crm.dynamics.com` | agent·flow 정의 원본 |

## 1. 환경의 Dataverse URL 찾기

```bash
ENV=<environment-id>
TOK=$(az account get-access-token --resource "https://api.bap.microsoft.com/" \
      --query accessToken -o tsv)

curl -s -H "Authorization: Bearer $TOK" \
  "https://api.bap.microsoft.com/providers/Microsoft.BusinessAppPlatform/environments/$ENV?api-version=2020-10-01" \
| python3 -c "import json,sys; p=json.load(sys.stdin)['properties']; \
print(p['displayName'], p['environmentSku'], p['linkedEnvironmentMetadata']['instanceUrl'])"
```

이 실습 환경 결과:

```text
Junwoo Jeong  Developer  https://orgcb421559.crm.dynamics.com/
```

## 2. Agent(bot) 상태 확인

`publishedon`이 `null`이면 **한 번도 게시되지 않은 것**입니다.
포털의 `Last published: Never`와 같은 의미입니다.

```bash
DV=https://orgcb421559.crm.dynamics.com
TOK=$(az account get-access-token --resource "$DV" --query accessToken -o tsv)

curl -s -H "Authorization: Bearer $TOK" \
  "$DV/api/data/v9.2/bots?\$select=name,botid,publishedon,statecode"
```

확인할 것:

- `name` — 30자 초과 시 잘렸는지
- `publishedon` — 게시 여부
- `botid` — 문서에 기록한 ID와 일치하는지

## 3. Flow 정의 원본 읽기 (가장 중요)

`clientdata`에 트리거·액션·식이 **그대로** 들어 있습니다.

```bash
ID=<workflow-id>
curl -s -H "Authorization: Bearer $TOK" \
  "$DV/api/data/v9.2/workflows($ID)?\$select=name,clientdata" \
| python3 -c "
import json,sys
cd=json.loads(json.load(sys.stdin)['clientdata'])
d=cd.get('properties',cd).get('definition',cd.get('definition',{}))
for k,v in d.get('triggers',{}).items():
    print('TRIGGER',k,v.get('type'),'kind=',v.get('kind'))
for k,v in d.get('actions',{}).items():
    print('ACTION ',k,v.get('type'))
    print('   ',json.dumps(v.get('inputs'),ensure_ascii=False)[:300])
"
```

여기서 반드시 확인할 것:

1. **트리거 `kind`** — `Skills`이면 DLP의 `PvaSkills` 커넥터에 의존합니다.
2. **식의 `@` 접두사** — `@{...}` 또는 `@...`가 없으면 **문자열 리터럴**입니다.
   Lab B의 1번 노드가 정확히 이 함정에 빠져 있습니다.
3. **Response 스키마의 `properties` 키와 `title`** — agent가 보는 이름은 `title`입니다.
4. **`body`의 값이 상수인지 `@{outputs(...)}`인지** — 상수면 계산 결과가 버려집니다.
5. **`outputs('이름')`의 이름** — 표시 이름이 아니라 **내부 이름**(공백이 `_`)입니다.

## 4. 실행 이력 확인

```bash
TOK=$(az account get-access-token --resource "https://service.flow.microsoft.com/" \
      --query accessToken -o tsv)

curl -s -H "Authorization: Bearer $TOK" \
  "https://api.flow.microsoft.com/providers/Microsoft.ProcessSimple/environments/$ENV/flows/$ID/runs?api-version=2016-11-01" \
| python3 -c "
import json,sys
from datetime import datetime
for r in json.load(sys.stdin)['value']:
    p=r['properties']
    f='%Y-%m-%dT%H:%M:%S.%f'
    s=datetime.strptime(p['startTime'][:26],f); e=datetime.strptime(p['endTime'][:26],f)
    print(r['name'], p['status'], f'{(e-s).total_seconds()*1000:.0f}ms')
"
```

이 방법으로 문서의 Run ID와 소요 시간(123 ms / 149 ms)을 **정확히 재현**했습니다.
포털 Activity 패널이 응답하지 않아도 실행 이력을 확인할 수 있습니다.

## 5. DLP 정책 확인 (차단 원인 규명)

게시 실패의 원인을 **추측하지 않고 확정**할 수 있습니다.

```bash
TOK=$(az account get-access-token --resource "https://api.bap.microsoft.com/" \
      --query accessToken -o tsv)

curl -s -H "Authorization: Bearer $TOK" \
  "https://api.bap.microsoft.com/providers/PowerPlatform.Governance/v2/policies?api-version=2020-10-01" \
  -o policies.json
```

적용 정책을 고르는 규칙:

| `environmentType` | 적용 조건 |
| --- | --- |
| `AllEnvironments` | 항상 적용 |
| `OnlyEnvironments` | 목록에 대상 환경이 **있으면** 적용 |
| `ExceptEnvironments` | 목록에 대상 환경이 **없으면** 적용 |

정책 하나를 골라 상세를 받으면 커넥터 분류를 볼 수 있습니다.

```bash
curl -s -H "Authorization: Bearer $TOK" \
  "https://api.bap.microsoft.com/providers/PowerPlatform.Governance/v2/policies/<policy-id>?api-version=2020-10-01"
```

이 환경의 확정 결과:

```text
정책        : Personal Developer - (default)
범위        : ExceptEnvironments (대상 환경이 제외 목록에 없음 → 적용)
기본 분류   : Blocked
PvaSkills   : Blocked  ← Skills with Copilot Studio
```

`defaultConnectorsClassification: Blocked`가 핵심입니다.
**명시적으로 허용하지 않은 모든 커넥터가 차단**되는 정책이며,
`PvaSkills`는 그 위에 Blocked 그룹에 **명시적으로도** 들어 있습니다.

## 6. 아직 API로 확인할 수 없는 것

| 항목 | 이유 | 대안 |
| --- | --- | --- |
| Flow checker 결과 | 디자이너 전용 정적 분석, API 없음 | 정의 원본을 직접 읽어 `@` 누락·이름 불일치를 점검 |
| agent → flow end-to-end 응답 | 실제 대화 실행이 필요 | Standard는 DLP 해제 후 Test 패널, GitHub는 Credits 한도 설정 후 Preview |
| DLP 차단 시 화면 오류 문구 | UI 문자열 | 게시를 시도해 캡처 (실패해도 리소스 변경 없음) |

## 7. 정리 체크리스트

실습을 마친 뒤 아래를 한 번씩 돌리면 문서와 실제가 어긋나지 않습니다.

- [ ] `bots`의 `name`이 30자에서 잘리지 않았는가
- [ ] `bots`의 `publishedon`이 기대와 일치하는가
- [ ] `workflows` 개수가 포털 목록과 일치하는가 (잔여 리소스 확인)
- [ ] 모든 Compose 입력에 `@` 접두사가 있는가
- [ ] Response `body`의 값이 상수가 아니라 `@{outputs(...)}`인가
- [ ] Response `properties`의 `title`이 topic 메시지의 변수명과 일치하는가
- [ ] flow 실행이 Succeeded이고 소요 시간이 문서와 일치하는가

## 관련 문서

- 실습 절차: [`PORTAL_CREATION_GUIDE.md`](PORTAL_CREATION_GUIDE.md)
- 역할·권한·DLP: [`ROLES_AND_PERMISSIONS.md`](ROLES_AND_PERMISSIONS.md)
- 개념: [`COPILOT_STUDIO_CONCEPTS.md`](COPILOT_STUDIO_CONCEPTS.md)
- Harness 비교: [`HARNESS_COMPARISON.md`](HARNESS_COMPARISON.md)
