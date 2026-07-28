import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:player_simulator/domain/app_settings.dart';
import 'package:player_simulator/services/random_career_generator.dart';
import 'package:player_simulator/services/story_api_client.dart';
import 'package:player_simulator/services/story_transport.dart';

void main() {
  test('demo generator includes the supplied player data', () async {
    final profile = RandomCareerGenerator(random: Random(4)).generate();
    final client = StoryApiClient(endpoint: '', token: '');

    final story = await client.generate(profile);

    expect(story, contains(profile.name));
    expect(story, contains(profile.nationality));
    expect(story, isNot(contains('初始能力值')));
  });

  test('a provider default model without an API key stays in demo mode', () {
    final client = StoryApiClient(
      provider: StoryApiProvider.deepSeek,
      endpoint: '',
      token: '',
      model: 'deepseek-v4-pro',
    );

    expect(client.usesDemo, isTrue);
  });

  test(
    'OpenAI client posts Chat Completions format and extracts text',
    () async {
      final transport = _RecordingTransport(
        const StoryHttpResponse(
          200,
          '{"choices":[{"message":{"role":"assistant","content":"一段远程故事"}}]}',
        ),
      );
      final profile = RandomCareerGenerator(random: Random(8)).generate();
      final client = StoryApiClient(
        endpoint: 'https://story.example.test/generate',
        token: 'test-token',
        model: 'test-openai-model',
        transport: transport,
      );

      final story = await client.generate(profile);
      final requestBody = jsonDecode(transport.body!) as Map<String, dynamic>;
      final messages = requestBody['messages'] as List<dynamic>;
      final userMessage = messages.last as Map<String, dynamic>;

      expect(story, '一段远程故事');
      expect(transport.headers!['Authorization'], 'Bearer test-token');
      expect(requestBody['model'], 'test-openai-model');
      expect(requestBody['stream'], isFalse);
      expect(messages.first, containsPair('role', 'system'));
      expect(userMessage['content'], contains('严格保持时间顺序'));
      expect(userMessage['content'], contains('不得向读者透露能力值'));
      expect(userMessage['content'], contains('只输出故事正文'));
      expect(userMessage['content'], contains(profile.name));
      expect(userMessage['content'], contains('"personal_information"'));
    },
  );

  test('Anthropic client uses Messages headers and content blocks', () async {
    final transport = _RecordingTransport(
      const StoryHttpResponse(
        200,
        '{"content":[{"type":"text","text":"Anthropic 故事"}]}',
      ),
    );
    final profile = RandomCareerGenerator(random: Random(9)).generate();
    final client = StoryApiClient(
      provider: StoryApiProvider.anthropic,
      endpoint: '',
      token: 'anthropic-key',
      model: 'claude-test-model',
      transport: transport,
    );

    final story = await client.generate(profile);
    final requestBody = jsonDecode(transport.body!) as Map<String, dynamic>;

    expect(story, 'Anthropic 故事');
    expect(
      transport.uri.toString(),
      StoryApiProvider.anthropic.defaultEndpoint,
    );
    expect(transport.headers!['x-api-key'], 'anthropic-key');
    expect(transport.headers!['anthropic-version'], '2023-06-01');
    expect(transport.headers, isNot(contains('Authorization')));
    expect(requestBody['model'], 'claude-test-model');
    expect(requestBody['max_tokens'], 16000);
    expect(requestBody['messages'], isA<List<dynamic>>());
  });

  test('DeepSeek client enables thinking for story generation', () async {
    final transport = _RecordingTransport(
      const StoryHttpResponse(
        200,
        '{"choices":[{"message":{"content":"DeepSeek 故事"}}]}',
      ),
    );
    final profile = RandomCareerGenerator(random: Random(10)).generate();
    final client = StoryApiClient(
      provider: StoryApiProvider.deepSeek,
      endpoint: '',
      token: 'deepseek-key',
      model: '',
      transport: transport,
    );

    final story = await client.generate(profile);
    final requestBody = jsonDecode(transport.body!) as Map<String, dynamic>;

    expect(story, 'DeepSeek 故事');
    expect(transport.uri.toString(), StoryApiProvider.deepSeek.defaultEndpoint);
    expect(transport.headers!['Authorization'], 'Bearer deepseek-key');
    expect(requestBody['model'], 'deepseek-v4-pro');
    expect(requestBody['thinking'], {'type': 'enabled'});
    expect(requestBody['reasoning_effort'], 'high');
    expect(requestBody['stream'], isFalse);
  });

  test(
    'connection test sends a short provider request and reports success',
    () async {
      final transport = _RecordingTransport(
        const StoryHttpResponse(
          200,
          '{"choices":[{"message":{"content":"OK"}}]}',
        ),
      );
      final client = StoryApiClient(
        provider: StoryApiProvider.deepSeek,
        endpoint: '',
        token: 'deepseek-key',
        model: '',
        transport: transport,
      );

      final result = await client.testConnection();
      final requestBody = jsonDecode(transport.body!) as Map<String, dynamic>;
      final messages = requestBody['messages'] as List<dynamic>;

      expect(result.isSuccess, isTrue);
      expect(result.message, contains('DeepSeek 连接成功'));
      expect(requestBody['thinking'], {'type': 'disabled'});
      expect(requestBody, isNot(contains('reasoning_effort')));
      expect('$messages', contains('Reply with exactly: OK'));
    },
  );

  test('connection test explains authentication failures', () async {
    final transport = _RecordingTransport(
      const StoryHttpResponse(401, '{"error":{"message":"invalid api key"}}'),
    );
    final client = StoryApiClient(
      endpoint: '',
      token: 'bad-key',
      model: 'test-model',
      transport: transport,
    );

    final result = await client.testConnection();

    expect(result.isSuccess, isFalse);
    expect(result.statusCode, 401);
    expect(result.message, contains('API 密钥无效'));
    expect(result.message, contains('invalid api key'));
  });

  test('remote client reports non-success status codes', () async {
    final transport = _RecordingTransport(
      const StoryHttpResponse(503, '{"error":"unavailable"}'),
    );
    final profile = RandomCareerGenerator(random: Random(12)).generate();
    final client = StoryApiClient(
      endpoint: 'https://story.example.test/generate',
      token: 'test-token',
      model: 'test-model',
      transport: transport,
    );

    await expectLater(
      client.generate(profile),
      throwsA(isA<StoryApiException>()),
    );
  });
}

class _RecordingTransport implements StoryTransport {
  _RecordingTransport(this.response);

  final StoryHttpResponse response;
  Uri? uri;
  Map<String, String>? headers;
  String? body;

  @override
  Future<StoryHttpResponse> post({
    required Uri uri,
    required Map<String, String> headers,
    required String body,
  }) async {
    this.uri = uri;
    this.headers = headers;
    this.body = body;
    return response;
  }
}
