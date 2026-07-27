import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
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

  test('remote client posts the documented neutral contract', () async {
    final transport = _RecordingTransport(
      const StoryHttpResponse(200, '{"story":"一段远程故事"}'),
    );
    final profile = RandomCareerGenerator(random: Random(8)).generate();
    final client = StoryApiClient(
      endpoint: 'https://story.example.test/generate',
      token: 'test-token',
      transport: transport,
    );

    final story = await client.generate(profile);
    final requestBody = jsonDecode(transport.body!) as Map<String, dynamic>;

    expect(story, '一段远程故事');
    expect(transport.headers!['Authorization'], 'Bearer test-token');
    expect(requestBody['task'], 'generate_football_player_story');
    expect(requestBody['prompt_version'], StoryPromptBuilder.version);
    expect(requestBody['prompt'], contains('严格保持时间顺序'));
    expect(requestBody['prompt'], contains('不得向读者透露能力值'));
    expect(requestBody['prompt'], contains('只输出故事正文'));
    expect(requestBody['player'], profile.toJson());
  });

  test('remote client reports non-success status codes', () async {
    final transport = _RecordingTransport(
      const StoryHttpResponse(503, '{"error":"unavailable"}'),
    );
    final profile = RandomCareerGenerator(random: Random(12)).generate();
    final client = StoryApiClient(
      endpoint: 'https://story.example.test/generate',
      token: '',
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
  Map<String, String>? headers;
  String? body;

  @override
  Future<StoryHttpResponse> post({
    required Uri uri,
    required Map<String, String> headers,
    required String body,
  }) async {
    this.headers = headers;
    this.body = body;
    return response;
  }
}
