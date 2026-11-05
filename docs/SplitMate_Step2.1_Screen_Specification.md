# SplitMate - Step 2.1 wireframes v2

Group 31 | 2 November 2026

Account-based shared groups; Firebase implementation planned for Step 3. Step 2 uses mock data.

## S01 Log in

Sign in with email and password to view your shared groups. An account is required; guest access is removed. Step 2 uses simulated success/error states; Firebase Authentication follows in Step 3.

Navigation: Log in -> S03; Create account -> S02.

## S02 Create account

Enter full name, email and password. Confirm valid details to enter S03. Photo and IBAN are optional and added later in S12. Authentication is simulated in Step 2.

Navigation: Create account -> confirmation -> S03; Back -> S01.

## S03 My groups

Home lists only groups joined by the signed-in user. Create a group or join with an invite code. The profile button opens your own profile. Shared records will sync through Firestore in Step 3.

Navigation: Group -> S05; Create -> S04; Join -> S13; Profile -> S11.

## S04 Create group

Choose the group name and currency. The creator becomes its first member and owner. Do not enter other people as local labels; invite registered accounts after creation.

Navigation: Create -> confirmation -> S14; Cancel / Back -> S03.

## S05 Group overview

View the group total and expense history. Expense cards show payer, amount and date. Open a card to inspect it; use the tabs for balances or members.

Navigation: Add expense -> S06; Expense -> S07; Balances -> S08; Members -> S10.

## S06 Add / edit expense

Enter description, positive amount, date, payer and participants selected from joined members. Split equally. Editing pre-fills the form. Only the expense creator can edit/delete it; others can view.

Navigation: Valid Save -> confirmation -> S05 (add) or S07 (edit); Cancel -> source.

## S07 Expense details

Inspect the payer, participants and exact shares. For the expense creator, show Edit and Delete; other members see read-only details. Confirming deletion refreshes shared history and balances.

Navigation: Edit -> S06; Delete -> confirmation -> S05; Back -> S05.

## S08 Balances

Show net balances and suggested repayments. Positive means the member should receive money; negative means they owe money. The group ledger remains balanced.

Navigation: Record payment -> S09; Expenses -> S05; Members -> S10.

## S09 Record payment

Sender is the signed-in user; select a suggested recipient. Show their optional IBAN with Copy, or an unavailable message. Record a payment already made outside the app; confirm to update balances.

Navigation: Valid Record -> confirmation -> S08; Cancel / Back -> S08.

## S10 Group members

List joined accounts and their profile photos or initials. Members edit only their own profile. The owner manages invite codes; all group members may view the list. IBANs are not shown here.

Navigation: Owner: Invite members -> S14; Expenses -> S05; Balances -> S08.

## S11 My profile

View your own full name, photo or initials, email and optional IBAN. Email is read-only for this scope. Sign out clears the signed-in session and returns to login.

Navigation: Edit profile -> S12; Sign out -> confirm -> S01; Back -> S03.

## S12 Edit profile

Full name is required. Add or remove an optional photo and IBAN. A photo permission denial leaves initials. Explain IBAN visibility to fellow group members in payment details before saving.

Navigation: Save -> confirmation -> S11; Cancel / Back -> S11.

## S13 Join group

Enter an invite code, preview the group name and owner, then confirm joining. Invalid or expired codes show an inline error. Already joined groups open directly without a duplicate membership.

Navigation: Preview -> same screen; Confirm join / Open group -> S05; Back -> S03.

## S14 Invite members

Owner-only screen shows the invite code with Copy. Share it outside the app. Reset invalidates the old code after confirmation. Non-owners cannot access this screen.

Navigation: Copy -> stays; Reset -> confirmation; Done / Back -> S05.

## Supporting states

### Account and group access

Sign-in is required. Members see only their joined groups. Group creators own invitations; invite codes are validated before joining. A reset code stops future joins but does not remove current members. Duplicate joins open the existing group.

### Forms and optional profile fields

Required: full name, valid email and password on sign-up; group name and currency; expense description, positive amount, date, payer and participants. IBAN may be blank; if entered, validate its format and checksum. Photo and IBAN never block account creation.

### Photo and IBAN visibility

A denied photo permission or failed photo upload keeps initials and allows retry. IBAN is absent from group lists/member cards; show it only to fellow members in recipient payment details. Copy uses the full stored IBAN and shows a copied message. Missing IBAN: show "IBAN not added"; payments can still be recorded.

### Confirmation and deletion

Valid forms show a summary with Cancel / Confirm before saving. S07 shows Edit/Delete only to the expense creator. Delete confirmation explains that balances will change. Cancel preserves the record. Other members can view but cannot edit that expense.

### Balances and settlement records

Derive balances from expense shares and settlements. Example: Efe +200, Emir -100, Yunus Emre -100. Emir records a TRY 40 payment to Efe: +160, -60, -100. Sender is the current user; recipient differs, amount is positive and cannot exceed the suggested repayment. No real bank transfer occurs.

### Empty, loading and failure states

Empty groups: Create / Join. Empty history: Add expense. Zero balances: All settled. Loading disables repeat submissions. In Step 3, network/auth/save errors show Retry and preserve input; do not show success before server confirmation. Step 2 simulates these states with mock data.

### Implementation and review

Step 2.2 will use model-backed expense Cards with remove, reusable widgets, a custom font, bundled image and network image with fallback. Use scrollable, keyboard-aware layouts on portrait phones. Obtain TA review of the expanded shared-group scope before Flutter UI implementation.
