# Step 2.2 submission checklist - Group 31

## Deliverables

1. Keep runnable Flutter source in the public repository: https://github.com/efe-akkus/cs310-project
2. Upload **one PDF per group** to the **Step 2.2** SUCourse submission: `CS310_Group31_Step2.2.pdf`.
3. The PDF must contain the repository link, full submitted commit ID, labeled screenshots of core screens and Member Contributions.
4. Any group member may submit. Complete the SUCourse final submission action and confirm receipt/status.

The team reports an extension to 22 November 2026, 23:59 (Europe/Istanbul). Step 2.1 has already been submitted. No separate APK, ZIP or video is requested by the supplied Step 2 specification.

## Requirement evidence

| Requirement | Implementation / verification |
| --- | --- |
| Approved core screens and navigation | Auth, groups, expenses, balances, members, profile and contextual panels; native UI tour |
| Shared widgets, colors, typography, spacing | `lib/widgets/common.dart`, `lib/theme/app_theme.dart` |
| Small/large portrait without overflow | Widget tests: 320x568 and 430x932; light/dark and keyboard insets |
| Local and network images | Bundled receipt illustration; HTTPS city image with fallback |
| Custom font | Bundled Roboto Regular/Bold; asset license included |
| Model objects displayed in Cards, working remove | Expense model, group expense Cards, creator delete with confirmation; state tests |
| Two-field form, inline errors, confirmation | Expense description/amount plus additional controls; validators and save confirmation |
| Runnable native application | iOS simulator build and integration tour; `flutter run` instructions in README |
| Tests and analysis | 56 unit/widget tests; `flutter analyze` clean |
| Public repository and run instructions | Public GitHub repository; root and app READMEs include Flutter 3.47.5 / Dart 3.13.4 |
| Member contributions | Team-confirmed table with account attribution note; see contribution record |

## Before pressing Submit

- Use the PDF whose commit matches the final checked code. If code changes, refresh relevant screenshots and regenerate the report.
- Confirm the member contribution table describes the work actually completed.
- The specification evaluates each member's own GitHub commits. Yunus's work was sent through Efe's account; this remains an individual-history issue and is disclosed.
- Each member must attend/explain their work at the TA meeting; attendance is not verified by repository checks.
- Upload the PDF, finish the SUCourse submission and verify its status. Repository preparation does not submit to SUCourse.

## Scope

Authentication and data are local UI previews. Firebase and Provider integration are planned for Step 3; OCR is deferred. The app records repayments and does not move money. Profile photos use optional HTTPS URLs. Internet is required for network imagery and map tiles.
