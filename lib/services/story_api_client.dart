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
        'prompt_version': StoryPromptBuilder.version,
        'language': language,
        if (model.isNotEmpty) 'model': model,
        'prompt': StoryPromptBuilder.build(profile, language: language),
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

abstract final class StoryPromptBuilder {
  static const version = 'football-biography-v2';

  static String build(PlayerProfile profile, {String language = 'zh-CN'}) {
    final isEnglish = language.toLowerCase().startsWith('en');
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

    if (isEnglish) {
      return '''
You are writing a long-form football biography, not a database summary or a motivational fable.

FACTUAL RULES
- Treat the attached `player` object and the fact sheet below as the only canon.
- Never invent a named club, competition, trophy, transfer, injury, scoreline, teammate, coach, quote, or family fact.
- You may add restrained sensory details and connective moments only when they do not create a new factual claim.
- Preserve chronology. Ages, seasons, clubs, transfers, contract dates, appearances, goals and honours must not contradict one another.
- Never expose internal ratings, probability weights, character-model attributes, training-load values, or game mechanics.

WRITING BRIEF
- Write 900–1,300 words in natural magazine-feature prose, with no bullet list and no headings.
- Open on one concrete football moment, then move chronologically through academy entry, professional debut, club changes, the peak years, injuries or setbacks, international football, and retirement.
- Give transfers a believable dramatic function based only on the supplied chronology: opportunity, adaptation, competition for a place, recovery, or a final chapter.
- Translate statistics into human consequences. Use only a few decisive numbers rather than reciting every field.
- Vary sentence length and paragraph rhythm. Prefer precise football actions and places over generic phrases such as “against all odds”, “destiny”, or “legend was born”.
- Let success and failure coexist. End with a specific image that echoes the opening rather than a generic statement about dreams.
- Output the story only.

FACT SHEET
Player: ${profile.name}; ${profile.nationality}; ${profile.primaryPosition}; ${profile.preferredFoot}
Born: ${profile.birthDate}, ${profile.birthPlace}
Academy: ${profile.academy}, entered at ${profile.academyEntryAge}
Professional debut: age ${profile.debutAge}; retirement: age ${profile.retirementAge}
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
''';
    }

    return '''
你是一名长期跟队、熟悉训练场和更衣室语境的足球传记作者。你的任务不是复述数据库，也不是写励志模板，而是依据档案写一篇可信、可感的球员生涯特写。

事实边界
- 随请求附带的 `player` 对象和下方事实表是唯一事实来源。
- 不得虚构具名俱乐部、赛事、冠军、转会、伤病、比分、队友、教练、引语或家庭背景。
- 可以加入克制的感官细节和过场动作，但这些细节不能形成新的事实断言。
- 严格保持时间顺序；年龄、赛季、俱乐部、转会、合同日期、出场、进球和荣誉不得互相矛盾。
- 不得向读者透露能力值、人物模型、概率权重、训练负荷、伤病风险或任何游戏机制。

写作要求
- 使用自然连贯的中文足球杂志特写体，约 1800–2600 字，不使用项目符号和小标题。
- 从一个具体的足球瞬间开场，再按时间推进青训入营、职业首秀、俱乐部变化、巅峰阶段、伤病或低谷、国家队经历与退役。
- 转会只能依据现有时间线赋予戏剧功能，例如争取机会、适应新环境、位置竞争、伤愈回归或寻找最后一站。
- 把统计数字写成人的处境，只选择少量关键数字进入正文，不要逐字段报表。
- 句子长短和段落节奏要有变化，多写具体的足球动作、天气、草皮、看台和训练日常，少用“命运”“奇迹”“传奇就此诞生”“一路披荆斩棘”等套话。
- 成功与失败都要留下痕迹。结尾用一个与开场呼应的具体画面收束，不要泛泛谈梦想或人生。
- 只输出故事正文。

事实表
球员：${profile.name}；${profile.nationality}；${profile.primaryPosition}；${profile.preferredFoot}
出生：${profile.birthDate}，${profile.birthPlace}
青训：${profile.academy}，${profile.academyEntryAge} 岁进入
职业入口：${profile.debutAge} 岁首秀；${profile.retirementAge} 岁退役
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
