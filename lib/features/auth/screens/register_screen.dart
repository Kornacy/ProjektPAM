import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:city_issues/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const Color _brandDark = Color(0xFF07004D);

  bool _isLoading = false;
  String? _error;

  Future<void> _registerWithGoogle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await AuthService.instance.signInWithGoogle();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Rejestracja')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Center(
                child: SvgPicture.asset(
                  'assets/images/app_logo.svg',
                  width: 96,
                  height: 96,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Załóż konto przez Google',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Pierwsze logowanie kontem Google automatycznie utworzy Twoje konto w aplikacji.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 40),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: theme.colorScheme.onErrorContainer),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              OutlinedButton(
                onPressed: _isLoading ? null : _registerWithGoogle,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: theme.colorScheme.surface,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const _GoogleLogo(size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Zarejestruj się z Google',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _brandDark.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: _brandDark.withValues(alpha: 0.8)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Nie musisz tworzyć osobnego hasła — Google zadba o bezpieczeństwo Twojego konta.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _brandDark.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: const Text('Masz już konto? Zaloguj się'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(Rect.fromLTWH(0, 0, w, h), 2.4, 1.2, true, paint);

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(Rect.fromLTWH(0, 0, w, h), -0.6, 1.4, true, paint);

    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(Rect.fromLTWH(0, 0, w, h), 1.8, 1.2, true, paint);

    paint.color = const Color(0xFF34A853);
    canvas.drawArc(Rect.fromLTWH(0, 0, w, h), 0.6, 1.4, true, paint);

    paint.color = Colors.white;
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.38, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
