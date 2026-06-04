const fs = require('fs');
const path = require('path');

const root = path.join(__dirname, '..', 'lib', 'ui');
const screens = path.join(root, 'screens');
const shared = path.join(root, 'shared');
const appPath = path.join(root, 'app.dart');
const lines = fs.readFileSync(appPath, 'utf8').split(/\r?\n/);

function findLine(prefix) {
  const idx = lines.findIndex((l) => l.startsWith(prefix));
  if (idx < 0) throw new Error(`Not found: ${prefix}`);
  return idx + 1;
}

function slice(start, end) {
  return lines.slice(start - 1, end).join('\n') + '\n';
}

const ranges = {
  avatar: [findLine('class AvatarScreen'), findLine('class SessionScreen') - 1],
  session: [findLine('class SessionScreen'), findLine('class RolePlayScreen') - 1],
  rolePlay: [findLine('class RolePlayScreen'), findLine('class _VoiceSyncDiagnosticCard') - 1],
  voiceCard: [findLine('class _VoiceSyncDiagnosticCard'), findLine('class FeedbackScreen') - 1],
  feedback: [findLine('class FeedbackScreen'), findLine('class PremiumScreen') - 1],
  premium: [findLine('class PremiumScreen'), findLine('class _ChartDot') - 1],
  analytics: [findLine('class _ChartDot'), lines.length],
};

const files = {
  voiceCard: {
    path: path.join(shared, 'voice_sync_diagnostic_card.dart'),
    header: `import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';
import 'package:virtuomate_flutter/ui/virtuomate_scope.dart';

`,
    body: () => slice(...ranges.voiceCard).replace(/_VoiceSyncDiagnosticCard/g, 'VoiceSyncDiagnosticCard'),
  },
  avatar: {
    path: path.join(screens, 'avatar_screen.dart'),
    header: `import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_shell.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';
import 'package:virtuomate_flutter/ui/routes.dart';
import 'package:virtuomate_flutter/ui/virtuomate_bindings.dart';

`,
    body: () => slice(...ranges.avatar),
  },
  session: {
    path: path.join(screens, 'session_screen.dart'),
    header: `import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:virtuomate_flutter/services/tts_speaker.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_shell.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';
import 'package:virtuomate_flutter/ui/routes.dart';
import 'package:virtuomate_flutter/ui/shared/avatar_presence.dart';
import 'package:virtuomate_flutter/ui/shared/voice_sync_diagnostic_card.dart';
import 'package:virtuomate_flutter/ui/virtuomate_bindings.dart';

`,
    body: () =>
      slice(...ranges.session).replace(/_VoiceSyncDiagnosticCard/g, 'VoiceSyncDiagnosticCard'),
  },
  rolePlay: {
    path: path.join(screens, 'role_play_screen.dart'),
    header: `import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:virtuomate_flutter/services/tts_speaker.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_shell.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';
import 'package:virtuomate_flutter/ui/routes.dart';
import 'package:virtuomate_flutter/ui/shared/voice_sync_diagnostic_card.dart';
import 'package:virtuomate_flutter/ui/virtuomate_bindings.dart';

`,
    body: () =>
      slice(...ranges.rolePlay).replace(/_VoiceSyncDiagnosticCard/g, 'VoiceSyncDiagnosticCard'),
  },
  feedback: {
    path: path.join(screens, 'feedback_screen.dart'),
    header: `import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_shell.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';
import 'package:virtuomate_flutter/ui/shared/responsive.dart';
import 'package:virtuomate_flutter/ui/virtuomate_bindings.dart';

`,
    body: () => slice(...ranges.feedback),
  },
  premium: {
    path: path.join(screens, 'premium_screen.dart'),
    header: `import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_shell.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';
import 'package:virtuomate_flutter/ui/routes.dart';
import 'package:virtuomate_flutter/ui/virtuomate_bindings.dart';

`,
    body: () => slice(...ranges.premium),
  },
  analytics: {
    path: path.join(screens, 'analytics_screen.dart'),
    header: `import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_shell.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';
import 'package:virtuomate_flutter/ui/virtuomate_bindings.dart';

`,
    body: () => slice(...ranges.analytics),
  },
};

// Write files in order (one-by-one)
const order = ['voiceCard', 'avatar', 'session', 'rolePlay', 'feedback', 'premium', 'analytics'];
for (const key of order) {
  const f = files[key];
  fs.writeFileSync(f.path, f.header + f.body());
  console.log('wrote', path.basename(f.path));
}

// Remove from app.dart (reverse line order)
const removeOrder = ['analytics', 'premium', 'feedback', 'voiceCard', 'rolePlay', 'session', 'avatar'];
let newLines = [...lines];
for (const key of removeOrder) {
  const [start, end] = ranges[key];
  newLines.splice(start - 1, end - start + 1);
  // Adjust subsequent ranges - recompute not needed if we go reverse by original line numbers
}
// Re-read and remove by finding classes in newLines
function removeClass(className, nextClassName) {
  const start = newLines.findIndex((l) => l.startsWith(`class ${className}`));
  if (start < 0) return;
  let end = newLines.length;
  if (nextClassName) {
    const next = newLines.findIndex((l) => l.startsWith(`class ${nextClassName}`));
    if (next > start) end = next;
  }
  newLines.splice(start, end - start);
}

removeClass('_ChartDot', null);
removeClass('PremiumScreen', '_ChartDot');
removeClass('FeedbackScreen', 'PremiumScreen');
removeClass('_VoiceSyncDiagnosticCard', 'FeedbackScreen');
removeClass('RolePlayScreen', '_VoiceSyncDiagnosticCard');
removeClass('SessionScreen', 'RolePlayScreen');
removeClass('AvatarScreen', 'SessionScreen');

let appNew = newLines.join('\n');
const imports = `import 'package:virtuomate_flutter/ui/screens/avatar_screen.dart';
import 'package:virtuomate_flutter/ui/screens/session_screen.dart';
import 'package:virtuomate_flutter/ui/screens/role_play_screen.dart';
import 'package:virtuomate_flutter/ui/screens/feedback_screen.dart';
import 'package:virtuomate_flutter/ui/screens/premium_screen.dart';
import 'package:virtuomate_flutter/ui/screens/analytics_screen.dart';
`;
const marker = "import 'package:virtuomate_flutter/ui/screens/settings_screen.dart';";
if (appNew.includes(marker)) {
  appNew = appNew.replace(marker, marker + '\n' + imports);
}

// Strip unused imports from app.dart heuristically - run analyze after
fs.writeFileSync(appPath, appNew);
console.log('app.dart lines:', appNew.split(/\r?\n/).length);
