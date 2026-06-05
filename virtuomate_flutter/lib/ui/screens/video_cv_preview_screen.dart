import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:open_file/open_file.dart';
import 'package:video_player/video_player.dart';
import 'package:virtuomate_flutter/config/app_config.dart';
import 'package:virtuomate_flutter/network/api_error_message.dart';
import 'package:virtuomate_flutter/services/cloud_download_service.dart';
import 'package:virtuomate_flutter/core/avatar_customization.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_shell.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';
import 'package:virtuomate_flutter/ui/shared/ui_helpers.dart';
import 'package:virtuomate_flutter/ui/virtuomate_bindings.dart';

class VideoCvPreviewScreen extends StatefulWidget {
  const VideoCvPreviewScreen({super.key});

  @override
  State<VideoCvPreviewScreen> createState() => _VideoCvPreviewScreenState();
}

class _VideoCvPreviewScreenState extends State<VideoCvPreviewScreen> {
  final FlutterTts _tts = FlutterTts();

  String _exportFormat = 'mp4';
  double _voicePlayback = 0;
  bool _isVoicePlaying = false;
  Timer? _voiceTimer;
  int _estimatedSeconds = 0;
  int _elapsedSeconds = 0;

  bool _rendering = false;
  bool _sharing = false;
  String? _lastError;
  VideoPlayerController? _videoController;
  String? _localPreviewPath;
  String? _savedLocationHint;
  String? _remoteVideoUrl;
  bool _externalPreviewOnly = false;
  bool _autoLoadAttempted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_autoLoadAttempted) return;
    _autoLoadAttempted = true;
    final url = VirtuoMateScope.of(context).videoCvDraft.renderVideoUrl;
    if (url.isNotEmpty && _videoController == null && !_rendering) {
      _loadLastRenderedPreview(VirtuoMateScope.of(context));
    }
  }

  @override
  void dispose() {
    _voiceTimer?.cancel();
    _tts.stop();
    _disposeVideo();
    super.dispose();
  }

  void _disposeVideo() {
    _videoController?.dispose();
    _videoController = null;
  }

  bool _isVideoPlayerChannelError(Object error) {
    final msg = error.toString();
    return error is PlatformException ||
        msg.contains('AndroidVideoPlayerApi') ||
        msg.contains('channel-error') ||
        msg.contains('createForTextureView');
  }

  Future<void> _openVideoExternal() async {
    if (_localPreviewPath != null) {
      await OpenFile.open(_localPreviewPath!);
      return;
    }
    if (_remoteVideoUrl != null && _remoteVideoUrl!.isNotEmpty) {
      await VirtuoMateScope.of(context).openCloudRenderPackage(_remoteVideoUrl!);
    }
  }

  Future<void> _prepareVideoPreview({
    required String videoUrl,
    required String format,
    required VirtuoMateController c,
    String? locationHint,
  }) async {
    _remoteVideoUrl = videoUrl;
    _externalPreviewOnly = false;
    _disposeVideo();

    CloudDownloadResult? downloaded;
    try {
      downloaded = await c.downloadVideoCvForPreview(url: videoUrl, format: format);
      _localPreviewPath = downloaded.localPath;
      _savedLocationHint = downloaded.savedLocationHint;
    } catch (e) {
      _localPreviewPath = null;
      _savedLocationHint = locationHint ??
          'Video is on cloud storage. Tap Open video to watch in your phone player.';
    }

    if (_localPreviewPath != null) {
      try {
        await _loadVideoPreview(_localPreviewPath!, locationHint: _savedLocationHint);
        return;
      } catch (e) {
        if (!_isVideoPlayerChannelError(e)) rethrow;
      }
    }

    try {
      await _loadVideoPreviewFromUrl(videoUrl, locationHint: _savedLocationHint ?? locationHint);
      return;
    } catch (_) {
      // Fall back to external player when in-app preview cannot load.
    }

    if (!mounted) return;
    setState(() {
      _externalPreviewOnly = true;
      _lastError = null;
    });
  }

  Future<void> _loadVideoPreviewFromUrl(String url, {String? locationHint}) async {
    _disposeVideo();
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await controller.initialize().timeout(const Duration(minutes: 2));
    } catch (_) {
      controller.dispose();
      rethrow;
    }
    controller.setLooping(false);
    controller.addListener(() {
      if (mounted) setState(() {});
    });
    if (!mounted) {
      controller.dispose();
      return;
    }
    setState(() {
      _videoController = controller;
      _localPreviewPath = null;
      _savedLocationHint = locationHint ??
          'Streaming preview from cloud. Tap Save & Share to download a copy to your device.';
    });
  }

  Future<void> _loadVideoPreview(String localPath, {String? locationHint}) async {
    _disposeVideo();
    final controller = VideoPlayerController.file(File(localPath));
    await controller.initialize();
    controller.setLooping(false);
    controller.addListener(() {
      if (mounted) setState(() {});
    });
    if (!mounted) {
      controller.dispose();
      return;
    }
    setState(() {
      _videoController = controller;
      _localPreviewPath = localPath;
      _savedLocationHint = locationHint;
    });
  }

  Future<void> _generateVideoPreview(VirtuoMateController c, String script) async {
    if (script.isEmpty) {
      setState(() => _lastError = 'Generate a narration script in the Video CV wizard first.');
      return;
    }
    if (c.videoCvRender == null) {
      setState(() => _lastError =
          'Cloud video API is unavailable. Sign in and run with USE_BACKEND_API=true (see .\\scripts\\run_dev.ps1).');
      return;
    }
    setState(() {
      _rendering = true;
      _lastError = null;
      _localPreviewPath = null;
      _savedLocationHint = null;
      _remoteVideoUrl = null;
      _externalPreviewOnly = false;
    });
    _disposeVideo();

    try {
      final draft = c.videoCvDraft;
      c.saveVideoCvDraft(draft.copyWith(exportFormat: _exportFormat));
      final fmt = _exportFormat == 'webm' ? 'webm' : 'mp4';

      final videoUrl = await c.submitCloudVideoCvRender();
      if (videoUrl == null || videoUrl.isEmpty) {
        throw Exception('Video render did not return a URL.');
      }

      await _prepareVideoPreview(videoUrl: videoUrl, format: fmt, c: c);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _externalPreviewOnly
                ? 'Video ready — tap Open video to watch in your phone player.'
                : 'Video preview ready — watch below, then Save & Share if you like it.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = friendlyApiError(e);
      setState(() => _lastError = msg);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 8)),
      );
    } finally {
      if (mounted) setState(() => _rendering = false);
    }
  }

  Future<void> _loadLastRenderedPreview(VirtuoMateController c) async {
    final url = c.videoCvDraft.renderVideoUrl;
    if (url.isEmpty) return;
    setState(() => _rendering = true);
    _disposeVideo();
    try {
      final fmt = c.videoCvDraft.exportFormat == 'webm' ? 'webm' : 'mp4';
      await _prepareVideoPreview(videoUrl: url, format: fmt, c: c);
    } catch (e) {
      if (!mounted) return;
      final msg = friendlyApiError(e);
      setState(() => _lastError = msg);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } finally {
      if (mounted) setState(() => _rendering = false);
    }
  }

  Future<void> _shareVideo(VirtuoMateController c) async {
    final path = _localPreviewPath;
    final fmt = _exportFormat == 'webm' ? 'webm' : 'mp4';
    setState(() => _sharing = true);
    try {
      if (path != null) {
        await c.shareVideoCvFile(localPath: path, format: fmt);
        return;
      }
      final url = c.videoCvDraft.renderVideoUrl;
      if (url.isEmpty) return;
      final downloaded = await c.downloadVideoCvForPreview(url: url, format: fmt);
      _localPreviewPath = downloaded.localPath;
      _savedLocationHint = downloaded.savedLocationHint;
      await c.shareVideoCvFile(localPath: downloaded.localPath, format: fmt);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  int _estimateDurationSeconds(String script) {
    final words = script.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    if (words == 0) return 60;
    return (words / 2.5).ceil().clamp(30, 600);
  }

  Future<void> _toggleVoicePlayback(VirtuoMateController c, String script) async {
    if (script.isEmpty) return;
    if (_isVoicePlaying) {
      _voiceTimer?.cancel();
      await _tts.stop();
      if (mounted) setState(() => _isVoicePlaying = false);
      return;
    }

    _estimatedSeconds = _estimateDurationSeconds(script);
    _elapsedSeconds = 0;
    _voicePlayback = 0;
    setState(() => _isVoicePlaying = true);
    await applyVoiceProfileToTts(_tts, c.encodedVoiceProfile);

    _voiceTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _elapsedSeconds++;
        _voicePlayback = (_elapsedSeconds / _estimatedSeconds).clamp(0.0, 1.0);
      });
      if (_elapsedSeconds >= _estimatedSeconds) {
        t.cancel();
        setState(() => _isVoicePlaying = false);
      }
    });

    await _tts.speak(script);
    if (mounted) {
      _voiceTimer?.cancel();
      setState(() {
        _isVoicePlaying = false;
        _voicePlayback = 1;
      });
    }
  }

  String _formatDuration(int totalSec) {
    final m = totalSec ~/ 60;
    final s = totalSec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final c = VirtuoMateScope.of(context);
    final draft = c.videoCvDraft;
    final script = draft.narrationScript;
    final totalSec = _isVoicePlaying ? _estimatedSeconds : _estimateDurationSeconds(script);
    final hasVideoPreview = (_videoController != null && _videoController!.value.isInitialized) ||
        _externalPreviewOnly;
    final canCloudRender = c.videoCvRender != null && script.isNotEmpty;

    return MvpShell(
      body: Column(
        children: [
          MvpTopBar(
            title: 'Video CV Preview',
            right: IconButton(
              icon: const Icon(Icons.edit_outlined, color: VirtuoMvpColors.textMuted, size: 20),
              onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.videoCv),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(VirtuoMvpSpacing.lg, 0, VirtuoMvpSpacing.lg, 8),
              child: _VideoPreviewPanel(
                rendering: _rendering,
                controller: _videoController,
                hasVideo: hasVideoPreview,
                externalPreview: _externalPreviewOnly,
                onTogglePlay: () {
                  final vc = _videoController;
                  if (vc == null) return;
                  setState(() {
                    if (vc.value.isPlaying) {
                      vc.pause();
                    } else {
                      vc.play();
                    }
                  });
                },
                onOpenExternal: _openVideoExternal,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(VirtuoMvpSpacing.lg, 0, VirtuoMvpSpacing.lg, VirtuoMvpSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _externalPreviewOnly
                        ? 'Video saved — tap Open video to watch in VLC/Photos, or Save & Share below.'
                        : hasVideoPreview
                            ? 'Step 2: Tap Save & Share when you are happy with the preview.'
                            : 'Step 1: Tap Generate video preview — your MP4 will play above.',
                    style: const TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 11, height: 1.35),
                    textAlign: TextAlign.center,
                  ),
                  if (AppConfig.useBackendApi) ...[
                    const SizedBox(height: 4),
                    Text(
                      'API: ${AppConfig.backendBaseUrl}',
                      style: const TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 9),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (_lastError != null) ...[
                    const SizedBox(height: 10),
                    VCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _lastError!,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 11, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_savedLocationHint != null && hasVideoPreview) ...[
                    const SizedBox(height: 10),
                    VCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.folder_outlined, color: VirtuoMvpColors.cyan, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Where is my video?',
                                style: TextStyle(
                                  color: VirtuoMvpColors.text,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _savedLocationHint!,
                            style: const TextStyle(
                              color: VirtuoMvpColors.textMuted,
                              fontSize: 10,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  VCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.memory, color: VirtuoMvpColors.cyan, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Video CV Details',
                              style: TextStyle(color: VirtuoMvpColors.text, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _detailRow('Duration (est.)', _formatDuration(totalSec)),
                        _detailRow('Quality', '720p MP4 (FFmpeg + TTS)'),
                        _detailRow(
                          'Avatar & lip-sync',
                          c.avatarImage.isNotEmpty && !c.avatarUseTemplate
                              ? 'Your portrait — mouth animates with narration'
                              : 'Enable My portrait in Customize Avatar for lip-sync',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Export Format',
                    style: TextStyle(color: VirtuoMvpColors.text, fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  _exportTile('MP4 video (FFmpeg + AI voice)', 'Real video file', 'High', 'mp4'),
                  const SizedBox(height: 8),
                  _exportTile('WebM video (FFmpeg)', 'Alternative video format', 'High', 'webm'),
                  if (script.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    VCard(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        script,
                        style: const TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 11, height: 1.4),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  GradientPrimaryButton(
                    title: _rendering
                        ? 'Generating video (1–2 min)…'
                        : hasVideoPreview
                            ? 'Regenerate video preview'
                            : 'Generate video preview',
                    icon: Icons.movie_creation_outlined,
                    onPressed: (_rendering || !canCloudRender) ? null : () => _generateVideoPreview(c, script),
                  ),
                  const SizedBox(height: 10),
                  if (draft.renderVideoUrl.isNotEmpty && !hasVideoPreview && !_rendering)
                    VButton(
                      title: 'Load last rendered video',
                      variant: VButtonVariant.outline,
                      icon: Icons.history,
                      expanded: true,
                      onPressed: () => _loadLastRenderedPreview(c),
                    ),
                  if (hasVideoPreview && _externalPreviewOnly) ...[
                    const SizedBox(height: 10),
                    VButton(
                      title: 'Open video in phone player',
                      variant: VButtonVariant.primary,
                      icon: Icons.open_in_new,
                      expanded: true,
                      onPressed: _openVideoExternal,
                    ),
                  ],
                  if (hasVideoPreview) ...[
                    const SizedBox(height: 10),
                    VButton(
                      title: _sharing ? 'Opening share sheet…' : 'Save & Share video',
                      variant: VButtonVariant.primary,
                      icon: Icons.ios_share,
                      expanded: true,
                      onPressed: _sharing ? null : () => _shareVideo(c),
                    ),
                  ],
                  const SizedBox(height: 10),
                  VButton(
                    title: _isVoicePlaying ? 'Stop voice preview' : 'Preview narration voice only',
                    variant: VButtonVariant.ghost,
                    icon: Icons.record_voice_over_outlined,
                    expanded: true,
                    onPressed: script.isEmpty ? null : () => _toggleVoicePlayback(c, script),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Coach voice: ${coachVoiceSummary(gender: c.resolvedVoice.gender, toneId: c.resolvedVoice.toneId)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: VirtuoMvpColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_isVoicePlaying) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _voicePlayback.clamp(0.0, 1.0),
                        minHeight: 4,
                        backgroundColor: VirtuoMvpColors.stroke,
                        color: VirtuoMvpColors.cyan,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 11)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: VirtuoMvpColors.text, fontWeight: FontWeight.w700, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _exportTile(String title, String size, String quality, String format) {
    final selected = _exportFormat == format;
    return InkWell(
      onTap: () => setState(() => _exportFormat = format),
      borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
          color: VirtuoMvpColors.surface,
          border: Border.all(
            color: selected ? VirtuoMvpColors.cyan : VirtuoMvpColors.stroke,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: VirtuoMvpColors.text, fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                  Text('$size • $quality quality', style: const TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 10)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? VirtuoMvpColors.cyan : VirtuoMvpColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoPreviewPanel extends StatelessWidget {
  const _VideoPreviewPanel({
    required this.rendering,
    required this.controller,
    required this.hasVideo,
    required this.externalPreview,
    required this.onTogglePlay,
    required this.onOpenExternal,
  });

  final bool rendering;
  final VideoPlayerController? controller;
  final bool hasVideo;
  final bool externalPreview;
  final VoidCallback onTogglePlay;
  final VoidCallback onOpenExternal;

  String _formatTime(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
            child: ColoredBox(
              color: Colors.black,
              child: rendering
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: VirtuoMvpColors.cyan),
                        SizedBox(height: 12),
                        Text(
                          'Rendering your Video CV…',
                          style: TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : externalPreview
                    ? Material(
                        color: const Color(0xFF141C2E),
                        child: InkWell(
                          onTap: onOpenExternal,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: VirtuoMvpColors.cyan, size: 48),
                              SizedBox(height: 10),
                              Text(
                                'Video CV ready',
                                style: TextStyle(
                                  color: VirtuoMvpColors.text,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Tap to open in your video app',
                                style: TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      )
                : hasVideo && controller != null
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          final c = controller!;
                          final videoSize = c.value.size;
                          final vw = videoSize.width > 0 ? videoSize.width : 1280.0;
                          final vh = videoSize.height > 0 ? videoSize.height : 720.0;
                          final position = c.value.position;
                          final duration = c.value.duration;
                          final progress = duration.inMilliseconds > 0
                              ? position.inMilliseconds / duration.inMilliseconds
                              : 0.0;

                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              FittedBox(
                                fit: BoxFit.contain,
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: vw,
                                  height: vh,
                                  child: VideoPlayer(c),
                                ),
                              ),
                              Positioned.fill(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: onTogglePlay,
                                    child: IgnorePointer(
                                      ignoring: c.value.isPlaying,
                                      child: AnimatedOpacity(
                                        opacity: c.value.isPlaying ? 0.0 : 1.0,
                                        duration: const Duration(milliseconds: 200),
                                        child: Container(
                                          color: Colors.black38,
                                          alignment: Alignment.center,
                                          child: Icon(
                                            c.value.isPlaying ? Icons.pause_circle : Icons.play_circle_fill,
                                            color: Colors.white,
                                            size: 56,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  height: 32,
                                  color: Colors.black54,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        _formatTime(position),
                                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                                      ),
                                      const Text(' / ', style: TextStyle(color: Colors.white38, fontSize: 10)),
                                      Text(
                                        _formatTime(duration),
                                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(2),
                                          child: LinearProgressIndicator(
                                            value: progress.clamp(0.0, 1.0),
                                            minHeight: 4,
                                            backgroundColor: Colors.white24,
                                            color: VirtuoMvpColors.cyan,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [VirtuoMvpColors.blue, VirtuoMvpColors.purple],
                          ),
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(20),
                        child: const Text(
                          'Tap Generate video preview to render and watch your Video CV here before saving.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                        ),
                      ),
            ),
          ),
        );
      },
    );
  }
}
