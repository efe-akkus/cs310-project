# SplitMate

Shared expenses, clear balances. CS310 Group 31.

## Step 2.2 status

Flutter UI implementation with 10 main screens and contextual panels. Authentication and group sharing are **local previews**; Firebase authentication, backend authorization and cross-device sync are planned for Step 3. The application does not transfer money. OCR is deferred.

## Run

Tested toolchain: **Flutter 3.47.5 stable / Dart 3.13.4**.

```sh
cd cs310_project
flutter pub get
flutter run
```

Select a running Android emulator or iOS simulator. On macOS, open Simulator before `flutter run` if needed. Internet is required for the city photo and map tiles; local images and the bundled font work offline. No API key or Firebase configuration is required for this UI preview.

Preview login: `efe.akkus@sabanciuniv.edu`, with any password of at least 8 characters. To test an outgoing repayment, sign in as `yunus@example.com`. Passwords are not authenticated or stored. Preview accounts and groups exist on this device only. Sign-up accepts a full name and creates a local preview identity. Do not treat this as a production account system.

Sample join code: **TRIP-7K2M**. Sign in with a different valid email to try joining. Resetting a code disables the previous code without removing existing members.

## Implemented

- Login and registration forms with inline validation and confirmation on registration.
- Group list, create, join preview/confirmation, member list and owner invite-code panel.
- Model-backed expense Cards with detail, edit and confirmed deletion; creator-only UI edit/delete.
- Equal splitting in integer minor units with deterministic rounding; recalculated balances and partial repayment records.
- Expense date, payer, selected participants and optional map location (pan/zoom/tap to select a pin).
- Profile name, optional HTTPS photo URL with initials fallback, optional IBAN checksum validation and copy in payment details.
- App-wide dark theme, shared widgets/styles/spacing, local receipt illustration, network city image and bundled Roboto font.
- Favorite groups and device-local persistence of preview records, profiles and appearance.

Location is selected on the map; GPS is not requested. The photo input currently uses a URL rather than device gallery upload. An IBAN is not required to save a profile or record a repayment. The signed-in debtor can record payments up to a suggested outstanding repayment. Editing/deleting an expense recomputes net balances, including existing settlement records.

## Checks

```sh
flutter analyze
flutter test
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_flow_test.dart -d <simulator-id>
```

All 56 unit/widget tests pass. They cover currency parsing, rounding, excluded payers, edits/deletions/partial settlements, full repayment and duplicate-payment rejection, invite membership, IBAN validation, profile updates across groups and local persistence. Widget tests exercise light/dark layouts at 320x568 and 430x932, including keyboard insets. The native integration test navigates the app and writes labeled screenshots into the ignored `screenshots/` directory. Screenshot tests use fresh sample state and do not modify stored user preview data.

## Team and member contributions

| Member | ID | Team-confirmed implementation responsibility |
| --- | --- | --- |
| Efe Çağan Akkuş | 32413 | Login, registration, profile, theme; AI-assisted baseline, integration and final tests |
| Emir Keskin | 31020 | Flutter starter, groups, create/join, members, invitations and group tests |
| Yunus Emre Yolal | 31294 | Step 2 coordination, expenses, balances, payments and map |

Yunus's work was committed through Efe's account. This table describes the team's confirmed screen work, not separate GitHub authorship. The UI baseline and test/report preparation used Codex assistance. Each member should be able to explain their work at the TA meeting. See [contribution details](../docs/STEP2_2_EKIP_GOREVLERI.md).

## Structure

- `lib/models/ledger.dart`: expenses, groups, settlements and balance derivation.
- `lib/state/app_state.dart`: preview state, membership operations and persistence.
- `lib/theme/` and `lib/widgets/`: shared design and form helpers.
- `lib/screens/`: auth, groups, expenses, profile and map selection.

## Assets and services

- Roboto: Google Fonts / Apache 2.0, bundled license in `assets/fonts/LICENSE-Roboto.txt`.
- Receipt illustration: generated locally for this project using simple geometric drawing.
- City image: [Unsplash source](https://images.unsplash.com/photo-1513635269975-59663e0ac1ad). Loaded over HTTPS with a local fallback.
- Map: flutter_map with visible OpenStreetMap attribution, app-identifying User-Agent and built-in native tile cache. [Tile policy](https://operations.osmfoundation.org/policies/tiles/). No bulk downloads or GPS lookup.

## Submission

Prepared for the team-reported extended deadline: **22 November 2026, 23:59 (Europe/Istanbul)**. Submit one group PDF named `CS310_Group31_Step2.2.pdf` through SUCourse. The PDF contains the public repository link, the full submitted code commit ID, labeled core-screen screenshots and Member Contributions. Runnable source stays in this public repository. APKs, screenshot ZIPs and the Step 2.1 PDF are not separate required Step 2.2 uploads in the specification.

See the [final submission checklist](../docs/STEP2_2_SUBMISSION.md).
