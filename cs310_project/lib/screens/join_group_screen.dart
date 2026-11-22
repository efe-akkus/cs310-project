import 'package:flutter/material.dart';
import '../models/ledger.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

import 'group_screens.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});
  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final form = GlobalKey<FormState>();
  final code = TextEditingController();
  ExpenseGroup? found;
  String? error;
  @override
  void dispose() {
    code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Join group')),
      body: PageBody(
        children: [
          const Text('Get an invite code from the group owner.'),
          const SizedBox(height: 24),
          Form(
            key: form,
            // Check again while typing, so the error goes away after a fix.
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: TextFormField(
              controller: code,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'Invite code',
                hintText: 'TRIP-7K2M',
                errorText: error,
              ),
              validator: requiredText,
              onChanged: (_) => setState(() {
                found = null;
                error = null;
              }),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              if (!form.currentState!.validate()) return;
              setState(() {
                found = app.findCode(code.text);
                error = found == null
                    ? 'Code not found on this preview device.'
                    : null;
              });
            },
            child: const Text('Preview group'),
          ),
          if (found != null) ...[
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.group_outlined),
                title: Text(found!.name),
                subtitle: Text(
                  'Owner: ${found!.members[found!.owner]}\n'
                  '${found!.members.length} ${found!.members.length == 1 ? 'member' : 'members'} · ${found!.currency}',
                ),
              ),
            ),
            const SizedBox(height: 16),
            PrimaryAction(
              found!.members.containsKey(app.userId)
                  ? 'Open group'
                  : 'Join group',
              onPressed: () async {
                final g = found!;
                if (!g.members.containsKey(app.userId)) {
                  if (!await confirm(
                    context,
                    'Join ${g.name}?',
                    'You will be able to view its expense records.',
                    action: 'Join group',
                  )) {
                    return;
                  }
                  if (!context.mounted) return;
                  app.join(g);
                }
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => GroupScreen(group: g),
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 24),
          const Text(
            'Preview code: TRIP-7K2M. Codes work with data on this device only until Firebase integration.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
