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

Tests cover currency parsing, rounding, excluded payers, edits/deletions/partial settlements, invite membership, IBAN validation and local persistence. Widget tests exercise light/dark layouts at 320x568 and 430x932, including keyboard insets. The native integration test navigates the app and writes labeled screenshots into the ignored `screenshots/` directory. Screenshot tests use fresh sample state and do not modify stored user preview data.

## Team and handoff

| Member | ID | Role |
| --- | --- | --- |
| Efe Çağan Akkuş | 32413 | Step 1 coordinator; auth/profile/appearance follow-up |
| Emir Keskin | 31020 | Flutter starter setup; group-management follow-up |
| Yunus Emre Yolal | 31294 | Step 2 coordinator; expenses/balances/map follow-up |

The follow-up assignments are planned work, not a claim that each member already implemented those screens. The initial UI baseline was created with Codex assistance at Efe's request. Each member must review, understand and make their own meaningful changes through their own GitHub account before the final contributions table is written.

See [screen assignments](../docs/STEP2_2_EKIP_GOREVLERI.md). Source files are separated by screen to support independent edits.

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

The team reports an extension to **22 November 2026, 23:59 (Europe/Istanbul)**. After members finish their edits, rerun checks, refresh screenshots and record the actual final commit ID. The Step 2.2 report must include the public repository link, deadline commit ID, labeled core-screen screenshots and actual Member Contributions.
