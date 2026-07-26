class StoryHttpResponse {
  const StoryHttpResponse(this.statusCode, this.body);

  final int statusCode;
  final String body;
}

abstract interface class StoryTransport {
  Future<StoryHttpResponse> post({
    required Uri uri,
    required Map<String, String> headers,
    required String body,
  });
}
