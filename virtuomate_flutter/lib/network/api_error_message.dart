/// Parses user-facing text from API / backend error strings.
String friendlyApiError(Object error) {
  var msg = error.toString().replaceFirst('Exception: ', '');
  if (msg.contains('Video CV limit reached') || msg.contains('VIDEO_CV_LIMIT')) {
    return 'Free plan allows 2 Video CVs. Upgrade to Premium or use a new account to test again.';
  }
  if (msg.contains('AndroidVideoPlayerApi') || msg.contains('createForTextureView')) {
    return 'In-app player needs a full rebuild. Video may still be saved — tap Open video.';
  }
  if (msg.contains('Cannot reach') || msg.contains('Request timed out')) {
    return msg;
  }
  if (msg.startsWith('API request failed')) {
    final jsonStart = msg.indexOf('{');
    if (jsonStart >= 0) {
      final tail = msg.substring(jsonStart);
      if (tail.contains('billing limit') || tail.contains('Billing hard limit')) {
        return 'OpenAI billing limit reached. Add payment at platform.openai.com/account/billing';
      }
      final errMatch = RegExp(r'"error"\s*:\s*"([^"]+)"').firstMatch(tail);
      if (errMatch != null) {
        final inner = errMatch.group(1)!;
        if (inner.contains('billing limit') || inner.contains('OPENAI')) {
          return inner.length > 120 ? '${inner.substring(0, 120)}…' : inner;
        }
        return inner;
      }
    }
  }
  if (msg.length > 280) return '${msg.substring(0, 280)}…';
  return msg;
}
