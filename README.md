# SplitMate

A Flutter application for managing shared group expenses and balances.

**CS310 | Group 31 | Current stage: Step 2.1 wireframes**

> Status: a 14-screen wireframe draft is ready for TA review. No runnable Flutter application or Firebase integration has been implemented yet. The current shared-group design supersedes the single-device scope of the historical Step 1 proposal; TA review of this scope change is pending.

## Team

| Member | Student ID | Coordination |
| --- | --- | --- |
| Efe Çağan Akkuş | 32413 | Step 1 coordinator |
| Emir Keskin | 31020 | Team member |
| Yunus Emre Yolal | 31294 | Step 2 coordinator |

Yunus Emre Yolal is the Step 2 coordinator, responsible for organizing meetings, coordinating task assignments and communicating with the assigned TA.

## Current product scope

SplitMate helps students, roommates and small travel groups track who paid and who owes whom. Users sign in with personal accounts and join shared groups using an invite code.

- Required sign-in; no guest mode.
- Simple profile: full name, optional photo and optional IBAN.
- Create a group, select one currency and invite registered users.
- Add, view, edit and delete expenses with one payer and selected participants.
- Split expenses equally and derive member balances from expenses, shares and settlement records.
- Record repayments already made outside the app. The app does not transfer money.
- Show an optional recipient IBAN in payment details to fellow group members, with a copy action. IBANs are not displayed on general member lists.

Amounts are planned as integer minor units with deterministic remainder allocation. Group net balances must sum to zero. Expense edit permissions, invitation management and other detailed access policies remain subject to review.

## Planned stack and stage boundaries

| Component | Planned responsibility |
| --- | --- |
| Flutter / Dart | Interface and application logic |
| Provider | Application state |
| Firebase Authentication | Accounts and sign-in |
| Cloud Firestore | Profiles, groups, memberships, expenses, shares and settlements |
| Cloud Storage | Optional profile photos |

Step 2.1 defines screens and navigation. Step 2.2 will implement UI with mock records, simulated authentication and working navigation. Real Firebase integration is planned for Step 3. SQLite is no longer the planned primary store. Group access and profile ownership must be enforced by backend rules when Firebase is implemented.

Unequal splits, expense categories, search/filtering, CSV export and dark mode remain optional. Currency conversion and bank transfers are outside the core scope.

## Design documentation

- [Tasarım Kararları - decisions, reasons and open questions (Turkish)](TASARIM_KARARLARI.md)
- [Step 2.1 wireframes v2 - 14 screens, 9 pages](docs/CS310_Group31_Step2.1.pdf)
- [Screen descriptions and navigation (English)](docs/SplitMate_Step2.1_Screen_Specification.md)

## Submission checklist

- [x] Step 1 proposal and repository setup documented.
- [x] Step 2.1 wireframe draft prepared; shared-group and profile scope documented.
- [x] Select Step 2 coordinator: Yunus Emre Yolal (31294).
- [ ] Confirm all members' GitHub access.
- [ ] Finalize visual design and obtain TA feedback on the updated scope and screens.
- [ ] Submit `CS310_Group31_Step2.1.pdf` by **8 November 2026, 23:59 (Europe/Istanbul)**.
- [ ] Implement reviewed screens with working navigation and the required UI components.
- [ ] Each member contributes through their own account and explains their work at the TA meeting.
- [ ] Submit Step 2.2 code and `CS310_Group31_Step2.2.pdf` by **20 November 2026, 23:59 (Europe/Istanbul)**.

Run instructions and the actual Flutter version will be added when the runnable app is created. The current repository is documentation-only.

## Historical Step 1 documents

These preserve the earlier single-device proposal; they do not describe the revised shared-group scope.

- [Step 1 proposal (PDF)](docs/CS310_SplitMate_Group31_Step1_Proposal.pdf)
- [Step 1 proposal text](docs/CS310_SplitMate_Group31_Step1_Proposal.md)

Efe prepared the Step 1 proposal sections, README and repository setup. Other members' final review completion was not confirmed in this chat. No Step 2 implementation contributions are claimed yet.

## Repository

[efe-akkus/cs310-project](https://github.com/efe-akkus/cs310-project)
