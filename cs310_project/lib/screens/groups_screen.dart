import 'package:flutter/material.dart';
import '../models/ledger.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'profile_screen.dart';

import 'group_screens.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('SplitMate'),
        actions: [
          IconButton(
            tooltip: 'My profile',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
            ),
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: PageBody(
        children: [
          Text(
            'Hi, ${app.name.split(' ').first}.',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Good company. Clear balances.'),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=1000&auto=format&fit=crop&q=80',
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              semanticLabel: 'City trip inspiration',
              errorBuilder: (_, e, s) => Image.asset(
                'assets/images/shared_receipt.png',
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SectionLabel('Your groups'),
          if (app.storageError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                app.storageError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (app.myGroups.isEmpty)
            const EmptyState(
              'Start with your people',
              'Create a group or use an invite code to join one.',
            ),
          for (final g in app.myGroups)
            Card(
              // The order changes when a group is favorited, so each card
              // gets a key and Flutter does not mix the cards up.
              key: ValueKey(g.id),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => GroupScreen(group: g),
                  ),
                ),
                leading: CircleAvatar(
                  child: Icon(
                    g.id == 'flat'
                        ? Icons.home_outlined
                        : Icons.luggage_outlined,
                  ),
                ),
                title: Text(
                  g.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${g.members.length} ${g.members.length == 1 ? 'member' : 'members'} · ${g.currency}\n'
                  'Total ${money(g.total, g.currency)}',
                ),
                isThreeLine: true,
                trailing: IconButton(
                  tooltip: app.isFavorite(g.id)
                      ? 'Remove favorite'
                      : 'Favorite group',
                  onPressed: () => app.toggleFavorite(g.id),
                  icon: Icon(
                    app.isFavorite(g.id)
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          PrimaryAction(
            'Create group',
            icon: Icons.add,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const CreateGroupScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const JoinGroupScreen()),
            ),
            icon: const Icon(Icons.group_add_outlined),
            label: const Text('Join with invite code'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Preview data is saved on this device. Accounts and cross-device sharing will connect in Step 3.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
