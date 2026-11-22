import 'package:flutter/material.dart';
import '../models/ledger.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'invite_sheet.dart';

class GroupMembersView extends StatelessWidget {
  final ExpenseGroup group;
  const GroupMembersView({super.key, required this.group});
  @override
  Widget build(BuildContext context) {
    final g = group;

    final app = AppScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Your people',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text('${g.members.length} joined members'),
        const SizedBox(height: 24),
        for (final m in g.members.entries)
          Card(
            child: ListTile(
              leading: Avatar(
                m.value,
                url: app.profiles[m.key]?['photo'] ?? '',
              ),
              title: Text(m.value),
              subtitle: Text(
                '${m.key == g.owner ? 'Group owner' : 'Member'}${m.key == app.userId ? ' · You' : ''}',
              ),
            ),
          ),
        if (g.owner == app.userId) ...[
          const SizedBox(height: 20),
          PrimaryAction(
            'Invite members',
            icon: Icons.person_add_alt,
            onPressed: () => openSheet(context, InviteSheet(group: g)),
          ),
        ],
        const SizedBox(height: 20),
        const Text(
          'Each member manages their own profile. IBANs appear only in payment details.',
        ),
      ],
    );
  }
}
