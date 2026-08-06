# 검증 방법: 포털 UI 없이 실습 결과 확인하기

포털은 표시 이름만 보여 주므로 내부 이름, 식, 응답 스키마를 놓칠 수 있습니다.
이 문서는 읽기 전용 API로 agent와 workflow의 저장 정의와 실행 결과를 확인합니다.
명령은 리소스를 변경하지 않으며 반복 실행할 수 있습니다.

## 0. 준비

Azure CLI에 로그인합니다.

```bash
az login
az account show --query user.name -o tsv
```

이 문서에서 사용하는 변수:

| 변수 | 의미 | 설정 위치 |
| --- | --- | --- |
| `ENV` | 환경 ID | 1장 |
| `DV` | 환경의 Dataverse URL | 1장에서 자동 설정 |
| `ID` | 대상 workflow ID | 3장 |
| `TOK` | 현재 API의 액세스 토큰 | 각 장에서 다시 발급 |

> 토큰은 API마다 다릅니다. 리소스 URI가 바뀔 때마다 `TOK`를 다시 받으세요.
> 새 터미널을 열면 `ENV`, `DV`, `ID`도 다시 설정해야 합니다.
> 토큰을 파일이나 문서에 저장하지 마세요.

## 1. 환경과 Dataverse URL 확인

`<environment-id>`를 Copilot Studio URL이나 PPAC에서 확인한 값으로 바꿉니다.

```bash
ENV=<environment-id>
TOK=$(az account get-access-token --resource "https://api.bap.microsoft.com/" \
      --query accessToken -o tsv)

ENV_JSON=$(curl -fsS -H "Authorization: Bearer ${TOK}" \
  "https://api.bap.microsoft.com/providers/Microsoft.BusinessAppPlatform/environments/${ENV}?api-version=2020-10-01")

printf '%s' "$ENV_JSON" | python3 -c "import json,sys; p=json.load(sys.stdin)['properties']; \
print(p['displayName'], p['environmentSku'], p['linkedEnvironmentMetadata']['instanceUrl'])"

DV=$(printf '%s' "$ENV_JSON" | python3 -c "import json,sys; \
print(json.load(sys.stdin)['properties']['linkedEnvironmentMetadata']['instanceUrl'].rstrip('/'))")
```

첫 명령은 환경 이름, 유형, Dataverse URL을 출력합니다. 마지막 명령은 이후 단계에서
재사용할 `DV`를 자동으로 설정합니다.

## 2. Agent 상태 확인

```bash
TOK=$(az account get-access-token --resource "$DV" --query accessToken -o tsv)

curl -fsS -H "Authorization: Bearer ${TOK}" \
  "$DV/api/data/v9.2/bots?\$select=name,botid,publishedon,statecode" \
| python3 -m json.tool
```

확인 항목:

- `name`: 의도한 이름으로 저장됐는가
- `publishedon`: `null`이면 한 번도 게시되지 않음
- `botid`: 기록한 ID와 일치하는가

## 3. Workflow 정의 원본 확인

먼저 대상 workflow의 ID를 찾습니다.

```bash
curl -fsS -H "Authorization: Bearer ${TOK}" \
  "$DV/api/data/v9.2/workflows?\$select=name,workflowid,statecode&\$filter=contains(name,'Classify Issue')" \
| python3 -c "
import json,sys
for w in json.load(sys.stdin)['value']:
    print(w['name'], w['workflowid'], w['statecode'])
"
```

출력에서 확인할 ID를 선택합니다.

```bash
ID=<workflow-id>

curl -fsS -H "Authorization: Bearer ${TOK}" \
  "$DV/api/data/v9.2/workflows(${ID})?\$select=name,clientdata" \
| python3 -c "
import json,sys
row=json.load(sys.stdin)
cd=json.loads(row['clientdata'])
d=cd.get('properties',cd).get('definition',cd.get('definition',{}))
print('WORKFLOW',row['name'])
for k,v in d.get('triggers',{}).items():
    print('TRIGGER',k,v.get('type'),'kind=',v.get('kind'))
for k,v in d.get('actions',{}).items():
    print('ACTION ',k,v.get('type'))
    print('   ',json.dumps(v.get('inputs'),ensure_ascii=False)[:500])
"
```

반드시 확인할 내용:

1. 트리거 `kind`가 `Skills`인지
2. 모든 식이 `@{...}` 또는 `@...`로 시작하는지
3. Response `properties`의 `title`이 agent에서 사용할 출력 이름과 일치하는지
4. Response `body`가 상수가 아니라 `@{outputs(...)}`를 반환하는지
5. `outputs('...')`가 실제 내부 노드 이름을 참조하는지

## 4. 실행 이력 확인

3장에서 선택한 `ID`를 그대로 사용합니다.

```bash
TOK=$(az account get-access-token --resource "https://service.flow.microsoft.com/" \
      --query accessToken -o tsv)

curl -fsS -H "Authorization: Bearer ${TOK}" \
  "https://api.flow.microsoft.com/providers/Microsoft.ProcessSimple/environments/${ENV}/flows/${ID}/runs?api-version=2016-11-01" \
| python3 -c "
import json,sys
from datetime import datetime
for r in json.load(sys.stdin)['value']:
    p=r['properties']
    f='%Y-%m-%dT%H:%M:%S.%f'
    s=datetime.strptime(p['startTime'][:26],f)
    e=datetime.strptime(p['endTime'][:26],f)
    print(r['name'],p['status'],f'{(e-s).total_seconds()*1000:.0f}ms')
"
```

포털의 Activity 패널이 열리지 않아도 Run ID, 상태, 소요 시간을 확인할 수 있습니다.

## 5. DLP 정책 확인

```bash
TOK=$(az account get-access-token --resource "https://api.bap.microsoft.com/" \
      --query accessToken -o tsv)

curl -fsS -H "Authorization: Bearer ${TOK}" \
  "https://api.bap.microsoft.com/providers/PowerPlatform.Governance/v2/policies?api-version=2020-10-01" \
  -o policies.json
```

환경에 적용되는 정책을 찾는 규칙:

| `environmentType` | 적용 조건 |
| --- | --- |
| `AllEnvironments` | 항상 적용 |
| `OnlyEnvironments` | 목록에 대상 환경이 있으면 적용 |
| `ExceptEnvironments` | 목록에 대상 환경이 없으면 적용 |

정책 ID를 찾은 뒤 상세를 확인합니다.

```bash
POLICY_ID=<policy-id>

curl -fsS -H "Authorization: Bearer ${TOK}" \
  "https://api.bap.microsoft.com/providers/PowerPlatform.Governance/v2/policies/${POLICY_ID}?api-version=2020-10-01" \
| python3 -m json.tool
```

`defaultConnectorsClassification`과 `PvaSkills`의 분류를 확인하세요.
해제 절차와 관리자 요청 템플릿은
[`ROLES_AND_PERMISSIONS.md` 6장](ROLES_AND_PERMISSIONS.md#6-dlp-심화-차단된-connector-해제)에 있습니다.

## 6. API로 확인할 수 없는 항목

| 항목 | 대안 |
| --- | --- |
| Flow checker 결과 | 3장의 정의 원본에서 식과 내부 이름 점검 |
| agent → flow end-to-end 응답 | Test 또는 Preview에서 실제 대화 실행 |
| DLP 차단 화면의 오류 문구 | 게시 시도 후 포털에서 확인 |

## 7. 완료 체크리스트

- [ ] Agent 이름과 게시 상태가 의도와 일치한다
- [ ] Workflow 수와 ID가 예상과 일치한다
- [ ] 모든 식에 `@` 접두사가 있다
- [ ] Response가 앞 노드의 계산 결과를 반환한다
- [ ] Response `title`과 agent의 출력 변수 이름이 일치한다
- [ ] 서로 다른 입력에서 출력이 달라진다
- [ ] 최근 실행 상태가 `Succeeded`다

## 관련 문서

- 실습 절차: [`PORTAL_CREATION_GUIDE.md`](PORTAL_CREATION_GUIDE.md)
- 역할·권한·DLP: [`ROLES_AND_PERMISSIONS.md`](ROLES_AND_PERMISSIONS.md)
- 실행 기록: [`ACCOUNT_PERMISSION_INVENTORY.md`](ACCOUNT_PERMISSION_INVENTORY.md)
