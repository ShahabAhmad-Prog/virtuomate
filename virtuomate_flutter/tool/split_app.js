const fs = require('fs');
const path = require('path');

const root = path.join(__dirname, '..', 'lib', 'ui');
const appPath = path.join(root, 'app.dart');
const lines = fs.readFileSync(appPath, 'utf8').split(/\r?\n/);

function slice(start, end) {
  return lines.slice(start - 1, end).join('\n') + '\n';
}

fs.writeFileSync(path.join(root, 'routes.dart'), slice(50, 72));

const appTextHeader = `import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/ui/virtuomate_scope.dart';

`;
fs.writeFileSync(path.join(root, 'app_text.dart'), appTextHeader + slice(74, 152));

const scopeHeader = `import 'dart:io';

import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/config/app_config.dart';
import 'package:virtuomate_flutter/core/models.dart';
import 'package:virtuomate_flutter/services/admin_api_service.dart';
import 'package:virtuomate_flutter/services/app_service.dart';
import 'package:virtuomate_flutter/services/storage_service.dart';
import 'package:virtuomate_flutter/services/video_cv_export_service.dart';
import 'package:virtuomate_flutter/services/video_cv_render_service.dart';

`;
fs.writeFileSync(path.join(root, 'virtuomate_scope.dart'), scopeHeader + slice(154, 631));

const authHeader = `import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/config/app_config.dart';
import 'package:virtuomate_flutter/ui/app_text.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_shell.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';
import 'package:virtuomate_flutter/ui/routes.dart';
import 'package:virtuomate_flutter/ui/shared/form_validators.dart';
import 'package:virtuomate_flutter/ui/virtuomate_scope.dart';

`;
fs.writeFileSync(
  path.join(root, 'screens', 'auth_screens.dart'),
  authHeader + slice(935, 1074) + '\n' + slice(1140, 1423) + '\n' + slice(1425, 1707),
);

const removeRanges = [
  [1425, 1707],
  [1140, 1423],
  [935, 1074],
  [154, 631],
  [74, 152],
  [50, 72],
];
const newLines = [...lines];
for (const [start, end] of removeRanges) {
  newLines.splice(start - 1, end - start + 1);
}
let appNew = newLines.join('\n');
const marker =
  "export 'package:virtuomate_flutter/services/tts_speaker.dart' show applyVoiceProfileToTts;";
const insert = `import 'package:virtuomate_flutter/ui/routes.dart';
import 'package:virtuomate_flutter/ui/app_text.dart';
import 'package:virtuomate_flutter/ui/virtuomate_scope.dart';
import 'package:virtuomate_flutter/ui/screens/auth_screens.dart';
`;
if (appNew.includes(marker)) {
  appNew = appNew.replace(marker, marker + '\n' + insert);
}
fs.writeFileSync(appPath, appNew);
console.log('split ok, app.dart lines:', appNew.split(/\r?\n/).length);
