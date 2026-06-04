const fs = require('fs');
const path = require('path');

const root = path.join(__dirname, '..', 'lib', 'ui');
const appPath = path.join(root, 'app.dart');
const lines = fs.readFileSync(appPath, 'utf8').split(/\r?\n/);

function findLine(prefix) {
  return lines.findIndex((l) => l.startsWith(prefix)) + 1;
}

const dashStart = findLine('class DashboardScreen');
const avatarStart = findLine('class AvatarScreen');
const settingsStart = findLine('class SettingsScreen');
const settingsEnd = findLine('class _SettingsScreenState');
// find end of settings - next class or EOF
let settingsEndLine = lines.length;
for (let i = settingsStart; i < lines.length; i++) {
  if (lines[i].startsWith('class ') && !lines[i].includes('Settings')) {
    settingsEndLine = i;
    break;
  }
}
// _SettingsScreenState is the state class - find closing of file
settingsEndLine = lines.length;

function slice(start, end) {
  return lines.slice(start - 1, end).join('\n') + '\n';
}

const dashHeader = `import 'package:flutter/material.dart';
import 'dart:io';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_shell.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';
import 'package:virtuomate_flutter/ui/routes.dart';
import 'package:virtuomate_flutter/ui/shared/responsive.dart';
import 'package:virtuomate_flutter/ui/virtuomate_bindings.dart';

`;

fs.writeFileSync(
  path.join(root, 'screens', 'dashboard_screen.dart'),
  dashHeader + slice(dashStart, avatarStart - 1),
);

const settingsHeader = `import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/app_text.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_shell.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';
import 'package:virtuomate_flutter/ui/routes.dart';
import 'package:virtuomate_flutter/ui/virtuomate_bindings.dart';

`;

fs.writeFileSync(
  path.join(root, 'screens', 'settings_screen.dart'),
  settingsHeader + slice(settingsStart, settingsEndLine),
);

// Remove dashboard and settings from app.dart
const newLines = [...lines];
newLines.splice(dashStart - 1, avatarStart - dashStart);
const settingsStart2 = findLine('class SettingsScreen') - (avatarStart - dashStart);
const settingsEnd2 = newLines.length;
// re-find settings in new array
const sIdx = newLines.findIndex((l) => l.startsWith('class SettingsScreen'));
if (sIdx >= 0) {
  newLines.splice(sIdx, newLines.length - sIdx);
}
let appNew = newLines.join('\n');
const insertMarker = "import 'package:virtuomate_flutter/ui/screens/auth_screens.dart';";
const extra = `import 'package:virtuomate_flutter/ui/screens/dashboard_screen.dart';
import 'package:virtuomate_flutter/ui/screens/settings_screen.dart';
`;
if (appNew.includes(insertMarker)) {
  appNew = appNew.replace(insertMarker, insertMarker + '\n' + extra);
}
fs.writeFileSync(appPath, appNew);
console.log('dashboard/settings split, lines:', appNew.split(/\r?\n/).length);
