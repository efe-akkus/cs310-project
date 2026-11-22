# SplitMate

Shared group expenses and clear balances. **CS310 Group 31 - Step 2.2**.

## Run

Tested with **Flutter 3.47.5 stable / Dart 3.13.4** on an iOS simulator.

```sh
git clone https://github.com/efe-akkus/cs310-project.git
cd cs310-project/cs310_project
flutter pub get
flutter run
```

Start an Android emulator or iOS simulator before running. No Firebase configuration or API key is needed for this UI submission. Internet is needed for the network photo and map tiles.

Demo login: `efe.akkus@sabanciuniv.edu`, any password of at least 8 characters. For a debtor preview use `yunus@example.com`. Sample invite code: `TRIP-7K2M`. These are device-local preview identities; passwords are not authenticated or stored.

## Implemented in Step 2.2

- Login, registration, profile editing and light/dark appearance.
- Create/join groups, member lists, owner invite-code reset and favorite groups.
- Model-backed expense Cards; add, view, edit and confirmed delete actions.
- Equal splitting with integer minor units, balances and partial/full repayment recording.
- Optional expense location selected on an interactive map.
- Inline form validation and confirmation dialogs, shared widgets and styles.
- Bundled receipt image and Roboto font, HTTPS city image with fallback.
- Device-local persistence of preview records and profile settings.

Firebase authentication, shared cloud data, backend authorization and Provider integration are planned for Step 3. OCR is deferred. The profile photo currently accepts an optional HTTPS URL. Payments record transfers made outside the application; no money is moved by SplitMate.

## Submission and checks

Step 2.1 was submitted. Step 2.2 is prepared for the team-reported extended deadline: **22 November 2026, 23:59 (Europe/Istanbul)**. The SUCourse report is named `CS310_Group31_Step2.2.pdf` and is delivered separately; its full commit ID identifies the submitted code snapshot.

```sh
cd cs310_project
flutter analyze
flutter test
```

Final automated verification: **56 tests passed**, covering models, state, forms, group flows and light/dark portrait layouts at 320x568 and 430x932, including keyboard insets. Native integration captures core screens and exercises navigation, expense creation, map selection and payment recording. See the [submission checklist](docs/STEP2_2_SUBMISSION.md) and [detailed run instructions](cs310_project/README.md).

## Team and member contributions

| Member | Student ID | Step 2 responsibilities |
| --- | --- | --- |
| Efe Çağan Akkuş | 32413 | Login, registration, profile and theme; AI-assisted UI baseline and final integration/testing |
| Emir Keskin | 31020 | Flutter starter; groups, create/join, members and invitations; group tests |
| Yunus Emre Yolal | 31294 | Step 2 coordinator; expenses, balances, payments and map |

Screen responsibilities above were confirmed by the team. Yunus's work was submitted through Efe's account; it is not represented as an independently authored Yunus GitHub commit. The initial UI baseline and subsequent test/report preparation used Codex assistance. The course separately evaluates each member's own GitHub history and TA explanation.

See [contribution details](docs/STEP2_2_EKIP_GOREVLERI.md).

## Design and earlier documents

- [Design decisions (Turkish)](TASARIM_KARARLARI.md)
- [Submitted Step 2.1 wireframes](docs/CS310_Group31_Step2.1.pdf)
- [Screen descriptions and navigation](docs/SplitMate_Step2.1_Screen_Specification.md)
- [Historical Step 1 proposal](docs/CS310_SplitMate_Group31_Step1_Proposal.pdf) - the earlier offline scope was later revised with TA approval.

Repository: https://github.com/efe-akkus/cs310-project
