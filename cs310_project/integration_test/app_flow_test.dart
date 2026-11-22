import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cs310_project/main.dart';
import 'package:cs310_project/state/app_state.dart';
import 'package:cs310_project/models/ledger.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Complete SplitMate UI tour and capture core screens', (
    tester,
  ) async {
    final app = AppState();
    await tester.pumpWidget(SplitMateApp(state: app));
    Future<void> shot(String name) async {
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      await binding.takeScreenshot(name);
      expect(tester.takeException(), isNull);
    }

    Future<void> tap(String label) async {
      final f = find.text(label).last;
      if (f.evaluate().isEmpty) {
        await tester.scrollUntilVisible(
          f,
          180,
          scrollable: find.byType(Scrollable).first,
        );
      } else {
        await tester.ensureVisible(f);
      }
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    await shot('01_login');
    await tap('New here? Create an account');
    await shot('02_register');
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, 'preview123');
    await tap('Log in');
    await shot('03_groups');
    await tap('Create group');
    await shot('04_create_group');
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tap('Join with invite code');
    await tester.enterText(find.byType(TextFormField), 'TRIP-7K2M');
    await tap('Preview group');
    await shot('10_join_group');
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('My profile'));
    await tester.pumpAndSettle();
    await shot('09_profile');
    await tap('Edit profile');
    await shot('12_edit_profile');
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(SwitchListTile));
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    await shot('14_dark_profile');
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tap('Weekend trip');
    await shot('05_group_overview');
    await tap('Add expense');
    await tester.enterText(find.byType(TextFormField).at(0), 'Groceries');
    await tester.enterText(find.byType(TextFormField).at(1), '120.00');
    FocusManager.instance.primaryFocus?.unfocus();
    await shot('06_expense_form');
    await tap('Add a place');
    await tester.tapAt(
      tester.getTopLeft(find.byType(FlutterMap)) + const Offset(70, 80),
    );
    await tester.enterText(find.byType(TextFormField).last, 'Istanbul market');
    FocusManager.instance.primaryFocus?.unfocus();
    await shot('17_location_map');
    await tap('Use this location');
    await tap('Save expense');
    await shot('15_save_confirmation');
    await tap('Save expense');
    expect(
      app.groups.first.expenses.any((e) => e.description == 'Groceries'),
      true,
    );
    await tap('Balances');
    await shot('07_balances');
    await tap('Members');
    await shot('08_members');
    await tap('Invite members');
    await shot('13_invite');
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    await tap('Expenses');
    await tap('Dinner together');
    // Network map tiles can continue loading; a bounded pump avoids indefinite waiting.
    await tester.pump(const Duration(seconds: 3));
    await binding.takeScreenshot('11_expense_detail');
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    // Exercise a real debt from the signed-in user for the payment panel.
    final g = app.groups.first;
    app.upsertExpense(
      g,
      Expense(
        id: 'payment-example',
        creator: efeId,
        description: 'Shared tickets',
        payer: emirId,
        cents: 120000,
        date: DateTime.now(),
        participants: g.members.keys.toList(),
      ),
    );
    await tester.pumpAndSettle();
    await tap('Balances');
    await tap('Record payment');
    await shot('16_payment');
    await tester.enterText(find.byType(TextFormField), '10.00');
    await tap('Record payment');
    await tap('Record payment');
    expect(g.settlements.isNotEmpty, true);
  });
}
