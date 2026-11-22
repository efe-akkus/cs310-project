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
            leading: Avatar(app.name),
            title: Text(app.name),
            subtitle: const Text('You will join automatically.'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Invite your friends with a code after creating the group.',
          ),
          const SizedBox(height: 24),
          PrimaryAction(
            'Create group',
            onPressed: () async {
              if (!form.currentState!.validate()) return;
              if (!await confirm(
                context,
                'Create this group?',
                '${name.text.trim()} · $currency',
                action: 'Create group',
              )) {
                return;
              }
              if (!context.mounted) return;
              final g = app.createGroup(name.text, currency);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => GroupScreen(group: g, showInvite: true),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
