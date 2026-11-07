# SplitMate - Step 2.1 pre-submission design draft

Group 31 | 6 November 2026

Step 2 coordinator: Yunus Emre Yolal (31294); confirmed 5 November 2026.

Account-based shared groups; Firebase implementation planned for Step 3. Step 2 uses mock data.

## S01 Log in

Sign in with email and password to view your shared groups. An account is required; guest access is removed. Step 2 uses simulated success/error states; Firebase Authentication follows in Step 3.

Navigation: Log in -> S03; Create account -> S02.

## S02 Create account

Enter full name, email and password. Confirm valid details to enter S03. Photo and IBAN are optional and added later in the profile edit panel. Authentication is simulated in Step 2.

Navigation: Create account -> confirmation -> S03; Back -> S01.

## S03 My groups

Home lists only groups joined by the signed-in user. Create a group or join with an invite code. The profile button opens your own profile. Shared records will sync through Firestore in Step 3.

Navigation: Group -> S05; Create -> S04; Join -> S10; Profile -> S09.

## S04 Create group

Choose the group name and currency. The creator becomes its first member and owner. Do not enter other people as local labels; invite registered accounts after creation.

Navigation: Create -> confirmation -> S05 + invite panel; Cancel / Back -> S03.

## S05 Group overview

View the group total and expense history. Expense cards show payer, amount and date. Open a card to inspect it; use the tabs for balances or members.

Navigation: Add expense -> S06; Expense -> details panel; Balances -> S07; Members -> S08.

## S06 Add / edit expense

Enter description, positive amount, date, payer and participants selected from joined members. Split equally. Editing pre-fills the form. Only the expense creator can edit/delete it; others can view.

Navigation: Valid Save -> confirmation -> S05 (add or edit); Cancel -> source.

## S07 Balances

Show net balances and suggested repayments. Positive means the member should receive money; negative means they owe money. The group ledger remains balanced.

Navigation: Record payment -> payment panel; Expenses -> S05; Members -> S08.

## S08 Group members

List joined accounts and their profile photos or initials. Members edit only their own profile. The owner manages invite codes; all group members may view the list. IBANs are not shown here.

Navigation: Owner: Invite members -> invite panel; Expenses -> S05; Balances -> S07.

## S09 My profile

View your own full name, photo or initials, email and optional IBAN. Email is read-only for this scope. Sign out clears the signed-in session and returns to login.

Navigation: Edit profile -> edit panel; Sign out -> confirm -> S01; Back -> S03.

## S10 Join group

Enter an invite code, preview the group name and owner, then confirm joining. Invalid or expired codes show an inline error. Already joined groups open directly without a duplicate membership.

Navigation: Preview -> same screen; Confirm join / Open group -> S05; Back -> S03.

## Supporting states

### Expense details panel - S05

Tap an expense card to open a sheet with description, date, total, payer and each share. The creator sees Edit and Delete. Edit opens S06; confirm deletion to update the ledger. Dismiss returns to S05.

### Record payment panel - S07

Show the current user as sender, a recipient selector, outstanding amount, optional recipient IBAN with Copy, and an amount field. Confirm an amount up to the outstanding repayment. Close returns to balances; the app records payments without transferring money.

### Edit profile panel - S09

Show full name, optional photo controls and optional IBAN. Validate the name and any supplied IBAN. Explain that fellow group members can see the IBAN in payment details. Save or cancel returns to the profile.

### Invite code panel - S05 / S08

Open after creating a group or from Invite members. Show the code, Copy and owner-only Reset with confirmation. Reset invalidates the old code while preserving memberships. Close returns to the underlying group screen.

### Validation, empty and failure states

Show inline errors and confirm valid submissions before saving. Offer Create / Join for empty groups and Add expense for empty history. Show All settled for zero balances. Preserve input on failure and block duplicate submissions.

### Step 2 / Step 3 boundary

Use mock data for the Step 2 UI. Connect Firebase in Step 3, with member-only group access and owner-only profile editing. Recalculate balances from expenses and settlement records.

## Visual design update - 7 November 2026

The 10-page PDF draws the four contextual panels and includes inline-validation and confirmation examples. There are still 10 main screens. The TA approved the account/shared-group scope, as confirmed by the group; final screen review remains pending.
