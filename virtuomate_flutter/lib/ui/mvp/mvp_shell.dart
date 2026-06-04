import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';

/// Full-screen gradient stack matching `virtuomate-mvp` `GradientScreen`.
class MvpShell extends StatelessWidget {
  const MvpShell({required this.body, super.key});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VirtuoMvpColors.bg0,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
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
            ),
            ColoredBox(color: VirtuoMvpColors.bg2.withValues(alpha: 0.35)),
            body,
          ],
        ),
      ),
    );
  }
}
