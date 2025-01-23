```markdown
# AnglerDiary

AnglerDiary는 **Angler**라는 이름의 선언형 네트워크 라이브러리를 사용하여 만든 낚시 기록 관리 앱입니다. 이 앱은 사용자가 낚시 활동을 손쉽게 기록하고 관리할 수 있도록 도와줍니다. **낚시 장소**, **날짜**, **미끼 종류**, **날씨 정보** 등 중요한 데이터를 기록하고, **낚시 장비 관리**, **동출 정보** 등을 관리할 수 있는 기능을 제공합니다.

이 프로젝트는 **선언형 UI**와 **선언형 네트워크 통신**을 결합하여 효율적인 코드 작성과 유연한 기능 확장을 목표로 개발되었습니다.

## 기능

- **낚시 기록 관리**: 사용자는 낚시 활동에 대한 기록을 손쉽게 입력하고 관리할 수 있습니다. 날짜, 장소, 미끼 종류 등 중요한 정보를 포함합니다.
- **날씨 정보 연동**: 사용자가 기록한 낚시 활동에 대해 날씨 정보를 자동으로 조회하여 기록에 포함시킬 수 있습니다.
- **낚시 장비 관리**: 사용하는 낚시 장비를 관리하고, 각 장비의 상태나 위치를 기록할 수 있습니다.
- **동출 관리**: 친구나 동료와 함께 낚시를 했을 때 동출자와의 기록을 함께 저장하고 관리할 수 있습니다.
- **데이터 필터링**: 날짜, 장소, 미끼 종류 등을 기준으로 낚시 기록을 필터링하고 쉽게 검색할 수 있습니다.

## 설치

프로젝트를 로컬에 클론하여 사용하려면 아래와 같은 명령어를 통해 설치할 수 있습니다:

```bash
git clone https://github.com/AidenJLee/AnglerDiary.git
cd AnglerDiary
```

필요한 의존성은 `SPM (Swift Package Manager)`을 사용하여 설치할 수 있습니다.

```bash
swift package resolve
```

이제 프로젝트를 Xcode에서 열고 실행할 수 있습니다.

## 사용법

1. **앱 실행**: Xcode에서 `AnglerDiary.xcodeproj` 또는 `AnglerDiary.xcworkspace` 파일을 열고, 시뮬레이터 또는 실제 디바이스에서 실행합니다.
2. **낚시 기록 추가**: 앱 내에서 "새 기록 추가" 버튼을 통해 낚시 활동을 기록합니다. 이때, 장소, 미끼 종류, 날짜 등을 입력할 수 있습니다.
3. **날씨 정보 조회**: 사용자가 기록한 낚시 장소에 맞춰 실시간 날씨 정보를 자동으로 조회하고, 해당 정보를 기록에 첨부할 수 있습니다.
4. **네트워크 요청**: Angler 네트워크 라이브러리를 통해 서버와의 데이터 통신을 선언형 방식으로 처리합니다.


## 프로젝트 배경

이 프로젝트는 개인 취미인 낚시와 관련된 데이터 관리의 필요성을 느껴 시작되었습니다. 낚시 활동과 관련된 정보는 매우 다양하고, 이를 관리하고 기록하는 것이 어려운 점이 있었습니다. 특히 날씨 정보, 낚시 장비 상태, 동출자 기록 등을 통합적으로 관리할 수 있는 시스템이 부족하다고 느꼈습니다. 이를 해결하기 위해 **Angler** 네트워크 라이브러리를 사용하여 서버와의 통신을 선언형으로 구현하고, 낚시 관련 모든 정보를 한곳에서 관리할 수 있는 앱을 만들었습니다.

## 기여

기여를 원하시면, 이 리포지토리를 포크한 후 풀 리퀘스트를 보내주세요. 새로운 기능 추가, 버그 수정, 개선사항 제안 등 다양한 기여를 환영합니다! 기여 시, 반드시 `기여 가이드라인`을 참고해 주세요.

## 라이선스

이 프로젝트는 [MIT 라이선스](LICENSE) 하에 배포됩니다.
```
