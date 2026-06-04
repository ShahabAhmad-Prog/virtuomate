import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';
import 'package:virtuomate_flutter/ui/virtuomate_scope.dart';

class VoiceSyncDiagnosticCard extends StatelessWidget {
  const VoiceSyncDiagnosticCard({super.key, required this.controller});

  final VirtuoMateController controller;

  @override
  Widget build(BuildContext context) {
    final hasAvatarImage = controller.avatarImage.trim().isNotEmpty;
    final hasVoiceProfile = controller.voiceProfile.trim().isNotEmpty;
    final isSynced = hasVoiceProfile && controller.avatarStyle.trim().isNotEmpty;

    return VCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Voice sync diagnostic',
            style: TextStyle(
              color: VirtuoMvpColors.text,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Avatar style: ${controller.avatarStyle}',
            style: const TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 12),
          ),
          Text(
            'Voice profile: ${controller.voiceProfile}',
            style: const TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 12),
          ),
          Text(
            'Avatar image: ${hasAvatarImage ? 'selected' : 'not selected'}',
            style: const TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            'Sync state: ${isSynced ? 'active' : 'incomplete'}',
            style: TextStyle(
              color: isSynced ? VirtuoMvpColors.green : VirtuoMvpColors.amber,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

