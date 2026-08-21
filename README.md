# Unimate

Cross-platform student productivity, routine, attendance, and study companion built with Flutter.

## Run locally

```bash
flutter pub get
flutter run
```

## Architecture

- Riverpod state containers and repository boundary ready for local/cloud persistence.
- Feature-first screens, typed domain models, adaptive Material 3 UI.
- English/Arabic locale switching with RTL support.
- Notifications, exports, backup, and platform integrations live behind services so unsupported platforms degrade safely.

## Android APK CI

Push to `main`; GitHub Actions builds a release APK and uploads it as `unimate-release-apk`.

> DND access and home-screen widgets need platform-specific user approval / native widget registration. The app gracefully opens notification policy access for DND.

