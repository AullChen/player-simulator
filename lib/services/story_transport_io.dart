import 'dart:convert';
import 'dart:io';

import 'story_transport.dart';

StoryTransport createStoryTransport() => const _IoStoryTransport();

class _IoStoryTransport implements StoryTransport {
  const _IoStoryTransport();

  @override
  Future<StoryHttpResponse> post({
    required Uri uri,
    required Map<String, String> headers,
    required String body,
  }) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      final request = await client.postUrl(uri);
      headers.forEach(request.headers.set);
      request.write(body);
      final response = await request.close().timeout(
        const Duration(seconds: 60),
      );
      final responseBody = await utf8.decoder.bind(response).join();
      return StoryHttpResponse(response.statusCode, responseBody);
    } finally {
      client.close(force: true);
    }
  }
}
