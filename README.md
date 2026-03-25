# Allowlist Browser

A Flutter web browser that only permits navigation to websites on a configurable allowlist. Any attempt to visit a site not on the list shows a friendly blocked page instead.

## Features

- 🌐 Built-in WebView browser (uses `webview_flutter`)
- ✅ JSON-based allowlist — easy to edit
- 🚫 Blocked page shown for non-allowlisted URLs
- 🔍 Address bar with URL validation before navigation
- ➕ Add/remove sites from allowlist at runtime
- 📱 Works on iOS and Android

## Getting Started

### Prerequisites

- Flutter SDK (3.x or later)
- Dart SDK
- Xcode (for iOS) or Android Studio (for Android)

### Installation

```bash
git clone https://github.com/Snapples-0/allowlist-browser.git
cd allowlist-browser
flutter pub get
flutter run
```

## Allowlist Configuration

Edit `assets/allowlist.json` to add or remove allowed domains:

```json
{
  "allowed_domains": [
    "google.com",
    "github.com",
    "flutter.dev"
  ]
}
```

The browser matches by **domain** — subdomains are included automatically (e.g. `github.com` also allows `gist.github.com`).

## Project Structure

```
lib/
  main.dart              # App entry point
  browser_screen.dart    # Main browser UI
  allowlist_service.dart # Allowlist loading & checking logic
  blocked_screen.dart    # Shown when a site is blocked
assets/
  allowlist.json         # The allowlist configuration file
```

## License

MIT
