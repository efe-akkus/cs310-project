import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

import 'group_screens.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});
  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController();
  String currency = 'TRY';
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  Future<void> create() async {
    if (!form.currentState!.validate()) return;
    final ok = await confirm(
      context,
      'Create this group?',
      '${name.text.trim()} · $currency',
      action: 'Create group',
    );
    if (!ok || !mounted) return;
    try {
      final g = AppScope.of(context).createGroup(name.text, currency);
      // Open the new group and show its invite code right away.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => GroupScreen(group: g, showInvite: true),
        ),
      );
    } on StateError catch (e) {
      toast(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Create group')),
      body: PageBody(
        children: [
          const Text('A shared space for your shared expenses.'),
          const SizedBox(height: 24),
          Form(
            key: form,
            // Check again while typing, so the error goes away after a fix.
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: 'Group name',
                    hintText: 'e.g. Weekend trip',
                  ),
                  validator: requiredText,
                  maxLength: 40,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: currency,
                  decoration: const InputDecoration(labelText: 'Currency'),
                  items: const ['TRY', 'EUR', 'USD', 'GBP']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => currency = v!),
                ),
              ],
            ),
          ),
          const SectionLabel('Group owner'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            // Same avatar as in the member list (photo if the user added one).
            leading: Avatar(app.name, url: app.profile['photo'] ?? ''),
            title: Text(app.name),
            subtitle: const Text('You will join automatically.'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Invite your friends with a code after creating the group.',
          ),
          const SizedBox(height: 24),
          PrimaryAction('Create group', onPressed: create),
        ],
      ),
    );
  }
}
