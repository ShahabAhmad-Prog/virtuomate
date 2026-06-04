import 'package:virtuomate_flutter/core/models.dart';
import 'package:virtuomate_flutter/network/api_client.dart';

class VideoCvRenderJob {
  const VideoCvRenderJob({
    required this.jobId,
    required this.status,
    this.downloadUrl,
    this.videoDownloadUrl,
    this.htmlDownloadUrl,
    this.format = 'mp4',
    this.message,
  });

  final String jobId;
  final String status;
  final String? downloadUrl;
  final String? videoDownloadUrl;
  final String? htmlDownloadUrl;
  final String format;
  final String? message;

  bool get isComplete => status == 'completed';
}

class VideoCvRenderService {
  VideoCvRenderService(this._api);

  final ApiClient _api;

  Future<VideoCvRenderJob> startRender({
    required String script,
    required VideoCvDraft draft,
    String format = 'mp4',
    String avatarImageUrl = '',
  }) async {
    final res = await _api.postJson(
      '/video-cv/render-job',
      {
        'script': script,
        'format': format,
        'draft': {
          'fullName': draft.fullName,
          'headline': draft.headline,
          'summary': draft.summary,
          'email': draft.email,
          'phone': draft.phone,
          'skills': draft.skills,
          'experience': draft.experience,
          'education': draft.education,
          'avatarImageUrl': avatarImageUrl,
        },
      },
      timeout: const Duration(minutes: 5),
    );
    final status = (res['status'] as String?) ?? 'processing';
    final renderError = res['renderError'] as String? ?? res['detail'] as String?;
    if (status == 'failed' || (renderError != null && renderError.isNotEmpty && res['videoDownloadUrl'] == null)) {
      throw Exception(renderError ?? res['message'] ?? 'Video render failed on server.');
    }
    return VideoCvRenderJob(
      jobId: (res['jobId'] as String?) ?? '',
      status: (res['status'] as String?) ?? 'processing',
      downloadUrl: res['downloadUrl'] as String?,
      videoDownloadUrl: res['videoDownloadUrl'] as String?,
      htmlDownloadUrl: res['htmlDownloadUrl'] as String?,
      format: (res['format'] as String?) ?? format,
      message: res['message'] as String?,
    );
  }

  Future<VideoCvRenderJob> pollJob(String jobId) async {
    final res = await _api.getJson('/video-cv/render-job/$jobId');
    return VideoCvRenderJob(
      jobId: (res['jobId'] as String?) ?? jobId,
      status: (res['status'] as String?) ?? 'processing',
      downloadUrl: res['downloadUrl'] as String?,
      videoDownloadUrl: res['videoDownloadUrl'] as String?,
      htmlDownloadUrl: res['htmlDownloadUrl'] as String?,
      format: (res['format'] as String?) ?? 'mp4',
      message: res['message'] as String?,
    );
  }
}
