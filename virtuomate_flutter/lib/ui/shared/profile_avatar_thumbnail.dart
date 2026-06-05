import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/config/app_config.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/virtuomate_scope.dart';

/// User profile circle — shows saved coach portrait when available.
class ProfileAvatarThumbnail extends StatelessWidget {
  const ProfileAvatarThumbnail({
    this.size = 64,
    this.borderWidth = 2,
    this.showOnlineDot = false,
    super.key,
  });

  final double size;
  final double borderWidth;
  final bool showOnlineDot;

  String _resolveRef(String raw) {
    var path = raw.trim();
    if (path.isEmpty) return path;
    if (path.startsWith('file://')) {
      if (kIsWeb) return '';
      try {
        path = Uri.parse(path).toFilePath(windows: Platform.isWindows);
      } catch (_) {
        return '';
      }
    }
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (path.startsWith('/')) {
      final base = AppConfig.backendBaseUrl.trim();
      if (base.isNotEmpty) return Uri.parse(base).resolve(path).toString();
    }
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: VirtuoMateScope.of(context),
      builder: (context, _) {
        final c = VirtuoMateScope.of(context);
        final ref = _resolveRef(c.avatarImage);
        final hasImage = ref.isNotEmpty;

        Widget face;
        if (hasImage && (ref.startsWith('http://') || ref.startsWith('https://'))) {
          face = Image.network(
            ref,
            width: size,
            height: size,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => _placeholder(),
          );
        } else if (hasImage && !kIsWeb) {
          final file = File(ref);
          face = file.existsSync()
              ? Image.file(file, width: size, height: size, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder())
              : _placeholder();
        } else {
          face = _placeholder();
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: VirtuoMvpColors.cyan.withValues(alpha: 0.35),
                  width: borderWidth,
                ),
                gradient: hasImage
                    ? null
                    : const LinearGradient(
                        colors: [VirtuoMvpColors.purple, VirtuoMvpColors.blue],
                      ),
              ),
              child: ClipOval(child: face),
            ),
            if (showOnlineDot)
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: size * 0.16,
                  height: size * 0.16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: VirtuoMvpColors.green,
                    border: Border.all(color: VirtuoMvpColors.bg1, width: 2),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _placeholder() {
    return ColoredBox(
      color: VirtuoMvpColors.surface2,
      child: Icon(Icons.person_outline, color: VirtuoMvpColors.textMuted, size: size * 0.44),
    );
  }
}
