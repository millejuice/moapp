# 구현 완료 사항

이 프로젝트에 이미지에서 요구된 모든 기능이 구현되었습니다.

## 구현된 기능

### 1. Login Page (로그인 페이지)
- ✅ Google Sign-in 버튼 (빨간색 버튼, G 아이콘)
- ✅ Anonymous Login (Guest) 버튼 (회색 버튼, ? 아이콘)
- ✅ Firebase Authentication 연동
- ✅ 로그인 후 자동으로 Home 페이지로 이동

### 2. Home Page (메인 페이지)
- ✅ Dropdown Selector로 가격 정렬 (ASC/DESC)
- ✅ Product 카드 표시 (이미지, 이름, 가격)
- ✅ "more" 버튼으로 Detail 페이지 이동
- ✅ AppBar에 Profile 아이콘 (왼쪽)
- ✅ AppBar에 Add 아이콘 (오른쪽)
- ✅ Firebase Firestore에서 실시간 데이터 로드

### 3. Add Product Page (상품 추가 페이지)
- ✅ 이미지 선택 기능 (image_picker 사용)
- ✅ 기본 이미지 표시 (Handong 로고)
- ✅ 이미지 미선택 시 기본 이미지 저장
- ✅ Firebase Storage에 이미지 업로드
- ✅ 상품명, 가격, 설명 입력
- ✅ Firebase Firestore에 상품 저장
- ✅ Cancel/Save 버튼

### 4. Detail Page (상품 상세 페이지)
- ✅ 상품 이미지, 이름, 가격, 설명 표시
- ✅ 좋아요 버튼 (thumb_up 아이콘)
  - ✅ 첫 클릭 시 좋아요 +1, "I LIKE IT!" SnackBar
  - ✅ 중복 클릭 방지, "You can only do it once !!" SnackBar
  - ✅ 사용자별로 한 번만 좋아요 가능
  - ✅ 로그아웃/재로그인 후에도 상태 유지
- ✅ 수정 기능 (연필 아이콘)
  - ✅ 작성자만 수정 가능
  - ✅ 이미지, 이름, 가격, 설명 수정
- ✅ 삭제 기능 (휴지통 아이콘)
  - ✅ 작성자만 삭제 가능
- ✅ 메타데이터 표시
  - ✅ creator UID
  - ✅ 생성 시간 (Created)
  - ✅ 수정 시간 (Modified)
  - ✅ FieldValue.serverTimestamp() 사용

### 5. Profile Page (프로필 페이지)
- ✅ 로그인 정보 표시
  - ✅ 프로필 사진 (Google: 실제 사진, Anonymous: 기본 이미지)
  - ✅ UID 표시
  - ✅ Email 표시 (Google: 실제 이메일, Anonymous: "Anonymous")
  - ✅ 이름 표시
- ✅ 로그아웃 기능 (exit_to_app 아이콘)
  - ✅ 로그아웃 후 Login 페이지로 이동
- ✅ Honor Code 표시: "I promise to take the test honestly before GOD."

## 파일 구조

```
lib/
├── main.dart                    # Firebase 초기화 및 앱 시작
├── app.dart                     # 라우팅 및 인증 상태 관리
├── login.dart                   # 로그인 페이지
├── home.dart                    # 메인 페이지 (상품 목록)
├── add_product_page.dart        # 상품 추가 페이지
├── detail_page.dart             # 상품 상세 페이지 (수정 포함)
├── profile_page.dart            # 프로필 페이지
├── model/
│   └── product.dart             # Product 모델 (Firestore 호환)
└── services/
    ├── auth_service.dart        # Firebase Authentication 서비스
    ├── firestore_service.dart   # Cloud Firestore 서비스
    └── storage_service.dart     # Firebase Storage 서비스
```

## Firebase 설정 필요 사항

자세한 설정 방법은 `FIREBASE_SETUP.md` 파일을 참조하세요.

### 필수 설정:
1. **Firebase 프로젝트 생성**
2. **Authentication 활성화**
   - Google Sign-in
   - Anonymous Sign-in
3. **Cloud Firestore 데이터베이스 생성**
   - Security Rules 설정 필요
4. **Firebase Storage 활성화**
   - Security Rules 설정 필요
5. **앱에 Firebase 추가**
   - Android: `google-services.json`
   - iOS: `GoogleService-Info.plist`

## Security Rules

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /products/{productId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null 
        && request.auth.uid == resource.data.creatorUid;
    }
  }
}
```

### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /products/{productId}.jpg {
      allow read: if true;
      allow write: if request.auth != null;
    }
    match /default/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## 실행 전 확인 사항

1. ✅ `flutter pub get` 실행하여 패키지 설치
2. ✅ Firebase 프로젝트 설정 완료
3. ✅ `google-services.json` (Android) 또는 `GoogleService-Info.plist` (iOS) 파일 추가
4. ✅ Firestore 및 Storage Security Rules 설정
5. ✅ 최소 6개의 상품 추가 (각각 다른 가격으로)

## 주요 기능 설명

### 좋아요 시스템
- 각 상품은 `likedBy` 배열에 좋아요를 누른 사용자 UID를 저장
- 사용자가 이미 좋아요를 누른 경우 다시 누를 수 없음
- 좋아요 수는 `likes` 필드에 저장
- 로그아웃 후 재로그인해도 좋아요 상태 유지

### 권한 관리
- 상품 수정/삭제는 작성자(creatorUid)만 가능
- Firestore Security Rules에서도 동일한 규칙 적용

### 이미지 처리
- 상품 이미지는 Firebase Storage에 저장
- 이미지 URL은 Firestore에 저장
- 기본 이미지는 Handong 로고 사용

## 테스트 체크리스트

- [ ] Google 로그인 테스트
- [ ] Anonymous 로그인 테스트
- [ ] 상품 추가 (이미지 포함)
- [ ] 상품 추가 (기본 이미지)
- [ ] 가격 정렬 (ASC/DESC)
- [ ] 상품 상세 보기
- [ ] 좋아요 기능 (첫 클릭)
- [ ] 좋아요 중복 방지
- [ ] 상품 수정 (작성자)
- [ ] 상품 수정 권한 확인 (비작성자)
- [ ] 상품 삭제 (작성자)
- [ ] 상품 삭제 권한 확인 (비작성자)
- [ ] 프로필 정보 표시
- [ ] 로그아웃 기능
- [ ] 로그아웃 후 재로그인 시 좋아요 상태 유지

