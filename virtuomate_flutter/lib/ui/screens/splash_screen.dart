import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/routes.dart';
import 'package:virtuomate_flutter/ui/shared/virtuomate_logo.dart';
import 'package:virtuomate_flutter/ui/virtuomate_scope.dart';

/// Branded in-app splash shown on cold start (after native launch screen).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fade = CurvedAnimation(parent: _pulse, curve: const Interval(0, 0.45, curve: Curves.easeOut));
    _scale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: const Interval(0, 0.55, curve: Curves.easeOutCubic)),
    );
    _pulse.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    await VirtuoMateLogo.precacheWelcome(context);
    final c = VirtuoMateScope.of(context);
    await c.loadLocaleFromDevice();
    await Future<void>.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;
    final destination = c.user != null ? AppRoutes.dashboard : AppRoutes.welcome;
    Navigator.pushReplacementNamed(context, destination);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VirtuoMvpColors.bg0,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              VirtuoMvpColors.bg0,
              VirtuoMvpColors.bg1,
              VirtuoMvpColors.bg2,
            ],
            stops: [0, 0.55, 1],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const VirtuoMateLogo.welcome(),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: VirtuoMvpColors.cyan.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Initializing neural coach…',
                      style: TextStyle(
                        color: VirtuoMvpColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
