import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum AppTourHighlight {
  welcome,
  navigationTab,
  target,
}

class AppTourStep {
  const AppTourStep({
    required this.title,
    required this.body,
    required this.stackIndex,
    this.highlight = AppTourHighlight.target,
    this.navDestinationIndex,
    this.targetKey,
    this.fallbackRect,
    this.showLogo = false,
  });

  final String title;
  final String body;
  final int stackIndex;
  final AppTourHighlight highlight;
  final int? navDestinationIndex;
  final GlobalKey? targetKey;
  final Rect? fallbackRect;
  final bool showLogo;
}

class AppTourOverlay extends StatelessWidget {
  const AppTourOverlay({
    super.key,
    required this.step,
    required this.stepIndex,
    required this.stepCount,
    required this.navBarKey,
    required this.onNext,
    required this.onSkip,
    required this.isLast,
    required this.isReplay,
  });

  final AppTourStep step;
  final int stepIndex;
  final int stepCount;
  final GlobalKey navBarKey;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final bool isLast;
  final bool isReplay;

  Rect? _targetRect(BuildContext context) {
    switch (step.highlight) {
      case AppTourHighlight.welcome:
        return null;
      case AppTourHighlight.navigationTab:
        final navIndex = step.navDestinationIndex;
        if (navIndex == null) return null;
        final navContext = navBarKey.currentContext;
        if (navContext == null) return null;
        final box = navContext.findRenderObject() as RenderBox?;
        if (box == null || !box.hasSize) return null;
        final tabWidth = box.size.width / 4;
        final topLeft = box.localToGlobal(Offset(navIndex * tabWidth, 0));
        return Rect.fromLTWH(topLeft.dx, topLeft.dy, tabWidth, box.size.height);
      case AppTourHighlight.target:
        final targetContext = step.targetKey?.currentContext;
        if (targetContext != null) {
          final box = targetContext.findRenderObject() as RenderBox?;
          if (box != null && box.hasSize) {
            final topLeft = box.localToGlobal(Offset.zero);
            return Rect.fromLTWH(topLeft.dx, topLeft.dy, box.size.width, box.size.height);
          }
        }
        return step.fallbackRect;
    }
  }

  @override
  Widget build(BuildContext context) {
    final highlightRect = _targetRect(context);
    final media = MediaQuery.of(context);
    final cardMaxWidth = media.size.width - 48;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: AbsorbPointer(
              child: CustomPaint(
                painter: _SpotlightPainter(
                  highlightRect: highlightRect,
                  screenSize: media.size,
                ),
              ),
            ),
          ),
          if (highlightRect != null)
            Positioned(
              left: highlightRect.left - 6,
              top: highlightRect.top - 6,
              width: highlightRect.width + 12,
              height: highlightRect.height + 12,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(
                      step.highlight == AppTourHighlight.navigationTab ? 16 : 12,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 24,
            right: 24,
            top: _cardTop(media, highlightRect),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: cardMaxWidth),
                child: _TourCard(
                  step: step,
                  stepIndex: stepIndex,
                  stepCount: stepCount,
                  isLast: isLast,
                  isReplay: isReplay,
                  onNext: onNext,
                  onSkip: onSkip,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _cardTop(MediaQueryData media, Rect? highlightRect) {
    if (highlightRect == null) {
      return media.size.height * 0.22;
    }
    const cardHeightEstimate = 260.0;
    final below = highlightRect.bottom + 20;
    if (below + cardHeightEstimate < media.size.height - 24) {
      return below;
    }
    final above = highlightRect.top - cardHeightEstimate - 20;
    if (above > media.padding.top + 12) {
      return above;
    }
    return media.size.height * 0.18;
  }
}

class _TourCard extends StatelessWidget {
  const _TourCard({
    required this.step,
    required this.stepIndex,
    required this.stepCount,
    required this.isLast,
    required this.isReplay,
    required this.onNext,
    required this.onSkip,
  });

  final AppTourStep step;
  final int stepIndex;
  final int stepCount;
  final bool isLast;
  final bool isReplay;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Krok ${stepIndex + 1} z $stepCount',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(onPressed: onSkip, child: Text(isReplay ? 'Zamknij' : 'Pomiń')),
              ],
            ),
            if (step.showLogo) ...[
              Center(
                child: SvgPicture.asset(
                  'assets/images/app_logo.svg',
                  width: 88,
                  height: 88,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              step.title,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              step.body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onNext,
              child: Text(isLast ? 'Rozpocznij' : 'Dalej'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({
    required this.highlightRect,
    required this.screenSize,
  });

  final Rect? highlightRect;
  final Size screenSize;

  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Paint()..color = Colors.black.withValues(alpha: 0.72);
    final path = Path()..addRect(Rect.fromLTWH(0, 0, screenSize.width, screenSize.height));

    if (highlightRect != null) {
      final hole = RRect.fromRectAndRadius(
        highlightRect!.inflate(6),
        Radius.circular(highlightRect!.height > 80 ? 16 : 12),
      );
      path.addRRect(hole);
      path.fillType = PathFillType.evenOdd;
    }

    canvas.drawPath(path, overlay);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.highlightRect != highlightRect ||
        oldDelegate.screenSize != screenSize;
  }
}

class AppTourSteps {
  static List<AppTourStep> build({
    required GlobalKey mapFiltersKey,
    required GlobalKey mapFabKey,
    required GlobalKey settingsHelpKey,
  }) {
    return [
      const AppTourStep(
        title: 'Witaj w City Issues',
        body:
            'Zgłaszaj problemy miejskie w kilka chwil — dziury w drodze, '
            'zepsute latarnie, śmieci i inne usterki w Twojej okolicy.',
        stackIndex: 0,
        highlight: AppTourHighlight.welcome,
        showLogo: true,
      ),
      const AppTourStep(
        title: 'Mapa zgłoszeń',
        body:
            'Tu przeglądasz zgłoszenia innych mieszkańców. Kliknij marker, '
            'aby zobaczyć szczegóły sprawy.',
        stackIndex: 0,
        highlight: AppTourHighlight.navigationTab,
        navDestinationIndex: 0,
      ),
      AppTourStep(
        title: 'Filtry kategorii',
        body:
            'Włączaj i wyłączaj kategorie, aby szybciej znaleźć interesujące '
            'Cię zgłoszenia na mapie.',
        stackIndex: 0,
        targetKey: mapFiltersKey,
        fallbackRect: const Rect.fromLTWH(8, 120, 56, 56),
      ),
      AppTourStep(
        title: 'Twoja lokalizacja',
        body:
            'Ten przycisk centruje mapę na Twojej aktualnej pozycji GPS.',
        stackIndex: 0,
        targetKey: mapFabKey,
      ),
      const AppTourStep(
        title: 'Moje zgłoszenia',
        body:
            'Śledź status swoich zgłoszeń, podbijaj ważne sprawy '
            'i wracaj do szczegółów.',
        stackIndex: 1,
        highlight: AppTourHighlight.navigationTab,
        navDestinationIndex: 1,
      ),
      const AppTourStep(
        title: 'Nowe zgłoszenie',
        body:
            'Zrób zdjęcie problemu, wybierz kategorię i wyślij — GPS uzupełni '
            'lokalizację.',
        stackIndex: 0,
        highlight: AppTourHighlight.navigationTab,
        navDestinationIndex: 2,
      ),
      const AppTourStep(
        title: 'Profil i ustawienia',
        body:
            'Zmień motyw, kolor akcentu i zarządzaj kontem w zakładce profilu.',
        stackIndex: 2,
        highlight: AppTourHighlight.navigationTab,
        navDestinationIndex: 3,
      ),
      AppTourStep(
        title: 'Pomoc w aplikacji',
        body:
            'W każdej chwili możesz ponownie uruchomić ten przewodnik '
            'z sekcji Pomoc.',
        stackIndex: 2,
        targetKey: settingsHelpKey,
      ),
    ];
  }
}
