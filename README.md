# Mathspro

Mathspro is a small, fun Flutter math quiz app. It lets you choose the quiz setup (questions, time limit, operation, difficulty), then generates questions with the right number of digits per difficulty. Answers are validated, feedback is shown with a quick slide animation to the next question, and a results sheet summarizes your score and mistakes. Results are saved locally so you can review previous runs.

**Highlights**
- First‑time name capture and a friendly splash screen
- Main menu to configure quiz:
  - Questions: 1–100
  - Time limit: Unlimited or per‑question seconds
  - Operation: Addition, Subtraction, Multiplication, Division, or All
  - Difficulty: Easy, Medium, Hard, Extreme
- Question rules by difficulty
  - Base digit sizes for operands per difficulty
  - Subtraction always non‑negative (no negative results)
  - Division always exact integer division with controlled digit sizes:
    - Easy: 3/1 digits, Medium: 3/2, Hard: 4/2, Extreme: 5/2 or 6/2
  - Multiplication digit patterns:
    - Easy: 3×1 or 4×1 or 5×1
    - Medium: 3×2 or 4×2
    - Hard: 4×3 or 5×3
    - Extreme: 5×3 or 6×3 or 7×3
- Numeric‑only input with an inline red error if invalid
- Hold‑to‑Submit: press and hold a circular button for ~1s to submit
- Slide animation to the next question with “Correct/Incorrect” feedback
- End‑of‑quiz bottom sheet with:
  - Score, percentage, and a friendly remark
  - Review of incorrect answers (your answer vs correct)
  - Button to open Previous Results
- History page (top‑right history icon on the home screen) listing all runs

**Tech**
- Flutter (Material 3, dark/AMOLED‑friendly palette)
- Local persistence via `shared_preferences` (no backend required)

---

**Project Structure**
- `lib/main.dart` — App entry and global theme
- `lib/splash_screen.dart` — Splash + first‑time name routing
- `lib/name_entry_screen.dart` — Name capture and save
- `lib/main_screen.dart` — Quiz setup (home screen)
- `lib/game_screen.dart` — Quiz logic, animations, results saving
- `lib/history_screen.dart` — Previous results list (expand to review mistakes)
- `pubspec.yaml` — Dependencies and optional assets/icon configuration

---

**Requirements**
- Flutter 3.x SDK installed and on your PATH
- Android Studio or Android SDK + an emulator or a connected device

---

**Run The App (Debug)**
- `flutter pub get`
- `flutter run`

If you have multiple devices, add `-d <device_id>`.

---

**Build APKs**
- Debug APK:
  - `flutter build apk --debug`
  - Output: `build/app/outputs/flutter-apk/app-debug.apk`
- Release APK (unsigned; fine for side‑loading):
  - `flutter build apk --release`
  - Smaller per‑ABI APKs:
    - `flutter build apk --release --split-per-abi`
    - Outputs: `app-arm64-v8a-release.apk`, `app-armeabi-v7a-release.apk`, `app-x86_64-release.apk`
- Google Play App Bundle:
  - `flutter build appbundle`
  - Output: `build/app/outputs/bundle/release/app-release.aab`

> Note: If you see an assets error, either add the referenced files or comment them out in `pubspec.yaml`.

---

**App Icon & Name**
- Display name (Android): set in `android/app/src/main/AndroidManifest.xml` (`android:label="Mathspro"`).
- App icon (optional):
  - Place your icon at `assets/logo.png`.
  - Uncomment the `assets:` entry in `pubspec.yaml`.
  - Generate launcher icons:
    - `flutter pub get`
    - `dart run flutter_launcher_icons`
  - Rebuild and reinstall the app.

---

**Troubleshooting**
- Assets missing: ensure the file path exists, the name matches case‑sensitively, and YAML indentation is correct under `flutter:`.
- NDK errors: this project doesn’t require the NDK by default. If a plugin does, install the required NDK via Android Studio’s SDK Manager.
- Stale build after changes: `flutter clean && flutter pub get && flutter run`.

---

**License**
This project is provided as‑is for learning and personal use. Add a license here if you plan to publish/distribute.
