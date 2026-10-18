# HealthMate

Flutter coursework app for manually recording steps walked, calories burned and water intake.

## Screens

- Dashboard: today's date and totals for steps, calories and water.
- History: saved records, date filter, edit and delete actions.
- Add/Edit record: date and three numeric inputs with validation.

The header sun/moon button switches between light and dark mode for the current session. Enter test records through Add record. Multiple records on one date are added together.

## Run in VS Code

Open this folder, select the Android emulator, select the **HealthMate** launch configuration and press **F5**. Flutter and Dart extensions are required. The Windows pre-launch task directs generated build files outside OneDrive; source stays on the Desktop. After `flutter clean`, F5 recreates the build junction automatically.

From a terminal, first run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/prepare_build_cache.ps1`, then:

```powershell
flutter pub get
flutter run
flutter analyze
flutter test
flutter build apk --release
```

The packaged release is `dist/HealthMate-1.0.0.apk`. `scripts/build_release.ps1` can also build in a temporary directory. The coursework APK uses a development signing key; production distribution requires private release signing.

## Implementation

Feature-based MVVM with Provider/ChangeNotifier and a sqflite repository. The SQLite health_records table contains id, date, steps, calories and water, plus a sample-data flag so samples can be removed safely. Records persist on the device. Database version 2 removes the previous optional preferences table without deleting health records.

Source: `lib/`; automated tests: `test/`; Android workflow: `integration_test/`. See `docs/TECHNICAL_GUIDE.md`, `docs/TEST_CASES.md` and `docs/SUBMISSION_CHECKLIST.md` for assessment preparation. iOS scaffolding is included but requires macOS/Xcode to build and test.

The brief requires disclosure of AI assistance. Keep an accurate acknowledgement, understand the implementation and explain your own review/modifications. Git history is retained as the actual development record.
