import 'dart:async';
import 'dart:convert';

import '../domain/app_settings.dart';
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
    this.provider = StoryApiProvider.openAi,
    this.model = '',
    this.language = 'zh-CN',
    StoryTransport? transport,
  }) : transport = transport ?? transport_factory.createStoryTransport();

  factory StoryApiClient.fromEnvironment() {
    const providerName = String.fromEnvironment('STORY_API_PROVIDER');
    final provider = StoryApiProvider.values
        .where((value) => value.name == providerName)
        .firstOrNull;
    return StoryApiClient(
      provider: provider ?? StoryApiProvider.openAi,
      endpoint: const String.fromEnvironment('STORY_API_URL'),
      token: const String.fromEnvironment('STORY_API_TOKEN'),
      model: const String.fromEnvironment('STORY_API_MODEL'),
    );
  }

  final String endpoint;
  final String token;
  final StoryApiProvider provider;
  final String model;
  final String language;
  final StoryTransport transport;

  bool get usesDemo => token.trim().isEmpty;

  String get effectiveEndpoint {
    final custom = endpoint.trim();
    return custom.isEmpty ? provider.defaultEndpoint : custom;
  }

  String get effectiveModel {
    final custom = model.trim();
    return custom.isEmpty ? provider.defaultModel : custom;
  }

  String get providerName => switch (provider) {
    StoryApiProvider.openAi => 'OpenAI',
    StoryApiProvider.anthropic => 'Anthropic',
    StoryApiProvider.deepSeek => 'DeepSeek',
  };

  Future<String> generate(PlayerProfile profile) async {
    if (usesDemo) {
      await Future<void>.delayed(const Duration(milliseconds: 650));
      return DemoStoryGenerator.generate(profile);
    }

    final request = _buildRequest(
      StoryPromptBuilder.build(profile, language: language),
      connectionTest: false,
    );
    final response = await _send(request);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _responseException(response);
    }

    final story = _extractText(_decodeResponse(response.body));
    if (story == null || story.trim().isEmpty) {
      throw StoryApiException(
        _localized(
          'API 响应成功，但没有找到可用的故事正文。',
          'The API succeeded but returned no usable story text.',
        ),
      );
    }
    return story.trim();
  }

  Future<StoryConnectionResult> testConnection() async {
    if (token.trim().isEmpty) {
      return StoryConnectionResult.failure(
        _localized('请输入 API 密钥后再测试。', 'Enter an API key before testing.'),
      );
    }
    if (effectiveModel.isEmpty) {
      return StoryConnectionResult.failure(
        _localized(
          '请输入当前账户可用的模型名称。',
          'Enter a model available to this account.',
        ),
      );
    }

    final stopwatch = Stopwatch()..start();
    try {
      final request = _buildRequest(
        'Reply with exactly: OK',
        connectionTest: true,
      );
      final response = await _send(
        request,
      ).timeout(const Duration(seconds: 25));
      stopwatch.stop();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return StoryConnectionResult.failure(
          _responseException(response).message,
          statusCode: response.statusCode,
          elapsed: stopwatch.elapsed,
        );
      }
      final text = _extractText(_decodeResponse(response.body));
      if (text == null || text.trim().isEmpty) {
        return StoryConnectionResult.failure(
          _localized(
            '服务已响应，但响应格式与所选供应商不匹配。',
            'The service responded, but its response does not match the selected provider format.',
          ),
          statusCode: response.statusCode,
          elapsed: stopwatch.elapsed,
        );
      }
      return StoryConnectionResult.success(
        _localized(
          '$providerName 连接成功，模型 ${effectiveModel.trim()} 可用。',
          '$providerName connected; model ${effectiveModel.trim()} is available.',
        ),
        elapsed: stopwatch.elapsed,
      );
    } on TimeoutException {
      stopwatch.stop();
      return StoryConnectionResult.failure(
        _localized(
          '连接测试超过 25 秒，请检查网络、地址或服务状态。',
          'The connection test exceeded 25 seconds. Check the network, endpoint, or service status.',
        ),
        elapsed: stopwatch.elapsed,
      );
    } on Object catch (error) {
      stopwatch.stop();
      return StoryConnectionResult.failure(
        _localized('连接失败：$error', 'Connection failed: $error'),
        elapsed: stopwatch.elapsed,
      );
    }
  }

  _StoryApiRequest _buildRequest(
    String prompt, {
    required bool connectionTest,
  }) {
    final uri = Uri.tryParse(effectiveEndpoint);
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      throw StoryApiException(
        _localized(
          'API 地址不是有效的 HTTP 或 HTTPS 地址。',
          'The API endpoint is not a valid HTTP or HTTPS URL.',
        ),
      );
    }
    if (effectiveModel.isEmpty) {
      throw StoryApiException(
        _localized(
          '当前供应商需要填写模型名称。',
          'A model name is required for this provider.',
        ),
      );
    }

    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    };
    late final Map<String, Object> body;
    switch (provider) {
      case StoryApiProvider.openAi:
        if (token.trim().isNotEmpty) {
          headers['Authorization'] = 'Bearer ${token.trim()}';
        }
        body = _openAiBody(prompt, connectionTest: connectionTest);
      case StoryApiProvider.anthropic:
        if (token.trim().isNotEmpty) {
          headers['x-api-key'] = token.trim();
        }
        headers['anthropic-version'] = '2023-06-01';
        body = {
          'model': effectiveModel,
          'max_tokens': connectionTest ? 16 : 16000,
          'system': connectionTest
              ? _connectionSystemInstruction
              : _systemInstruction,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'stream': false,
        };
      case StoryApiProvider.deepSeek:
        if (token.trim().isNotEmpty) {
          headers['Authorization'] = 'Bearer ${token.trim()}';
        }
        body = {
          ..._openAiBody(prompt, connectionTest: connectionTest),
          'thinking': {'type': connectionTest ? 'disabled' : 'enabled'},
          if (!connectionTest) 'reasoning_effort': 'high',
        };
    }
    return _StoryApiRequest(uri: uri, headers: headers, body: body);
  }

  Map<String, Object> _openAiBody(
    String prompt, {
    required bool connectionTest,
  }) {
    return {
      'model': effectiveModel,
      'messages': [
        {
          'role': 'system',
          'content': connectionTest
              ? _connectionSystemInstruction
              : _systemInstruction,
        },
        {'role': 'user', 'content': prompt},
      ],
      'stream': false,
    };
  }

  String get _systemInstruction => language.toLowerCase().startsWith('en')
      ? 'Write a realistic football biography using only supplied facts. Return only the requested text.'
      : '依据提供的事实撰写真实可信的足球生涯故事，只返回请求的正文。';

  String get _connectionSystemInstruction =>
      'This is a connection test. Follow the user instruction exactly.';

  Future<StoryHttpResponse> _send(_StoryApiRequest request) {
    return transport.post(
      uri: request.uri,
      headers: request.headers,
      body: jsonEncode(request.body),
    );
  }

  Object? _decodeResponse(String body) {
    try {
      return jsonDecode(body);
    } on FormatException {
      throw StoryApiException(
        _localized('API 返回的不是有效 JSON。', 'The API did not return valid JSON.'),
      );
    }
  }

  String? _extractText(Object? decoded) {
    if (decoded is String) return decoded;
    if (decoded is! Map<String, dynamic>) return null;

    if (provider == StoryApiProvider.anthropic) {
      final content = decoded['content'];
      if (content is List) {
        final text = content
            .whereType<Map>()
            .where((block) => block['type'] == 'text')
            .map((block) => block['text'])
            .whereType<String>()
            .join('\n');
        if (text.isNotEmpty) return text;
      }
    } else {
      final choices = decoded['choices'];
      if (choices is List && choices.isNotEmpty) {
        final choice = choices.first;
        if (choice is Map) {
          final message = choice['message'];
          if (message is Map) {
            final content = message['content'];
            if (content is String) return content;
            if (content is List) {
              final text = content
                  .whereType<Map>()
                  .map((part) => part['text'])
                  .whereType<String>()
                  .join('\n');
              if (text.isNotEmpty) return text;
            }
          }
        }
      }
    }

    return _extractLegacyText(decoded);
  }

  String? _extractLegacyText(Object? decoded) {
    if (decoded is String) return decoded;
    if (decoded is! Map) return null;
    for (final key in const ['story', 'text', 'content']) {
      final value = decoded[key];
      if (value is String) return value;
    }
    final data = decoded['data'];
    return _extractLegacyText(data);
  }

  StoryApiException _responseException(StoryHttpResponse response) {
    final detail = _extractErrorMessage(response.body);
    final advice = switch (response.statusCode) {
      400 => _localized(
        '请求格式或模型参数无效。',
        'The request or model parameters are invalid.',
      ),
      401 => _localized('API 密钥无效或已失效。', 'The API key is invalid or expired.'),
      403 => _localized(
        '密钥没有访问该模型的权限。',
        'The key does not have access to this model.',
      ),
      404 => _localized(
        'API 地址或模型名称不存在。',
        'The API endpoint or model name was not found.',
      ),
      429 => _localized(
        '请求受到速率或余额限制。',
        'The request was rate-limited or quota-limited.',
      ),
      >= 500 => _localized(
        '供应商服务暂时不可用。',
        'The provider service is temporarily unavailable.',
      ),
      _ => _localized('请检查供应商设置。', 'Check the provider settings.'),
    };
    return StoryApiException(
      '$providerName HTTP ${response.statusCode}：$advice'
      '${detail == null ? '' : ' $detail'}',
    );
  }

  String? _extractErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map) return null;
      final error = decoded['error'];
      if (error is Map && error['message'] is String) {
        return '${error['message']}';
      }
      if (error is String) return error;
      if (decoded['message'] is String) return '${decoded['message']}';
    } on FormatException {
      return null;
    }
    return null;
  }

  String _localized(String zh, String en) =>
      language.toLowerCase().startsWith('en') ? en : zh;
}

class StoryConnectionResult {
  const StoryConnectionResult._({
    required this.isSuccess,
    required this.message,
    this.statusCode,
    this.elapsed = Duration.zero,
  });

  factory StoryConnectionResult.success(
    String message, {
    required Duration elapsed,
  }) {
    return StoryConnectionResult._(
      isSuccess: true,
      message: message,
      elapsed: elapsed,
    );
  }

  factory StoryConnectionResult.failure(
    String message, {
    int? statusCode,
    Duration elapsed = Duration.zero,
  }) {
    return StoryConnectionResult._(
      isSuccess: false,
      message: message,
      statusCode: statusCode,
      elapsed: elapsed,
    );
  }

  final bool isSuccess;
  final String message;
  final int? statusCode;
  final Duration elapsed;
}

class _StoryApiRequest {
  const _StoryApiRequest({
    required this.uri,
    required this.headers,
    required this.body,
  });

  final Uri uri;
  final Map<String, String> headers;
  final Map<String, Object> body;
}

abstract final class StoryPromptBuilder {
  static const version = 'football-biography-v3';

  static String build(PlayerProfile profile, {String language = 'zh-CN'}) {
    final isEnglish = language.toLowerCase().startsWith('en');
    final canonicalPlayerJson = const JsonEncoder.withIndent(
      '  ',
    ).convert(profile.toJson());
    final timeline = profile.career.isEmpty
        ? (isEnglish ? 'No club timeline supplied.' : '未提供俱乐部时间线。')
        : profile.career
              .map(
                (chapter) => isEnglish
                    ? 'Age ${chapter.age}: ${chapter.club} — ${chapter.event}'
                    : '${chapter.age} 岁：${chapter.club}——${chapter.event}',
              )
              .join('\n');
    final transfers = profile.transferHistory.isEmpty
        ? (isEnglish ? 'No transfers.' : '无转会。')
        : profile.transferHistory
              .map(
                (item) => isEnglish
                    ? '${item.season}, age ${item.age}: ${item.fromClub} → '
                          '${item.toClub}, ${item.type}, €${item.feeMillions}m'
                    : '${item.season}，${item.age} 岁：${item.fromClub} → '
                          '${item.toClub}，${item.type}，€${item.feeMillions}M',
              )
              .join('\n');
    final injuries = profile.injuryHistory.isEmpty
        ? (isEnglish ? 'No recorded injury spell.' : '无结构化伤病记录。')
        : profile.injuryHistory
              .map(
                (item) => isEnglish
                    ? '${item.season}: ${item.type}, ${item.daysAbsent} days out'
                    : '${item.season}：${item.type}，缺阵 ${item.daysAbsent} 天',
              )
              .join('\n');
    final annualSnapshots = profile.careerYearSnapshots.isEmpty
        ? (isEnglish
              ? 'No annual simulation snapshots supplied.'
              : '未提供逐年模拟快照。')
        : profile.careerYearSnapshots
              .map(
                (item) => isEnglish
                    ? '${item.season}, age ${item.age}, ${item.club}, '
                          '${item.squadRole}: overall ${item.overallRating}, '
                          'technical ${item.technical}, physical ${item.physical}, '
                          'mental ${item.mental}, fitness ${item.fitness}, '
                          'morale ${item.morale}, reputation ${item.reputation}; '
                          '${item.keyEvent}'
                    : '${item.season}，${item.age} 岁，${item.club}，'
                          '${item.squadRole}：综合 ${item.overallRating}，'
                          '技术 ${item.technical}，身体 ${item.physical}，'
                          '心智 ${item.mental}，竞技状态 ${item.fitness}，'
                          '士气 ${item.morale}，声望 ${item.reputation}；'
                          '${item.keyEvent}',
              )
              .join('\n');

    if (isEnglish) {
      return '''
You are writing a long-form football biography, not a database summary or a motivational fable.
Prompt contract: $version.

FACTUAL RULES
- Treat the attached `player` object and the fact sheet below as the only canon.
- Never invent a named club, competition, trophy, transfer, injury, scoreline, teammate, coach, quote, or family fact.
- You may add restrained sensory details and connective moments only when they do not create a new factual claim.
- Preserve chronology. Ages, seasons, clubs, transfers, contract dates, appearances, goals and honours must not contradict one another.
- Never expose internal ratings, probability weights, character-model attributes, training-load values, or game mechanics.
- Annual snapshots are private writing evidence. Convert their year-to-year changes into form, role, confidence, recovery and training consequences; never print their hidden numerical ratings.

WRITING BRIEF
- Write 900–1,300 words in natural magazine-feature prose, with no bullet list and no headings.
- Open on one concrete football moment, then move chronologically through academy entry, professional debut, club changes, the peak years, injuries or setbacks, international football, and retirement.
- Give transfers a believable dramatic function based only on the supplied chronology: opportunity, adaptation, competition for a place, recovery, or a final chapter.
- Translate statistics into human consequences. Use only a few decisive numbers rather than reciting every field.
- Give important seasons their own texture. Use annual snapshots to show gradual improvement, a plateau, lost sharpness, recovery, changing squad status or reputation without turning the story into a season-by-season ledger.
- Vary sentence length and paragraph rhythm. Prefer precise football actions and places over generic phrases such as “against all odds”, “destiny”, or “legend was born”.
- Let success and failure coexist. End with a specific image that echoes the opening rather than a generic statement about dreams.
- Output the story only.

FACT SHEET
Player: ${profile.name}; ${profile.nationality}; ${profile.primaryPosition}; ${profile.preferredFoot}
Born: ${profile.birthDate}, ${profile.birthPlace}
Academy: ${profile.academy}, entered at ${profile.academyEntryAge}
Professional debut: age ${profile.debutAge}; retirement: age ${profile.retirementAge}
Retirement reason: ${profile.retirementReason}; ${profile.retirementContext}
Career totals: ${profile.stats.appearances} appearances, ${profile.stats.goals} goals, ${profile.stats.assists} assists
International: ${profile.nationalTeam}, ${profile.stats.nationalCaps} caps, ${profile.stats.nationalGoals} goals
Honours: ${profile.stats.championships.join('; ')}
Individual recognition: ${profile.stats.personalHonors.join('; ')}

CLUB TIMELINE
$timeline

TRANSFERS
$transfers

INJURIES
$injuries

ANNUAL SIMULATION SNAPSHOTS — PRIVATE WRITING EVIDENCE
$annualSnapshots

COMPLETE CANONICAL PLAYER JSON
$canonicalPlayerJson
''';
    }

    return '''
你是一名长期跟队、熟悉训练场和更衣室语境的足球传记作者。你的任务不是复述数据库，也不是写励志模板，而是依据档案写一篇可信、可感的球员生涯特写。
提示词协议：$version。

事实边界
- 随请求附带的 `player` 对象和下方事实表是唯一事实来源。
- 不得虚构具名俱乐部、赛事、冠军、转会、伤病、比分、队友、教练、引语或家庭背景。
- 可以加入克制的感官细节和过场动作，但这些细节不能形成新的事实断言。
- 严格保持时间顺序；年龄、赛季、俱乐部、转会、合同日期、出场、进球和荣誉不得互相矛盾。
- 不得向读者透露能力值、人物模型、概率权重、训练负荷、伤病风险或任何游戏机制。
- 逐年快照是仅供写作使用的内部证据。把年度数值变化转译为状态、角色、信心、恢复和训练后果，不得在正文直接报出隐藏评分。

写作要求
- 使用自然连贯的中文足球杂志特写体，约 1800–2600 字，不使用项目符号和小标题。
- 从一个具体的足球瞬间开场，再按时间推进青训入营、职业首秀、俱乐部变化、巅峰阶段、伤病或低谷、国家队经历与退役。
- 转会只能依据现有时间线赋予戏剧功能，例如争取机会、适应新环境、位置竞争、伤愈回归或寻找最后一站。
- 把统计数字写成人的处境，只选择少量关键数字进入正文，不要逐字段报表。
- 让重要赛季拥有各自的质感；依据逐年快照写出进步、平台期、锐度下降、伤愈恢复、队内角色或声望变化，但不要机械地逐赛季点名。
- 句子长短和段落节奏要有变化，多写具体的足球动作、天气、草皮、看台和训练日常，少用“命运”“奇迹”“传奇就此诞生”“一路披荆斩棘”等套话。
- 成功与失败都要留下痕迹。结尾用一个与开场呼应的具体画面收束，不要泛泛谈梦想或人生。
- 只输出故事正文。

事实表
球员：${profile.name}；${profile.nationality}；${profile.primaryPosition}；${profile.preferredFoot}
出生：${profile.birthDate}，${profile.birthPlace}
青训：${profile.academy}，${profile.academyEntryAge} 岁进入
职业入口：${profile.debutAge} 岁首秀；${profile.retirementAge} 岁退役
退役原因：${profile.retirementReason}；${profile.retirementContext}
俱乐部总计：${profile.stats.appearances} 场、${profile.stats.goals} 球、${profile.stats.assists} 次助攻
国家队：${profile.nationalTeam}，${profile.stats.nationalCaps} 场、${profile.stats.nationalGoals} 球
冠军：${profile.stats.championships.join('；')}
个人荣誉：${profile.stats.personalHonors.join('；')}

俱乐部时间线
$timeline

转会
$transfers

伤病
$injuries

逐年模拟快照（仅供写作推理，不得直接展示隐藏评分）
$annualSnapshots

完整球员档案 JSON（同样属于唯一事实来源）
$canonicalPlayerJson
''';
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

${profile.debutAge}岁那年，${profile.name}代表$firstClub完成职业首秀。那时首先要争取的不是掌声，而是下一场比赛还能不能留在名单里。训练后的加练、客场长途和位置竞争一点点改变了教练对这名年轻人的判断。整个职业生涯里，${profile.name}出场${profile.stats.appearances}次、累计${profile.stats.minutesPlayed}分钟，贡献${profile.stats.goals}球和${profile.stats.assists}次助攻，还为${profile.nationalTeam}出战${profile.stats.nationalCaps}场。${peakValue > 0 ? '最受市场关注的阶段，模拟身价峰值达到€${peakValue.toStringAsFixed(1)}M。' : ''}

档案里记录了${profile.stats.transferCount}次转会和${profile.injuryHistory.length}段伤停，伤病总结写着“${profile.injuryRecord}”，奖杯柜里则留下${profile.stats.championships.length}座重要冠军。到了${profile.retirementAge}岁，${profile.name}在$lastClub完成最后一章。比分会被新的比赛覆盖，但$signatureHonor，以及那些由每一次选择串起的时刻，留在了这段独一无二的足球人生里。
''';
  }
}
