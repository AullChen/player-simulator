import 'story_transport.dart';

StoryTransport createStoryTransport() => const _UnsupportedStoryTransport();

class _UnsupportedStoryTransport implements StoryTransport {
  const _UnsupportedStoryTransport();

  @override
  Future<StoryHttpResponse> post({
    required Uri uri,
    required Map<String, String> headers,
    required String body,
  }) {
    throw UnsupportedError('当前平台尚未启用远程故事 API。');
  }
}
