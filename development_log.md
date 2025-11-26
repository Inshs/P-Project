# 개발 작업 일지 (Development Log)

## 2025-11-26

### 1. 개발 환경 구축 (Troubleshooting)
- **이슈**: JDK 미설치, Flutter SDK 파일 손상, Visual Studio Build Tools 누락.
- **해결**:
  - `winget`으로 OpenJDK 17 설치.
  - `git checkout`으로 Flutter SDK 복구 및 캐시 정리.
  - Visual Studio 2022 Build Tools (C++ 워크로드) 설치.
- **결과**: `flutter doctor` 및 `flutter run -d windows` 정상 작동 확인.

### 2. 메인 홈 화면 (`lib/main.dart`)
- **기능**:
  - 앱 진입점(Entry Point) 설정.
  - 로그인 UI (아이디/비밀번호, 소셜 로그인 버튼).
  - "로그인 없이 시세 조회하기" 버튼 구현.
  - 하단 네비게이션 바 (내 차 찾기, 내 차 시세, 설정) UI 구성.

### 3. 차량 정보 입력 화면 (`lib/car_info_input_page.dart`)
- **기능**:
  - 브랜드, 모델, 연식 선택 (Dropdown).
  - 주행거리 입력 (TextField).
  - 연료 타입 및 상세 옵션(선루프, 내비게이션 등) 선택 UI.
  - "검색하기" 버튼을 통해 결과 화면으로 이동.

### 4. 시세 예측 결과 화면 (`lib/result_page.dart`)
- **구조**: 3개 탭(Tabs)으로 구성.
  1.  **가격 분석**: 신뢰도 및 가격 분포 그래프(Placeholder).
  2.  **구매 타이밍**: 구매 적기 신호등 UI, 타이밍 지표(거시경제, 트렌드 등).
  3.  **AI 조언**: 상세 분석 텍스트, 허위매물 위험도, 문자 복사/전화 대본 기능.
- **특이사항**:
  - `fl_chart` 라이브러리가 Windows 빌드 환경에서 충돌을 일으켜, 안정적인 실행을 위해 임시로 제거하고 Placeholder UI로 대체함.

---
**현재 상태**:
- Windows 데스크톱 환경에서 앱 빌드 및 실행 가능.
- 화면 이동 흐름: `Home` -> `Input` -> `Result` 정상 작동.

### 5. 네고 도우미 화면 (`lib/negotiation_page.dart`)
- **기능**:
  - **협상 포인트 점검**: 타이어 마모, 가격 등 체크리스트 UI.
  - **모드 전환**: 문자 전송 / 전화 통화 탭(Segmented Control).
  - **문자 모드**: 협상 메시지 텍스트 및 클립보드 복사 기능.
  - **전화 모드**: 1~3단계별 통화 대본 및 꿀팁 UI.
- **연결**: 결과 화면의 "문자 복사", "전화 대본 보기" 버튼과 연동.

### 6. 마이페이지 및 네비게이션 개선
- **마이페이지 (`lib/mypage.dart`)**:
  - **탭 구조**: 찜한 차량 / 최근 분석.
  - **리스트 UI**: 차량 이미지, 정보, 가격, 알림/좋아요 아이콘 카드 구현.
  - **상호작용**: 좋아요(하트) 버튼 클릭 시 '찜한 차량' 목록에 자동 반영되도록 상태 관리(`StatefulWidget`) 구현. 알림 버튼 토글 기능 추가.
- **메인 화면 (`lib/main.dart`)**:
  - **네비게이션 활성화**: `BottomNavigationBar`와 `IndexedStack`을 연동하여 탭 전환 기능 구현.
  - **탭 구성 변경**: [홈, 내 차 찾기, 마이페이지, 설정] 순서로 재구성.

### 7. 설정 화면 및 다크 모드 구현
- **설정 화면 (`lib/settings_page.dart`)**:
  - **UI**: 일반(다크모드, 알림), AI 엔진(API 키), 지원 및 정보(기록 삭제, 문의, 버전) 섹션 구현.
- **다크 모드 (`lib/main.dart`)**:
  - **상태 관리**: `ThemeMode`를 최상위 `StatefulWidget`에서 관리.
  - **테마 적용**: `ThemeData.light()`와 `ThemeData.dark()`를 정의하고, `SettingsPage`의 스위치와 연동.
  - **홈 화면 대응**: 홈 화면의 카드 및 텍스트 색상이 다크 모드 상태에 따라 동적으로 변경되도록 수정.
  - **전체 화면 적용**: `CarInfoInputPage`, `MyPage`, `ResultPage`, `NegotiationPage`의 하드코딩된 색상을 제거하고, `Theme.of(context)`를 사용하여 다크 모드 시 배경색, 텍스트 색상, 카드 색상이 올바르게 변경되도록 수정.

### 2025-11-26
- **GitHub 업로드**: 현재까지 작업한 모든 파일 및 변경 사항을 원격 저장소(`origin/main`)에 푸시 완료.

### 8. 차량 상세 페이지 (`lib/car_detail_page.dart`)
- **기능**:
  - **헤더**: 뒤로가기, 공유, 찜하기 버튼이 있는 커스텀 AppBar.
  - **차량 정보**: 이미지 슬라이더(Placeholder), 핵심 정보(가격, 연식, 주행거리), 상세 스펙 그리드.
  - **판매자 정보**: 판매자 프로필 및 연락처 버튼(전화, 문자).
  - **네고 도우미 연동**: 하단 FAB 버튼을 통해 `NegotiationPage`로 이동.
- **데이터 모델**: `CarData` 클래스를 `lib/models/car_data.dart`로 분리하여 재사용성 확보.
- **네비게이션**:
  - `HomePage`의 추천 차량 리스트 및 `MyPage`의 찜한/최근 차량 리스트에서 상세 페이지로 이동하도록 연동.

### 9. 다크 모드 고도화 및 버그 수정
- **전체 적용**: `CarDetailPage`를 포함한 모든 신규 페이지에 다크 모드(`Theme.of(context)`) 완벽 지원.
- **UI 개선**: 텍스트 가독성 확보를 위해 다크 모드 시 색상 대비 조정.

### 10. 차량 비교 페이지 (`lib/comparison_page.dart`)
- **기능**:
  - **비교함 관리**: `ComparisonProvider`를 통해 최대 3대의 차량을 비교함에 추가/삭제.
  - **상단 고정 헤더**: 스크롤 시에도 차량 기본 정보(이미지, 모델명, 가격)를 상단에 고정하여 비교 편의성 제공.
  - **데이터 시각화**:
    - **가격 분석**: 막대 그래프와 애니메이션(`TweenAnimationBuilder`)을 통해 차량별 시세 비교.
    - **감가율 예측**: `CustomPainter`를 활용하여 연도별 감가율 곡선 시각화.
  - **옵션 비교**: 주요 옵션 유무를 O/X로 직관적으로 비교.
- **연동**:
  - `MyPage`의 '비교하기' 버튼 및 `CarDetailPage`의 '비교함 담기' 버튼과 연동.
- **버그 수정 및 최적화**:
  - `flutter analyze`를 통해 모든 Lint 오류 및 문법 에러 해결.
  - `CarDetailPage`의 '좋아요' 버튼 로직을 별도 위젯(`_LikeButton`)으로 분리하여 상태 관리 오류 수정.
