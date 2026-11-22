import 'package:cs310_project/models/ledger.dart';
import 'package:cs310_project/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Full repayment clears the debt and rejects duplicate payment', () {
    final app = AppState();
    app.signIn(yunusId);
    final group = app.groups.first;
    group.expenses.clear();
    group.settlements.clear();
    app.upsertExpense(
      group,
      Expense(
        id: 'shared-dinner',
        creator: yunusId,
        description: 'Dinner',
        payer: efeId,
        cents: 10001,
        date: DateTime(2026, 11, 22),
        participants: [efeId, yunusId],
      ),
    );

    expect(group.balances[yunusId], -5000);
    expect(group.balances[efeId], 5000);
    app.settle(group, efeId, 5000);

    expect(group.balances.values, everyElement(0));
    expect(group.repayments, isEmpty);
    expect(group.settlements, hasLength(1));
    expect(group.settlements.single.from, yunusId);
    expect(group.settlements.single.to, efeId);
    expect(group.settlements.single.cents, 5000);
    expect(group.total, 10001);

    expect(() => app.settle(group, efeId, 5000), throwsStateError);
    expect(group.settlements, hasLength(1));
    expect(group.balances.values, everyElement(0));
    expect(group.repayments, isEmpty);
  });
}
