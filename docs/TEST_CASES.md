# HealthMate test evidence

Environment: Flutter 3.47.4, Dart 3.13.3, Windows host, 18 October 2026. Automated tests run against actual SQLite through sqflite_common_ffi, a ViewModel fake repository, and Flutter widgets. These are not all physical-device tests.

| ID | Scenario | Input | Expected result | Actual result | Status |
|---|---|---|---|---|---|
| TC01 | SQLite CRUD | 1000 steps/80 kcal/250 ml; update to 2000/100/500; delete | Insert receives id, update persists, delete removes | Assertions passed | PASS |
| TC02 | Domain validation | Negative, over-limit, all-zero and future-dated entries | Rejected; no row inserted | Assertions passed | PASS |
| TC03 | Demo isolation | One personal row; load demo twice; remove demo | 15 rows after refresh, personal row remains after removal | Assertions passed | PASS |
| TC04 | Disk persistence | Save row and dark theme/2500 ml goal; close/reopen DB | Same row and settings recovered | Assertions passed | PASS |
| TC05 | Schema constraints | Direct negative insert and zero goal | SQLite rejects writes | Assertions passed | PASS |
| TC06 | Aggregation | Two today rows, one yesterday row | Today = 300 steps/30 kcal/750 ml, 2 active days | Assertions passed | PASS |
| TC07 | Date filters | Entries 16–18 Oct; inclusive range and exact date | 2 rows in range, 1 exact-day row, 3 after clear | Assertions passed | PASS |
| TC08 | Storage failure | Simulated repository failure, then retry | Error shown, no mutation, busy resets; retry succeeds | Assertions passed | PASS |
| TC09 | Number parsing | Empty, decimal, text, negative, over-limit; 0 and padded 100 | Invalid rejected; 0 and 100 accepted | Assertions passed | PASS |
| TC10 | Calendar rollover | Entry 31 Dec; clock advances to 1 Jan | New-day total 0; previous entry in 7-day window, streak retained | Assertions passed | PASS |
| TC11 | UI workflow | All-zero form, valid add, edit, cancel delete, confirm delete | Validation, saved changes and correct cancellation/deletion | Assertions passed | PASS |
| TC12 | Accessible layout | 360 × 800 logical screen, 1.3 text scale, all tabs | No Flutter overflow exceptions | Assertions passed after app-bar fix | PASS |

Reproduce with `flutter test --reporter expanded`. Run `flutter analyze` for static analysis. Latest observed result: no analyzer issues and all 12 tests passed before the final documentation stage. See final verification logs for the final source state.

## Additional manual/device checks

The Android integration suite is in integration_test/app_test.dart. Run:

```powershell
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d emulator-5554
```

It loads sample records, navigates the main screens, saves a personal entry and deletes that entry through the visible UI. Screenshot output is docs/screenshots when the device run succeeds.

For report evidence, also perform these checks on the release APK and record actual results: force-stop/reopen persistence; portrait/landscape; Android back navigation and unsaved form confirmation; large text in forms; no internet connection; save goals and restart; exact-date picker with no results. iOS checks require an iOS device/simulator and are not verified on this Windows host.

UI images under docs/previews are explicitly labelled **Flutter widget renders using synthetic data**, not device screenshots. They are created by `flutter test test/ui_preview.dart` on Windows and use the installed Segoe UI font for readable host rendering. Android uses its platform fonts, so metrics may differ slightly.
