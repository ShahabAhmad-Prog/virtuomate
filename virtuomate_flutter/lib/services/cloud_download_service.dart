import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:virtuomate_flutter/network/connection_error.dart';

/// Result of downloading a cloud render for in-app preview or sharing.
class CloudDownloadResult {
  const CloudDownloadResult({
    required this.localPath,
    required this.fileName,
    required this.savedLocationHint,
  });

  final String localPath;
  final String fileName;
  final String savedLocationHint;
}

/// Downloads cloud render artifacts, previews locally, and shares them.
class CloudDownloadService {
  static Future<void> openInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<CloudDownloadResult> downloadVideoForPreview({
    required String url,
    required String fileName,
  }) async {
    Object? lastError;
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(minutes: 3));
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception('Download failed (${response.statusCode}).');
        }
        final dir = await _videoCvDirectory();
        final path = '${dir.path}/$fileName';
        final file = File(path);
        await file.writeAsBytes(response.bodyBytes, flush: true);
        return CloudDownloadResult(
          localPath: path,
          fileName: fileName,
          savedLocationHint: savedLocationHint(dir.path),
        );
      } on TimeoutException catch (e) {
        lastError = e;
      } on SocketException catch (e) {
        lastError = e;
      } on http.ClientException catch (e) {
        lastError = e;
      }
      if (attempt == 0) {
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }
    throw Exception(
      friendlyConnectionError(
        lastError ?? Exception('Download failed'),
        apiBaseUrl: url,
      ),
    );
  }

  static Future<void> downloadAndShare({
    required String url,
    required String fileName,
    String mimeType = 'application/json',
  }) async {
    final result = await downloadVideoForPreview(url: url, fileName: fileName);
    await shareLocalFile(
      localPath: result.localPath,
      fileName: result.fileName,
      mimeType: mimeType,
    );
  }

  static Future<void> shareLocalFile({
    required String localPath,
    required String fileName,
    String mimeType = 'video/mp4',
  }) async {
    await Share.shareXFiles(
      [XFile(localPath, mimeType: mimeType, name: fileName)],
      subject: 'VirtuoMate Video CV',
      text: 'Video CV from VirtuoMate',
    );
  }

  static String savedLocationHint(String directoryPath) {
    if (Platform.isAndroid) {
      return 'Stored in app folder:\n$directoryPath\n'
          'Use Save & Share below, then pick Files or Downloads to keep a copy outside the app.';
    }
    if (Platform.isIOS) {
      return 'Stored in app Documents:\n$directoryPath\n'
          'Use Save & Share, then Save to Files to move it to iCloud or On My iPhone.';
    }
    return 'Stored at:\n$directoryPath';
  }

  static Future<Directory> _videoCvDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/video_cv');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}
