import 'package:flutter/material.dart';
import 'package:city_issues/services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Ustawienia')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(
                  (user?.email?.isNotEmpty == true) ? user!.email![0].toUpperCase() : '?',
                ),
              ),
              title: Text(user?.displayName ?? 'Użytkownik'),
              subtitle: Text(user?.email ?? ''),
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Wyloguj się', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Wylogować?'),
                  content: const Text('Czy na pewno chcesz się wylogować?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Anuluj')),
                    FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Wyloguj')),
                  ],
                ),
              );
              if (confirm == true) {
                await AuthService.instance.signOut();
              }
            },
          ),
        ],
      ),
    );
  }
}
