import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('My profile')),
      body: PageBody(
        children: [
          const SizedBox(height: 16),
          Center(
            child: Avatar(
              app.name,
              url: app.profile['photo'] ?? '',
              radius: 46,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            app.name,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(app.userId, textAlign: TextAlign.center),
          const SizedBox(height: 28),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Payment details',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    app.profile['iban']!.isEmpty
                        ? 'No IBAN added'
                        : app.profile['iban']!,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Optional. Visible to fellow group members only in payment details.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryAction(
            'Edit profile',
            icon: Icons.edit_outlined,
            onPressed: () => openSheet(context, const EditProfileSheet()),
          ),
          const SectionLabel('Appearance'),
          Card(
            child: SwitchListTile(
              title: const Text('Dark theme'),
              subtitle: const Text('A little easier on the eyes.'),
              secondary: const Icon(Icons.dark_mode_outlined),
              value: app.dark,
              onChanged: app.setDark,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              if (!await confirm(
                context,
                'Sign out?',
                'Your preview data stays on this device.',
                action: 'Sign out',
              )) {
                return;
              }
              if (!context.mounted) return;
              Navigator.of(context).popUntil((route) => route.isFirst);
              app.signOut();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
          const SizedBox(height: 20),
          const Text(
            'SplitMate · Group 31\nCourse preview • Local sample data',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key});
  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final form = GlobalKey<FormState>();
  late TextEditingController name, iban, photo;
  bool initialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      final p = AppScope.of(context).profile;
      name = TextEditingController(text: p['name']);
      iban = TextEditingController(text: p['iban']);
      photo = TextEditingController(text: p['photo']);
      initialized = true;
    }
  }

  @override
  void dispose() {
    name.dispose();
    iban.dispose();
    photo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return SheetBody(
      title: 'Edit profile',
      children: [
        Center(child: Avatar(name.text, url: photo.text, radius: 36)),
        const SizedBox(height: 20),
        Form(
          key: form,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: requiredText,
                maxLength: 60,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: photo,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: 'Photo URL · optional',
                  hintText: 'https://...',
                  suffixIcon: IconButton(
                    tooltip: 'Remove photo',
                    onPressed: () => setState(() => photo.clear()),
                    icon: const Icon(Icons.close),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final u = Uri.tryParse(v.trim());
                  return u != null && u.scheme == 'https' && u.host.isNotEmpty
                      ? null
                      : 'Use a full https image URL, or leave blank.';
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() {}),
                child: const Text('Preview photo'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: iban,
                decoration: const InputDecoration(labelText: 'IBAN · optional'),
                textCapitalization: TextCapitalization.characters,
                validator: ibanError,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Your IBAN is shown to fellow group members in payment details. Leave it blank or remove it at any time.',
        ),
        const SizedBox(height: 24),
        PrimaryAction(
          'Save profile',
          onPressed: () async {
            if (!form.currentState!.validate()) return;
            if (!await confirm(
              context,
              'Save profile changes?',
              'Update your name and optional payment/photo details?',
              action: 'Save profile',
            )) {
              return;
            }
            if (!context.mounted) return;
            app.updateProfile(name.text, iban.text, photo.text);
            Navigator.pop(context);
            toast(context, 'Profile updated.');
          },
        ),
      ],
    );
  }
}
