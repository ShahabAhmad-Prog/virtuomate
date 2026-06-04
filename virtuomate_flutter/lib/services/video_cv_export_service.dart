import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:virtuomate_flutter/core/models.dart';

/// Builds and shares a real Video CV package (HTML + narration script).
class VideoCvExportService {
  static Future<void> exportAndShare({
    required VideoCvDraft draft,
    required String avatarStyle,
    required String displayName,
    required String format,
  }) async {
    final ext = format == 'webm' ? 'webm' : 'html';
    final fileName = 'virtuomate_video_cv_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final content = format == 'webm'
        ? _buildWebmReadme(draft, avatarStyle, displayName)
        : _buildHtmlPackage(draft, avatarStyle, displayName);

    if (kIsWeb) {
      await Share.share(content, subject: 'VirtuoMate Video CV');
      return;
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: format == 'webm' ? 'text/plain' : 'text/html')],
      subject: 'VirtuoMate Video CV',
      text: 'Video CV export from VirtuoMate',
    );
  }

  static String _buildWebmReadme(VideoCvDraft draft, String avatarStyle, String displayName) {
    return '''
VirtuoMate Video CV — WebM narration package
==========================================
Candidate: ${draft.fullName.isNotEmpty ? draft.fullName : displayName}
Headline: ${draft.headline}
Avatar style: $avatarStyle
Duration target: ${draft.durationMinutes}:${draft.durationSeconds.toString().padLeft(2, '0')}

NARRATION SCRIPT (use with any video editor + TTS):
${draft.narrationScript}

---
This package contains your AI-generated narration script.
Record avatar video in VirtuoMate or import this script into your editor to produce WebM/MP4.
''';
  }

  static String _buildHtmlPackage(VideoCvDraft draft, String avatarStyle, String displayName) {
    final name = draft.fullName.isNotEmpty ? draft.fullName : displayName;
    final script = draft.narrationScript.replaceAll('<', '&lt;').replaceAll('>', '&gt;');
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <title>VirtuoMate Video CV — $name</title>
  <style>
    body { font-family: system-ui, sans-serif; background: #0b1220; color: #e8eef7; padding: 24px; max-width: 720px; margin: auto; }
    h1 { color: #3be7ff; }
    .card { background: #141c2e; border: 1px solid #2a3550; border-radius: 12px; padding: 16px; margin: 12px 0; }
    .label { color: #8b9cb8; font-size: 12px; text-transform: uppercase; }
    .script { line-height: 1.6; white-space: pre-wrap; }
  </style>
</head>
<body>
  <h1>$name</h1>
  <p>${draft.headline}</p>
  <div class="card"><div class="label">Summary</div><p>${draft.summary}</p></div>
  <div class="card"><div class="label">Skills</div><p>${draft.skills}</p></div>
  <div class="card"><div class="label">Experience</div><p>${draft.experience}</p></div>
  <div class="card"><div class="label">Education</div><p>${draft.education}</p></div>
  <div class="card"><div class="label">Narration script</div><p class="script">$script</p></div>
  <p><small>Exported from VirtuoMate · Avatar: $avatarStyle · ${DateTime.now().toIso8601String()}</small></p>
</body>
</html>
''';
  }
}
