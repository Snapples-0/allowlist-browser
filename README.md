# Allowlist Browser (Kids Safe Browser)

A Flutter web browser designed for kids. It only permits navigation to websites on a **server-side allowlist** managed remotely by a parent. Any attempt to visit a site not on the list shows a blocked page. Parents can add or remove domains in real time from any device without touching the kid's phone.

## Features

- 🌐 Built-in WebView browser
- ✅ Server-side allowlist stored in **Firebase Firestore** — cannot be edited on-device
- ⚡ Real-time updates — changes by the parent reflect instantly on the kid's device
- 📵 Offline support — last fetched list is cached locally (read-only)
- 🚫 Blocked page shown for any non-allowlisted URL
- 🔒 Parent admin panel protected by **Firebase Auth** (email/password)
- 🔍 Strict exact-match domain checking — subdomains must be listed explicitly
- 📱 Works on iOS and Android

## Architecture

```
Firebase Firestore
  └── config/allowlist
        └── allowed_domains: ["github.com", "wikipedia.org", ...]

Kid's Device (Flutter app)
  ├── Fetches allowlist from Firestore on launch
  ├── Listens for real-time changes (StreamSubscription)
  ├── Caches list locally via SharedPreferences (offline fallback)
  └── Blocks any URL not in the list

Parent (any device / browser)
  └── Opens Parent Controls screen → logs in → add/remove domains
```

## Getting Started

### 1. Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/) and create a new project.
2. Enable **Firestore Database** (start in production mode).
3. Enable **Authentication** → Email/Password provider.
4. Create a parent account under Authentication → Users.
5. In Firestore, create a document at path `config/allowlist` with a field:
   ```
   allowed_domains: [] (array)
   ```
6. Add the `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) from Firebase to your project.

### 2. Firestore Security Rules

Paste these rules in Firestore → Rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /config/allowlist {
      // Anyone can read (the kid's device fetches it)
      allow read: if true;
      // Only authenticated parents can write
      allow write: if request.auth != null;
    }
  }
}
```

### 3. Run the App

```bash
git clone https://github.com/Snapples-0/allowlist-browser.git
cd allowlist-browser
flutter pub get
flutter run
```

## How the Parent Controls Work

1. Tap the **shield icon** (top right) in the browser.
2. Log in with the parent email/password set up in Firebase Auth.
3. Add or remove domains — changes are saved to Firestore instantly.
4. The kid's browser updates in real time without any restart.

## Domain Matching

The browser uses **strict exact-match** — subdomains are not allowed automatically. Each domain must be listed explicitly:

```json
["github.com", "gist.github.com"]
```

## Project Structure

```
lib/
  main.dart                # App entry point + Firebase init
  browser_screen.dart      # Main browser UI (no local allowlist editor)
  allowlist_service.dart   # Firestore listener + offline cache
  blocked_screen.dart      # Shown when a site is blocked
  parent_auth_service.dart # Firebase Auth sign-in/out
  parent_admin_screen.dart # Parent login + domain management UI
```

## License

MIT
