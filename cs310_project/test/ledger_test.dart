import 'package:flutter_test/flutter_test.dart';
import 'package:cs310_project/models/ledger.dart';
import 'package:cs310_project/state/app_state.dart';
import 'package:cs310_project/widgets/common.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'Integer currency input avoids binary floating point and rejects malformed amounts',
    () {
      expect(parseMoney('12.34'), 1234);
      expect(parseMoney('0,01'), 1);
      expect(parseMoney('1.239'), null);
      expect(parseMoney('-2'), null);
      expect(parseMoney('1e5'), null);
    },
  );
  test(
    'Remainder cents are deterministic and payer can be outside participants',
    () {
      final e = Expense(
        id: '1',
        creator: 'a',
        description: 'Shared',
        payer: 'a',
        cents: 100,
        date: DateTime(2026),
        participants: ['c', 'b', 'd'],
      );
      expect(e.shares, {'b': 34, 'c': 33, 'd': 33});
      final g = ExpenseGroup(
        id: '1',
        name: 'test',
        currency: 'TRY',
        owner: 'a',
        code: 'A',
        members: {'a': 'A', 'b': 'B', 'c': 'C', 'd': 'D'},
        expenses: [e],
      );
      expect(g.balances, {'a': 100, 'b': -34, 'c': -33, 'd': -33});
      expect(g.balances.values.reduce((a, b) => a + b), 0);
    },
  );
  test(
    'Expense edits, deletion and partial settlement recalculate zero-sum balances',
    () {
      final app = AppState();
      app.signIn(efeId);
      final g = app.groups.first;
      g.expenses.clear();
      app.upsertExpense(
        g,
        Expense(
          id: 'x',
          creator: efeId,
          description: 'Dinner',
          payer: efeId,
          cents: 30000,
          date: DateTime(2026),
          participants: g.members.keys.toList(),
        ),
      );
      expect(g.balances[efeId], 20000);
      app.signIn(emirId);
      app.settle(g, efeId, 4000);
      expect(g.balances[efeId], 16000);
      expect(g.balances[emirId], -6000);
      expect(() => app.settle(g, efeId, 10001), throwsStateError);
      app.signIn(efeId);
      final old = g.expenses.first;
      app.upsertExpense(
        g,
        Expense(
          id: 'x',
          creator: efeId,
          description: 'Dinner updated',
          payer: efeId,
          cents: 60000,
          date: old.date,
          participants: old.participants,
        ),
      );
      expect(g.balances[efeId], 36000);
      app.deleteExpense(g, g.expenses.first);
      expect(g.balances.values.reduce((a, b) => a + b), 0);
      expect(g.total, 0);
    },
  );
  test('Only expense creator can edit or delete', () {
    final app = AppState();
    app.signIn(yunusId);
    final g = app.groups.first;
    expect(() => app.deleteExpense(g, g.expenses.first), throwsStateError);
  });
  test('Invite flow adds registered account without duplicate membership', () {
    final app = AppState();
    app.signIn('new@example.com', fullName: 'New Person');
    final g = app.findCode('trip-7k2m')!;
    app.join(g);
    app.join(g);
    expect(g.members.length, 4);
    expect(app.myGroups.contains(g), true);
  });
  test('IBAN optional but checksum and country length validated', () {
    expect(ibanError(''), null);
    expect(ibanError('TR330006100519786457841326'), null);
    expect(ibanError('TR330006100519786457841327'), isNotNull);
  });
  test('Data and dark theme survive an app-state reload', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final a = AppState(prefs);
    a.signIn(efeId);
    a.setDark(true);
    a.createGroup('Saved group', 'EUR');
    await a.save();
    final b = AppState(prefs);
    expect(b.dark, true);
    expect(b.groups.any((g) => g.name == 'Saved group'), true);
  });
}
