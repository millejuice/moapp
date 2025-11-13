# Firebase 설정 가이드

이 프로젝트를 실행하기 위해 Firebase 프로젝트를 설정해야 합니다.

## 1. Firebase 프로젝트 생성

1. [Firebase Console](https://console.firebase.google.com/)에 접속
2. "프로젝트 추가" 클릭
3. 프로젝트 이름 입력 및 설정 완료

## 2. Firebase Authentication 설정

1. Firebase Console에서 **Authentication** 메뉴로 이동
2. **Sign-in method** 탭 클릭
3. 다음 인증 방법 활성화:
   - **Google**: 활성화하고 프로젝트 지원 이메일 설정
   - **Anonymous**: 활성화

## 3. Cloud Firestore 설정

1. Firebase Console에서 **Firestore Database** 메뉴로 이동
2. **데이터베이스 만들기** 클릭
3. **프로덕션 모드에서 시작** 선택 (나중에 Security Rules 설정 필요)
4. 위치 선택 (가장 가까운 리전 선택)

### Firestore Security Rules 설정

Firestore Console의 **규칙** 탭에서 다음 규칙을 설정하세요:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Products collection
    match /products/{productId} {
      // Anyone can read
      allow read: if true;
      
      // Only authenticated users can create
      allow create: if request.auth != null;
      
      // Only the creator can update or delete
      allow update, delete: if request.auth != null 
        && request.auth.uid == resource.data.creatorUid;
    }
  }
}
```

## 4. Firebase Storage 설정

1. Firebase Console에서 **Storage** 메뉴로 이동
2. **시작하기** 클릭
3. 기본 보안 규칙 사용 (나중에 수정 필요)
4. 위치 선택 (Firestore와 동일한 리전 권장)

### Storage Security Rules 설정

Storage Console의 **규칙** 탭에서 다음 규칙을 설정하세요:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Products images
    match /products/{productId}.jpg {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Default images
    match /default/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## 5. Flutter 앱에 Firebase 추가

### Android 설정

1. Firebase Console에서 프로젝트 설정으로 이동
2. **내 앱** 섹션에서 Android 앱 추가
3. Android 패키지 이름 입력 (예: `com.example.shrine`)
4. `google-services.json` 파일 다운로드
5. `android/app/` 디렉토리에 `google-services.json` 파일 복사

### iOS 설정

1. Firebase Console에서 프로젝트 설정으로 이동
2. **내 앱** 섹션에서 iOS 앱 추가
3. iOS 번들 ID 입력
4. `GoogleService-Info.plist` 파일 다운로드
5. Xcode에서 `ios/Runner/` 디렉토리에 `GoogleService-Info.plist` 파일 추가

## 6. Android 빌드 설정

`android/app/build.gradle` 파일에 다음을 추가:

```gradle
dependencies {
    // ... 기존 dependencies
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
}
```

`android/build.gradle` 파일에 다음을 추가:

```gradle
buildscript {
    dependencies {
        // ... 기존 dependencies
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

`android/app/build.gradle` 파일 상단에 다음을 추가:

```gradle
apply plugin: 'com.google.gms.google-services'
```

## 7. iOS 빌드 설정

`ios/Podfile`에 다음이 있는지 확인:

```ruby
platform :ios, '12.0'
```

터미널에서 다음 명령 실행:

```bash
cd ios
pod install
cd ..
```

## 8. 패키지 설치

프로젝트 루트에서 다음 명령 실행:

```bash
flutter pub get
```

## 9. 앱 실행

```bash
flutter run
```

## 주의사항

1. **최소 6개의 상품 생성**: 앱을 실행한 후 최소 6개의 상품을 추가하세요 (각각 다른 가격으로)
2. **이미지 업로드**: 상품 이미지는 Firebase Storage에 저장됩니다
3. **인증 상태**: 로그아웃 후 다시 로그인해도 좋아요 상태가 유지됩니다
4. **권한**: 본인이 작성한 상품만 수정/삭제할 수 있습니다

## 문제 해결

- **Firebase 초기화 오류**: `google-services.json` 또는 `GoogleService-Info.plist` 파일이 올바른 위치에 있는지 확인
- **인증 오류**: Firebase Console에서 Authentication이 활성화되어 있는지 확인
- **Storage 업로드 오류**: Storage Security Rules가 올바르게 설정되어 있는지 확인
- **Firestore 읽기/쓰기 오류**: Firestore Security Rules가 올바르게 설정되어 있는지 확인

