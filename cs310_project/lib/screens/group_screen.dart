import 'group_members_view.dart';
import 'package:flutter/material.dart';
import '../models/ledger.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'expense_screens.dart';

import 'group_screens.dart';

class GroupScreen extends StatefulWidget {
  final ExpenseGroup group;
  final bool showInvite;
  const GroupScreen({super.key, required this.group, this.showInvite = false});
  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  int tab = 0;
  @override
  void initState() {
    super.initState();
    if (widget.showInvite) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) openSheet(context, InviteSheet(group: widget.group));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final g = widget.group;
    return Scaffold(
      appBar: AppBar(
        title: Text(g.name),
        actions: [
          IconButton(
            tooltip: 'Favorite group',
            onPressed: () => app.toggleFavorite(g.id),
            icon: Icon(app.isFavorite(g.id) ? Icons.star : Icons.star_border),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Balances',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            label: 'Members',
          ),
        ],
      ),
      body: PageBody(
        children: tab == 0
            ? _expenses(g)
            : tab == 1
            ? _balances(g)
            : _members(g),
      ),
    );
  }

  List<Widget> _expenses(ExpenseGroup g) {
    return [
      Text('Shared so far', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      Text(
        money(g.total, g.currency),
        style: Theme.of(
          context,
        ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Text('${g.expenses.length} expenses · ${g.members.length} people'),
      const SizedBox(height: 24),
      PrimaryAction(
        'Add expense',
        icon: Icons.add,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => ExpenseForm(group: g)),
        ),
      ),
      const SectionLabel('Recent expenses'),
      if (g.expenses.isEmpty)
        const EmptyState(
          'Nothing to split yet',
          'Add your first shared expense.',
        ),
      for (final e in ([
        ...g.expenses,
      ]..sort((a, b) => b.date.compareTo(a.date))))
        Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () =>
                openSheet(context, ExpenseDetails(group: g, expense: e)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          e.description,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        money(e.cents, g.currency),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${g.members[e.payer]} paid · ${dateLabel(e.date)}'),
                  if (e.location != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.place_outlined, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              e.location!.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
    ];
  }

  List<Widget> _balances(ExpenseGroup g) {
    final app = AppScope.of(context);
    final b = g.balances;
    final mine = g.repayments.where((r) => r.from == app.userId).toList();
    return [
      Text(
        'Everyone’s balance',
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      const Text('Positive: receives money. Negative: owes money.'),
      const SizedBox(height: 20),
      for (final member in g.members.entries)
        Card(
          child: ListTile(
            leading: Avatar(
              member.value,
              url: app.profiles[member.key]?['photo'] ?? '',
            ),
            title: Text(member.value),
            subtitle: Text(member.key == app.userId ? 'You' : 'Member'),
            trailing: Text(
              '${b[member.key]! > 0 ? '+' : ''}${money(b[member.key]!, g.currency)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: b[member.key]! < 0
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      const SectionLabel('Who pays whom'),
      if (g.repayments.isEmpty)
        const EmptyState('All settled', 'There are no outstanding repayments.'),
      for (final r in g.repayments)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            '${g.members[r.from]} → ${g.members[r.to]}\n${money(r.cents, g.currency)}',
          ),
        ),
      PrimaryAction(
        'Record payment',
        onPressed: mine.isEmpty
            ? null
            : () => openSheet(context, PaymentSheet(group: g)),
      ),
      if (mine.isEmpty && g.repayments.isNotEmpty)
        const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'You have no outgoing repayments. The member who paid records their payment.',
          ),
        ),
      if (g.settlements.isNotEmpty) ...[
        const SectionLabel('Recorded payments'),
        for (final p in g.settlements)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.check_circle_outline),
            title: Text('${g.members[p.from]} → ${g.members[p.to]}'),
            subtitle: const Text('Recorded outside the app'),
            trailing: Text(money(p.cents, g.currency)),
          ),
      ],
    ];
  }

  List<Widget> _members(ExpenseGroup g) => [GroupMembersView(group: g)];
}
