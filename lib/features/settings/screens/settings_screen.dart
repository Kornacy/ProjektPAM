import 'package:flutter/material.dart';
import 'package:city_issues/core/utils/scroll_padding.dart';
import 'package:city_issues/features/settings/screens/about_screen.dart';
import 'package:city_issues/features/settings/widgets/notification_settings_tile.dart';
import 'package:city_issues/services/app_preferences.dart';
import 'package:city_issues/services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    this.onShowOnboarding,
    this.onboardingHelpKey,
    this.scrollController,
  });

  final VoidCallback? onShowOnboarding;
  final GlobalKey? onboardingHelpKey;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final prefs = AppPreferences.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListenableBuilder(
        listenable: prefs,
        builder: (context, _) {
          return ListView(
            controller: scrollController,
            padding: ScrollPadding.list(context, includeNavBar: true),
            children: [
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      (user?.email?.isNotEmpty == true)
                          ? user!.email![0].toUpperCase()
                          : '?',
                    ),
                  ),
                  title: Text(user?.displayName ?? 'Użytkownik'),
                  subtitle: Text(user?.email ?? ''),
                ),
              ),
              const SizedBox(height: 16),
              Text('Pomoc', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      key: onboardingHelpKey,
                      leading: const Icon(Icons.help_outline),
                      title: const Text('Wprowadzenie do aplikacji'),
                      subtitle: const Text('Przewodnik po funkcjach'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: onShowOnboarding,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('O aplikacji'),
                      subtitle: const Text('Cel, twórcy, wersja'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AboutScreen()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Powiadomienia', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const Card(
                child: NotificationSettingsTile(),
              ),
              const SizedBox(height: 16),
              Text('Wygląd', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.brightness_6_outlined),
                      title: const Text('Motyw'),
                      subtitle: Text(_themeModeLabel(prefs.themeMode)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text('System'),
                            icon: Icon(Icons.settings_suggest_outlined),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text('Jasny'),
                            icon: Icon(Icons.light_mode_outlined),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text('Ciemny'),
                            icon: Icon(Icons.dark_mode_outlined),
                          ),
                        ],
                        selected: {prefs.themeMode},
                        onSelectionChanged: (modes) {
                          prefs.setThemeMode(modes.first);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Kolor akcentu', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: AppPreferences.accentPresets.map((color) {
                      final selected = prefs.accentColor == color;
                      return GestureDetector(
                        onTap: () => prefs.setAccentColor(color),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: selected
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
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
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Anuluj'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Wyloguj'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await AuthService.instance.signOut();
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Jasny';
      case ThemeMode.dark:
        return 'Ciemny';
      case ThemeMode.system:
        return 'Zgodny z systemem';
    }
  }
}
