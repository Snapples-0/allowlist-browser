# Firebase Setup Guide

This app requires a Firebase project with **Firestore** and **Authentication** enabled.

## 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **Add Project** → name it (e.g. `allowlist-browser`)
3. Disable Google Analytics if you don't need it → **Create Project**

## 2. Enable Firestore

1. In your project, go to **Build → Firestore Database**
2. Click **Create Database**
3. Choose **Start in test mode** (you can lock it down later)
4. Pick a region → **Enable**

## 3. Seed the Firestore Document

The app reads from `config/allowlist` with a field `allowed_domains` (array of strings).

1. In Firestore, click **Start collection** → Collection ID: `config`
2. Document ID: `allowlist`
3. Add a field:
   - Field: `allowed_domains`
   - Type: **array**
   - Add string values like `google.com`, `youtube.com`, etc.

## 4. Enable Email/Password Auth (for Parent Login)

1. Go to **Build → Authentication**
2. Click **Get Started**
3. Under **Sign-in method**, enable **Email/Password**
4. Go to **Users** tab → **Add user** → enter parent email + password

## 5. Register Your Android App

1. In Firebase Console → **Project Settings** (gear icon) → **Your apps**
2. Click the **Android icon** to add an Android app
3. Package name: `com.example.allowlist_browser`
   - (Check your `android/app/build.gradle` for the actual `applicationId`)
4. Download `google-services.json`
5. Place it at: `android/app/google-services.json`

## 6. Fill in `lib/firebase_options.dart`

**Option A — Auto (recommended):**
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
This auto-generates `lib/firebase_options.dart` for you.

**Option B — Manual:**
Open `lib/firebase_options.dart` and replace each `YOUR_*` placeholder with the
values from **Project Settings → Your apps → SDK setup and configuration**.

## 7. Firestore Security Rules (optional but recommended)

In Firestore → **Rules**, replace the default with:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Anyone can read the allowlist (the browser app needs this)
    match /config/allowlist {
      allow read: if true;
      // Only authenticated parents can write
      allow write: if request.auth != null;
    }
  }
}
```

## 8. Build & Run

```bash
flutter pub get
flutter run
```

Or to build the APK:
```bash
flutter build apk --release
```
