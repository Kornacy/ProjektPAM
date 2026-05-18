import 'package:flutter/material.dart';
import 'package:city_issues/services/app_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.replay = false});

  final bool replay;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardingPage(
      icon: Icons.location_city,
      title: 'Witaj w City Issues',
      body:
          'Zgłaszaj problemy miejskie w kilka chwil — dziury w drodze, '
          'zepsute latarnie, śmieci i inne usterki w Twojej okolicy.',
    ),
    _OnboardingPage(
      icon: Icons.map_outlined,
      title: 'Mapa zgłoszeń',
      body:
          'Przeglądaj zgłoszenia innych mieszkańców. Przytrzymaj mapę, '
          'aby dodać zgłoszenie w wybranym miejscu (1 s + 3 s wypełniania).',
    ),
    _OnboardingPage(
      icon: Icons.add_a_photo_outlined,
      title: 'Nowe zgłoszenie',
      body:
          'Zrób zdjęcie problemu, wybierz kategorię i wyślij — GPS uzupełni '
          'lokalizację. Formularz jest dostępny z dolnej zakładki „Dodaj”.',
    ),
    _OnboardingPage(
      icon: Icons.list_alt_outlined,
      title: 'Moje zgłoszenia',
      body:
          'Śledź status swoich zgłoszeń, podbijaj ważne sprawy i sprawdzaj '
          'szczegóły na mapie.',
    ),
    _OnboardingPage(
      icon: Icons.person_outline,
      title: 'Profil i ustawienia',
      body:
          'Zmień motyw, kolor akcentu lub ponów to wprowadzenie z ikony '
          'pomocy w zakładce Profil.',
    ),
  ];

  Future<void> _finish() async {
    if (!widget.replay) {
      await AppPreferences.instance.setOnboardingCompleted();
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(widget.replay ? 'Zamknij' : 'Pomiń'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _pages[i],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _page == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _page == i
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                0,
                24,
                16 + MediaQuery.paddingOf(context).bottom,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (isLast) {
                      _finish();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                      );
                    }
                  },
                  child: Text(isLast ? 'Rozpocznij' : 'Dalej'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 96, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 32),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
