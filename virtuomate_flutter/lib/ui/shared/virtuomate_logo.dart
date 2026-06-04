import 'package:flutter/material.dart';

/// Brand image paths (see `assets/images/`).
abstract final class VirtuoMateBrandAssets {
  static const logo = 'assets/images/virtuomate_logo.png';
}

/// Official VirtuoMate logo — welcome screen only (avoids repeated PNG decode on the UI thread).
class VirtuoMateLogo extends StatelessWidget {
  const VirtuoMateLogo.welcome({super.key});

  static const double welcomeHeight = 72;
  static const double welcomeWidth = 280;

  static Future<void> precacheWelcome(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return precacheImage(
      const AssetImage(VirtuoMateBrandAssets.logo),
      context,
      size: Size(welcomeWidth * dpr, welcomeHeight * dpr),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final image = Image.asset(
      VirtuoMateBrandAssets.logo,
      height: welcomeHeight,
      width: welcomeWidth,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      cacheHeight: (welcomeHeight * dpr).round(),
      cacheWidth: (welcomeWidth * dpr).round(),
      gaplessPlayback: true,
      semanticLabel: 'VirtuoMate',
    );

    return RepaintBoundary(
      child: SizedBox(width: double.infinity, child: Center(child: image)),
    );
  }
}
