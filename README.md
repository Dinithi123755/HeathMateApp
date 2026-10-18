# HealthMate

An offline Flutter mobile application for recording steps walked, calories burned and water intake. The app uses a feature-based MVVM structure, Provider/ChangeNotifier state management and a real SQLite database through sqflite.

## Start in VS Code

1. Open this **healthmate** folder in Visual Studio Code.
2. Install the recommended Dart and Flutter extensions if needed.
3. Run `flutter pub get` in the VS Code terminal.
4. Start an Android emulator or connect an Android phone with USB debugging enabled.
5. Select the device in VS Code's status bar and press **F5** using the **HealthMate** launch configuration.

Flutter SDK on this computer: `C:\flutter`. Android is the verified build target. iOS scaffolding is included; building and testing iOS requires macOS and Xcode. This project does not target the browser or Windows desktop because its production database uses mobile sqflite.

```powershell
flutter analyze
flutter test --reporter expanded
flutter build apk --release
```

If the local Flutter batch launcher stalls, the installed Flutter tool can be invoked directly:

```powershell
& C:\flutter\bin\cache\dart-sdk\bin\dart.exe C:\flutter\bin\cache\flutter_tools.snapshot pub get
& C:\flutter\bin\cache\dart-sdk\bin\dart.exe C:\flutter\bin\cache\flutter_tools.snapshot run
```

## Included functionality

- Today dashboard with date, totals, goal progress and activity streak.
- Create, read, update and delete health entries, with confirmation before deletion.
- Exact-date and inclusive date-range filtering; newest records first.
- Form and domain validation, plus database CHECK constraints.
- SQLite persistence across restarts and transactional demo generation.
- Editable daily goals persisted in SQLite.
- 7-day and 30-day charts, calendar-day averages, active days and highest day.
- Light/dark appearance persisted across launches.
- Optional 14-day sample dataset; refreshing or removing it preserves personal entries.
- Responsive scrolling screens, semantic chart/metric labels and large-text layout checks.
- Unsaved form confirmation, disabled save controls while saving, loading, empty and error states.

Multiple entries on the same date are **added together**. Log either individual activities or a daily total; do not enter the same activity twice. All values are manually entered; there is no pedometer or automatic calorie estimation. Goals are configurable tracking preferences, not medical prescriptions.

## Project structure

```text
lib/
  main.dart                         Dependency construction and startup
  app.dart                          App theme, navigation and lifecycle
  core/data/health_database.dart    SQLite opening and schema
  core/theme/                       Material 3 light and dark themes
  core/widgets/                     Shared cards, states and dialogs
  features/
    records/domain/                 Immutable record models and validation
    records/data/                   Repository interface and SQLite adapter
    records/presentation/           ViewModel, history and add/edit form
    dashboard/presentation/         Today totals and goal cards
    insights/presentation/          Period statistics and accessible bars
    settings/domain/                Persistent settings model
    settings/presentation/          Goals, appearance, samples and about
test/                               Unit, SQLite and widget tests
integration_test/                   Android device workflow
docs/                               Technical guide and assessment checklist
```

## Data and privacy

Records are stored in the app-private `healthmate.db`. No login, cloud sync or health-data network requests are implemented. Android backup is disabled. Uninstalling the app removes its local database. Sample records are labelled DEMO and included in totals until removed. There is no export/backup feature in this version.

## Assessment preparation

Read `docs/TECHNICAL_GUIDE.md`, `docs/TEST_CASES.md` and `docs/SUBMISSION_CHECKLIST.md`. They describe the implemented design and the remaining student deliverables. Do not treat source code alone as a complete submission: the coursework also requires a PDF report, a public repository, Drive links and a video with your own narration.

The included local Git commits record actual implementation stages under a development identity. Configure your own Git identity for your subsequent work. Understand and adapt the code, and acknowledge AI assistance as required by the brief; do not claim generated work or automated tests as manually authored/performed work.

The packaged APK for this project is in `dist/HealthMate-1.0.0.apk`. If OneDrive locks Gradle output folders, run `./scripts/build_release.ps1` in the VS Code PowerShell terminal; it builds in a temporary folder and copies the APK back. Normal Flutter release output after a successful build: `build/app/outputs/flutter-apk/app-release.apk`. The default Flutter debug signing key is used for this coursework demonstration release. Production distribution requires a private release signing key and a suitable application ID.

## References

- Flutter architecture: https://docs.flutter.dev/app-architecture
- Flutter SQLite cookbook: https://docs.flutter.dev/cookbook/persistence/sqlite
- sqflite: https://pub.dev/packages/sqflite
- Provider: https://pub.dev/packages/provider
- intl: https://pub.dev/packages/intl

