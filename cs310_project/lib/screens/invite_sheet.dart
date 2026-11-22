import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ledger.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class InviteSheet extends StatelessWidget {
  final ExpenseGroup group;
  const InviteSheet({super.key, required this.group});
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    if (group.owner != app.userId) {
      return const SheetBody(
        title: 'Invite members',
        children: [Text('Only the group owner can manage invitations.')],
      );
    }
    return SheetBody(
      title: 'Invite members',
      children: [
        Text(group.name, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        const Text('Send this code to someone you want to join.'),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SelectableText(
              group.code,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        PrimaryAction(
          'Copy invite code',
          icon: Icons.copy,
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: group.code));
            if (context.mounted) toast(context, 'Invite code copied.');
          },
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () async {
            if (await confirm(
              context,
              'Reset invite code?',
              'The old code will stop working. Existing members keep their access.',
              action: 'Reset code',
            )) {
              group.code = app.inviteCode();
              app.save();
            }
          },
          child: const Text('Reset invite code'),
        ),
        const Text(
          'Preview: invites work between accounts on this device.',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
