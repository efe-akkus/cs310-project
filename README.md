# SplitMate

A Flutter application for managing shared group expenses and balances.

**CS310 | Group 31 | Step 1: Project Proposal**

> Status: project planning. The features below describe the planned MVP; a runnable Flutter application has not yet been added.

## Team

| Member | Student ID | Role |
| --- | --- | --- |
| Efe Çağan Akkuş | 32413 | Step 1 coordinator |
| Emir Keskin | 31020 | Team member |
| Yunus Emre Yolal | 31294 | Team member |

## Project overview

SplitMate is a Flutter application for recording shared expenses and showing who owes whom. It targets students, roommates and small travel groups who need a clear record of common costs. The MVP works entirely offline on one device: one person manages the group records and shows the results to the others.

## MVP scope

The MVP uses local data and one currency per group. It does not require accounts, a backend or an internet connection. Multi-device synchronization, online payments and currency conversion are outside the MVP scope. Recording a settlement only updates the expense ledger; it does not transfer money.

## Core features

- **Groups and members:** Create a group, choose its currency and add named members. Keep member references consistent when records are edited.
- **Expense management:** Add, view, edit and delete an expense with a description, amount, date, one payer and selected participating members.
- **Equal splitting:** Divide each expense equally among its selected participants and recalculate balances after every change.
- **Balances and settlements:** Show each member's net balance and a readable list of who owes whom. Record a manual repayment and update outstanding balances.
- **Offline persistence:** Save groups, members, expenses and settlements on the device and restore them when the app is reopened.

## Optional features

After the core workflow is reliable, optional extensions may include unequal splits, expense categories, search and filtering, CSV export and dark mode. These features are not required for MVP completion.

## Technical approach

The planned stack is Flutter and Dart, with a local SQLite database. The interface, balance calculations and persistence logic will be kept separate so that each can be developed and checked independently. In Step 3, Provider will manage application state and update the interface when local records or balances change. Planned screens are the group list, group overview, expense form, balance summary and settlement form.

## Local data

Local records will include groups, members, expenses, expense participants and settlements, linked by stable IDs. Amounts will be stored as integer minor units, such as cents, to avoid floating-point errors. Any remainder from an equal split will be assigned deterministically so that participant shares add up exactly to the expense total. No cloud storage or automatic backup is planned; uninstalling the app or clearing its data may remove the records.

## Expected challenges

- **Calculation accuracy:** Handle rounding, selected participants, edits and repayments consistently; verify that all net balances sum to zero.
- **Data consistency:** Validate positive amounts and valid member references; use database transactions for related changes and define safe deletion rules.
- **Usability and teamwork:** Keep entry forms and balance labels clear. Agree on shared data models early and integrate changes in small commits.

## Step 1 contributions and remaining tasks

| Member | Contribution / remaining task |
| --- | --- |
| Efe Çağan Akkuş | Prepared all Step 1 sections: overview, features, data and challenges; prepared the proposal, README and GitHub setup. Coordinates Step 1 and TA communication. |
| Emir Keskin | Planned before submission: review the feature scope and local data requirements. Review is not yet confirmed complete. |
| Yunus Emre Yolal | Planned before submission: review the balance workflow, challenges and proposal clarity. Review is not yet confirmed complete. |

All members will review changes, integrate their work and contribute to the final demonstration.

## Completion and validation

The MVP is complete when a user can create a group, add members, record and revise an expense, inspect balances, record a repayment and reopen the app without losing data, all without internet access. Checks will cover uneven cent divisions, participants who exclude the payer, expense deletion and partial repayments. All three members will review integration and contribute to the final demonstration.

For example, if Efe pays 300.00 for an expense shared equally by all three members, each share is 100.00. Efe's balance is +200.00, Emir's is -100.00 and Yunus Emre's is -100.00. Recording a 40.00 repayment from Emir to Efe changes their balances to +160.00 and -60.00; Yunus Emre remains at -100.00.

## Proposal documents

- [Step 1 proposal (PDF)](docs/CS310_SplitMate_Group31_Step1_Proposal.pdf)
- [Editable proposal text](docs/CS310_SplitMate_Group31_Step1_Proposal.md)

## Development status

The repository currently contains the Step 1 documentation. App setup and run instructions will be added with the Flutter project.

## Repository

[https://github.com/efe-akkus/cs310-project](https://github.com/efe-akkus/cs310-project)
