import 'dart:convert';

import '../domain/player_profile.dart';
import 'story_transport.dart';
import 'story_transport_stub.dart'
    if (dart.library.io) 'story_transport_io.dart'
    if (dart.library.html) 'story_transport_web.dart'
    as transport_factory;

class StoryApiClient {
  StoryApiClient({
    required this.endpoint,
    required this.token,
    this.model = '',
    this.language = 'zh-CN',
    StoryTransport? transport,
  }) : transport = transport ?? transport_factory.createStoryTransport();

  factory StoryApiClient.fromEnvironment() {
    return StoryApiClient(
      endpoint: const String.fromEnvironment('STORY_API_URL'),
      token: const String.fromEnvironment('STORY_API_TOKEN'),
      model: const String.fromEnvironment('STORY_API_MODEL'),
    );
  }

  final String endpoint;
  final String token;
  final String model;
  final String language;
  final StoryTransport transport;

  bool get usesDemo => endpoint.trim().isEmpty;

  Future<String> generate(PlayerProfile profile) async {
    if (usesDemo) {
      await Future<void>.delayed(const Duration(milliseconds: 650));
      return DemoStoryGenerator.generate(profile);
    }

    final uri = Uri.tryParse(endpoint);
    if (uri == null || !uri.hasScheme) {
      throw const FormatException('STORY_API_URL 不是有效的网址。');
    }
    final response = await transport.post(
      uri: uri,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'task': 'generate_football_player_story',
        'language': language,
        if (model.isNotEmpty) 'model': model,
        'player': profile.toJson(),
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StoryApiException('故事 API 返回 ${response.statusCode}，请检查服务端日志。');
    }

    final decoded = jsonDecode(response.body);
    final story = _extractStory(decoded);
    if (story == null || story.trim().isEmpty) {
      throw const StoryApiException('响应中缺少 story、text 或 content 字段。');
    }
    return story.trim();
  }

  String? _extractStory(Object? decoded) {
    if (decoded is String) return decoded;
    if (decoded is! Map<String, dynamic>) return null;
    for (final key in const ['story', 'text', 'content']) {
      final value = decoded[key];
      if (value is String) return value;
    }
    final data = decoded['data'];
    if (data is Map<String, dynamic>) {
      return _extractStory(data);
    }
    return null;
  }
}

class StoryApiException implements Exception {
  const StoryApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract final class DemoStoryGenerator {
  static String generate(PlayerProfile profile) {
    final firstClub = profile.career.isEmpty
        ? profile.academy
        : profile.career.first.club;
    final lastClub = profile.career.isEmpty ? '职业赛场' : profile.career.last.club;
    final signatureHonor = profile.stats.personalHonors.isEmpty
        ? '球迷长久的掌声'
        : profile.stats.personalHonors.last;
    final peakValue = profile.marketValueHistory.fold<double>(
      profile.marketValueMillions,
      (highest, point) =>
          point.valueMillions > highest ? point.valueMillions : highest,
    );

    return '''
${profile.name}的故事从${profile.birthPlace == '未记录' ? '${profile.nationality}的一块普通球场' : profile.birthPlace}开始。作为一名${profile.preferredFoot}、身高${profile.heightCm}厘米的${profile.primaryPosition}，${profile.name}在${profile.academy}学会了用“${profile.playStyle}”理解比赛。

${profile.debutAge}岁那年，${profile.name}代表$firstClub完成职业首秀。初始能力值${profile.initialRating}并没有让所有球探立刻相信这位年轻人，但持续的选择与训练最终把巅峰能力推到${profile.peakRating}。整个职业生涯里，${profile.name}出场${profile.stats.appearances}次、累计${profile.stats.minutesPlayed}分钟，贡献${profile.stats.goals}球和${profile.stats.assists}次助攻，还为${profile.nationalTeam}出战${profile.stats.nationalCaps}场。${peakValue > 0 ? '生涯模拟身价峰值达到€${peakValue.toStringAsFixed(1)}M。' : ''}

档案里记录了${profile.stats.transferCount}次转会和${profile.injuryHistory.length}段伤停，伤病总结写着“${profile.injuryRecord}”，奖杯柜里则留下${profile.stats.championships.length}座重要冠军。到了${profile.retirementAge}岁，${profile.name}在$lastClub完成最后一章。比分会被新的比赛覆盖，但$signatureHonor，以及那些由每一次选择串起的时刻，留在了这段独一无二的足球人生里。
''';
  }
}
