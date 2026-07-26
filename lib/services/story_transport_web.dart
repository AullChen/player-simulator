// ignore_for_file: deprecated_member_use

import 'dart:html' as html;

import 'story_transport.dart';

StoryTransport createStoryTransport() => const _WebStoryTransport();

class _WebStoryTransport implements StoryTransport {
  const _WebStoryTransport();

  @override
  Future<StoryHttpResponse> post({
    required Uri uri,
    required Map<String, String> headers,
    required String body,
  }) async {
    final response = await html.HttpRequest.request(
      uri.toString(),
      method: 'POST',
      requestHeaders: headers,
      sendData: body,
    );
    return StoryHttpResponse(response.status ?? 0, response.responseText ?? '');
  }
}
