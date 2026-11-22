import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ledger.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class InviteSheet extends StatefulWidget {
  final ExpenseGroup group;
  const InviteSheet({super.key, required this.group});
  @override
  State<InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends State<InviteSheet> {
  // A SnackBar opens behind this bottom sheet, so the user cannot see it.
  // That is why the result of copy/reset is shown inside the sheet.
  String? message;

  Future<void> copyCode() async {
    await Clipboard.setData(ClipboardData(text: widget.group.code));
    if (!mounted) return;
    setState(() => message = 'Invite code copied.');
  }

  Future<void> resetCode() async {
    final ok = await confirm(
      context,
      'Reset invite code?',
      'The old code will stop working. Existing members keep their access.',
      action: 'Reset code',
    );
    if (!ok || !mounted) return;
    try {
      AppScope.of(context).resetInviteCode(widget.group);
      setState(
        () => message = 'New code created. The old code no longer works.',
      );
    } on StateError catch (e) {
      setState(() => message = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final group = widget.group;
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
          onPressed: copyCode,
        ),
        if (message != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: resetCode,
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
