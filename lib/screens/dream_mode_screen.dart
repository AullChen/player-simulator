import 'dart:math';

import 'package:flutter/material.dart';

import '../data/football_catalog.dart';
import '../domain/player_profile.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import 'result_screen.dart';

class DreamModeScreen extends StatefulWidget {
  const DreamModeScreen({super.key});

  @override
  State<DreamModeScreen> createState() => _DreamModeScreenState();
}

class _DreamModeScreenState extends State<DreamModeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{
    'name': TextEditingController(text: '传奇十号'),
    'birthDate': TextEditingController(text: '18/06/2006'),
    'birthPlace': TextEditingController(text: '上海'),
    'nationality': TextEditingController(text: '中国'),
    'citizenships': TextEditingController(text: '中国'),
    'height': TextEditingController(text: '181'),
    'weight': TextEditingController(text: '74'),
    'shirtNumber': TextEditingController(text: '10'),
    'academy': TextEditingController(text: '梦想足球学院'),
    'currentClub': TextEditingController(text: '世界全明星'),
    'league': TextEditingController(text: '欧洲顶级联赛'),
    'joined': TextEditingController(text: '01/07/2034'),
    'contractUntil': TextEditingController(text: '30/06/2038'),
    'agent': TextEditingController(text: 'Legend Sports'),
    'marketValue': TextEditingController(text: '80.0'),
    'nationalTeam': TextEditingController(text: '中国国家队'),
    'nationalDebut': TextEditingController(text: '05/09/2025'),
    'debut': TextEditingController(text: '17'),
    'retirement': TextEditingController(text: '38'),
    'initial': TextEditingController(text: '68'),
    'peak': TextEditingController(text: '94'),
    'final': TextEditingController(text: '78'),
    'style': TextEditingController(text: '自由组织核心'),
    'injury': TextEditingController(text: '生涯健康，只有短期伤停'),
    'clubs': TextEditingController(text: '家乡俱乐部, 欧洲新星队, 世界全明星'),
    'appearances': TextEditingController(text: '628'),
    'starts': TextEditingController(text: '570'),
    'substituteAppearances': TextEditingController(text: '58'),
    'minutes': TextEditingController(text: '51240'),
    'goals': TextEditingController(text: '214'),
    'assists': TextEditingController(text: '286'),
    'yellowCards': TextEditingController(text: '42'),
    'secondYellowCards': TextEditingController(text: '1'),
    'redCards': TextEditingController(text: '2'),
    'cleanSheets': TextEditingController(text: '0'),
    'penalties': TextEditingController(text: '28'),
    'caps': TextEditingController(text: '126'),
    'nationalGoals': TextEditingController(text: '48'),
    'transferHistory': TextEditingController(
      text:
          '2026/27|20|家乡俱乐部|欧洲新星队|永久转会|28.5\n'
          '2034/35|28|欧洲新星队|世界全明星|永久转会|160.0',
    ),
    'injuryHistory': TextEditingController(text: '2030/31|腿筋伤势|24|4'),
    'marketValueHistory': TextEditingController(
      text: '17|5.0\n20|32.0\n24|95.0\n28|160.0\n32|110.0\n38|0.0',
    ),
    'competitionStats': TextEditingController(
      text:
          '国内联赛|430|132|198|35200\n'
          '国内杯赛|82|31|35|6120\n'
          '洲际俱乐部赛事|116|51|53|9920',
    ),
    'championships': TextEditingController(text: '联赛冠军 ×6, 洲际冠军 ×2, 世界冠军 ×1'),
    'honors': TextEditingController(text: '世界年度最佳球员, 联赛最佳阵容 ×8'),
  };
  String _position = '前腰';
  String _secondaryPosition = '中前卫';
  String _preferredFoot = '双足';

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? '请填写这一项' : null;
  }

  String? _integer(String? value) {
    if (value == null || int.tryParse(value) == null) return '请输入整数';
    return null;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final debut = int.parse(_controllers['debut']!.text);
    final retirement = int.parse(_controllers['retirement']!.text);
    final initial = int.parse(_controllers['initial']!.text);
    final peak = int.parse(_controllers['peak']!.text);
    final clubs = _csv('clubs');
    if (retirement <= debut || peak < initial) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('退役年龄需晚于首秀年龄，巅峰能力不能低于初始能力。')),
      );
      return;
    }

    late final List<TransferRecord> transfers;
    late final List<InjurySpell> injuries;
    late final List<MarketValuePoint> marketValues;
    late final List<CompetitionStats> competitionStats;
    try {
      transfers = _parseTransfers();
      injuries = _parseInjuries();
      marketValues = _parseMarketValues();
      competitionStats = _parseCompetitionStats();
    } on FormatException catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
      return;
    }

    final chapters = List.generate(clubs.length, (index) {
      final progress = clubs.length == 1 ? 0.0 : index / (clubs.length - 1);
      return CareerChapter(
        age: debut + ((retirement - debut) * progress).round(),
        club: clubs[index],
        event: index == 0
            ? '完成职业首秀'
            : index == clubs.length - 1
            ? '完成职业生涯最后一站'
            : '完成重要转会',
        rating: min(peak, initial + ((peak - initial) * progress).round()),
      );
    });
    final totalTransferFee = transfers.fold<double>(
      0,
      (sum, transfer) => sum + transfer.feeMillions,
    );
    final profile = PlayerProfile(
      mode: CareerMode.dream,
      name: _text('name'),
      birthDate: _text('birthDate'),
      birthPlace: _text('birthPlace'),
      developmentAssociation: _text('nationality'),
      nationality: _text('nationality'),
      citizenships: _csv('citizenships'),
      preferredFoot: _preferredFoot,
      heightCm: int.parse(_controllers['height']!.text),
      weightKg: int.parse(_controllers['weight']!.text),
      shirtNumber: int.parse(_controllers['shirtNumber']!.text),
      primaryPosition: _position,
      secondaryPosition: _secondaryPosition,
      academy: _text('academy'),
      debutAge: debut,
      retirementAge: retirement,
      initialRating: initial,
      peakRating: peak,
      finalRating: int.parse(_controllers['final']!.text),
      playStyle: _text('style'),
      injuryRecord: _text('injury'),
      currentClub: _text('currentClub'),
      currentLeague: _text('league'),
      joinedClubDate: _text('joined'),
      contractUntil: _text('contractUntil'),
      agent: _text('agent'),
      marketValueMillions: double.parse(_controllers['marketValue']!.text),
      nationalTeam: _text('nationalTeam'),
      nationalTeamDebut: _text('nationalDebut'),
      career: chapters,
      transferHistory: transfers,
      injuryHistory: injuries,
      marketValueHistory: marketValues,
      competitionStats: competitionStats,
      stats: CareerStats(
        appearances: int.parse(_controllers['appearances']!.text),
        starts: int.parse(_controllers['starts']!.text),
        substituteAppearances: int.parse(
          _controllers['substituteAppearances']!.text,
        ),
        minutesPlayed: int.parse(_controllers['minutes']!.text),
        goals: int.parse(_controllers['goals']!.text),
        assists: int.parse(_controllers['assists']!.text),
        yellowCards: int.parse(_controllers['yellowCards']!.text),
        secondYellowCards: int.parse(_controllers['secondYellowCards']!.text),
        redCards: int.parse(_controllers['redCards']!.text),
        cleanSheets: int.parse(_controllers['cleanSheets']!.text),
        penaltiesScored: int.parse(_controllers['penalties']!.text),
        nationalCaps: int.parse(_controllers['caps']!.text),
        nationalGoals: int.parse(_controllers['nationalGoals']!.text),
        transferCount: transfers.length,
        totalTransferFeeMillions: double.parse(
          totalTransferFee.toStringAsFixed(1),
        ),
        championships: _csv('championships'),
        personalHonors: _csv('honors'),
      ),
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ResultScreen(profile: profile)),
    );
  }

  String _text(String key) => _controllers[key]!.text.trim();

  List<String> _csv(String key) {
    return _text(key)
        .split(RegExp(r'[,，]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  List<TransferRecord> _parseTransfers() {
    return [
      for (final (lineNumber, parts) in _structuredRows(
        'transferHistory',
        expectedFields: 6,
        format: '赛季|年龄|原俱乐部|新俱乐部|形式|费用',
      ))
        TransferRecord(
          season: parts[0],
          age: _rowInt(parts[1], '转会记录', lineNumber),
          fromClub: parts[2],
          toClub: parts[3],
          type: parts[4],
          feeMillions: _rowDouble(parts[5], '转会记录', lineNumber),
        ),
    ];
  }

  List<InjurySpell> _parseInjuries() {
    return [
      for (final (lineNumber, parts) in _structuredRows(
        'injuryHistory',
        expectedFields: 4,
        format: '赛季|伤病|缺阵天数|错过场次',
      ))
        InjurySpell(
          season: parts[0],
          type: parts[1],
          daysAbsent: _rowInt(parts[2], '伤病记录', lineNumber),
          matchesMissed: _rowInt(parts[3], '伤病记录', lineNumber),
        ),
    ];
  }

  List<MarketValuePoint> _parseMarketValues() {
    return [
      for (final (lineNumber, parts) in _structuredRows(
        'marketValueHistory',
        expectedFields: 2,
        format: '年龄|百万欧元',
      ))
        MarketValuePoint(
          age: _rowInt(parts[0], '身价轨迹', lineNumber),
          valueMillions: _rowDouble(parts[1], '身价轨迹', lineNumber),
        ),
    ];
  }

  List<CompetitionStats> _parseCompetitionStats() {
    return [
      for (final (lineNumber, parts) in _structuredRows(
        'competitionStats',
        expectedFields: 5,
        format: '赛事|出场|进球|助攻|分钟',
      ))
        CompetitionStats(
          competition: parts[0],
          appearances: _rowInt(parts[1], '分赛事统计', lineNumber),
          goals: _rowInt(parts[2], '分赛事统计', lineNumber),
          assists: _rowInt(parts[3], '分赛事统计', lineNumber),
          minutesPlayed: _rowInt(parts[4], '分赛事统计', lineNumber),
        ),
    ];
  }

  List<(int, List<String>)> _structuredRows(
    String key, {
    required int expectedFields,
    required String format,
  }) {
    final lines = _text(key).split(RegExp(r'\r?\n'));
    final rows = <(int, List<String>)>[];
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index].trim();
      if (line.isEmpty) continue;
      final parts = line.split('|').map((part) => part.trim()).toList();
      if (parts.length != expectedFields || parts.any((part) => part.isEmpty)) {
        throw FormatException('第 ${index + 1} 行格式错误，应为：$format');
      }
      rows.add((index + 1, parts));
    }
    return rows;
  }

  int _rowInt(String value, String label, int lineNumber) {
    final parsed = int.tryParse(value);
    if (parsed == null) {
      throw FormatException('$label第 $lineNumber 行包含无效整数。');
    }
    return parsed;
  }

  double _rowDouble(String value, String label, int lineNumber) {
    final parsed = double.tryParse(value);
    if (parsed == null) {
      throw FormatException('$label第 $lineNumber 行包含无效数字。');
    }
    return parsed;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '梦想球员 · 自由创作',
      child: Form(
        key: _formKey,
        child: ContentWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionLabel('Build your legend'),
              const SizedBox(height: 10),
              Text(
                '所有数据，\n都由你来定义。',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 10),
              Text(
                '下面的字段会原样进入故事生成请求。俱乐部用逗号分隔；结构化记录每行一条，用“|”分隔。',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _FormSection(
                title: '个人信息',
                children: [
                  _field('name', '球员姓名'),
                  _field('birthDate', '出生日期'),
                  _field('birthPlace', '出生地'),
                  _field('nationality', '国籍'),
                  _field('citizenships', '公民身份（逗号分隔）'),
                  _dropdown(
                    label: '主位置',
                    value: _position,
                    values: FootballCatalog.positions
                        .map((item) => item.value)
                        .toList(),
                    onChanged: (value) => setState(() => _position = value),
                  ),
                  _dropdown(
                    label: '第二位置',
                    value: _secondaryPosition,
                    values: FootballCatalog.positions
                        .map((item) => item.value)
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _secondaryPosition = value),
                  ),
                  _dropdown(
                    label: '惯用脚',
                    value: _preferredFoot,
                    values: const ['右脚', '左脚', '双足'],
                    onChanged: (value) =>
                        setState(() => _preferredFoot = value),
                  ),
                  _field('height', '身高（cm）', numeric: true),
                  _field('weight', '体重（kg）', numeric: true),
                  _field('shirtNumber', '球衣号码', numeric: true),
                  _field('style', '比赛风格'),
                ],
              ),
              const SizedBox(height: 14),
              _FormSection(
                title: '俱乐部、合同与国家队',
                children: [
                  _field('academy', '青训'),
                  _field('currentClub', '当前 / 最后效力俱乐部'),
                  _field('league', '联赛'),
                  _field('joined', '加盟日期'),
                  _field('contractUntil', '合同到期'),
                  _field('agent', '经纪人'),
                  _field('marketValue', '当前 / 峰值身价（百万欧元）', decimal: true),
                  _field('nationalTeam', '成年国家队'),
                  _field('nationalDebut', '国家队首秀日期'),
                ],
              ),
              const SizedBox(height: 14),
              _FormSection(
                title: '能力与生涯轨迹',
                description: '转会：赛季|年龄|原俱乐部|新俱乐部|形式|费用',
                children: [
                  _field('debut', '首秀年龄', numeric: true),
                  _field('retirement', '退役年龄', numeric: true),
                  _field('initial', '初始能力', numeric: true),
                  _field('peak', '巅峰能力', numeric: true),
                  _field('final', '退役能力', numeric: true),
                  _field('injury', '伤病记录', lines: 2),
                  _field('clubs', '俱乐部顺序（逗号分隔）', lines: 2),
                  _field(
                    'transferHistory',
                    '转会流水（每行一条）',
                    lines: 4,
                    optional: true,
                  ),
                  _field(
                    'injuryHistory',
                    '伤病流水：赛季|伤病|缺阵天数|错过场次',
                    lines: 3,
                    optional: true,
                  ),
                  _field(
                    'marketValueHistory',
                    '身价轨迹：年龄|百万欧元',
                    lines: 5,
                    optional: true,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _FormSection(
                title: '数据与荣誉',
                description: '分赛事：赛事|出场|进球|助攻|分钟',
                children: [
                  _field('appearances', '俱乐部出场', numeric: true),
                  _field('starts', '首发', numeric: true),
                  _field('substituteAppearances', '替补出场', numeric: true),
                  _field('minutes', '累计分钟', numeric: true),
                  _field('goals', '俱乐部进球', numeric: true),
                  _field('assists', '俱乐部助攻', numeric: true),
                  _field('yellowCards', '黄牌', numeric: true),
                  _field('secondYellowCards', '两黄变红', numeric: true),
                  _field('redCards', '直接红牌', numeric: true),
                  _field('cleanSheets', '零封', numeric: true),
                  _field('penalties', '点球进球', numeric: true),
                  _field('caps', '国家队出场', numeric: true),
                  _field('nationalGoals', '国家队进球', numeric: true),
                  _field(
                    'competitionStats',
                    '分赛事统计（每行一条）',
                    lines: 5,
                    optional: true,
                  ),
                  _field('championships', '冠军（逗号分隔）', lines: 2),
                  _field('honors', '个人荣誉（逗号分隔）', lines: 2),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('生成梦想球员档案'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    String key,
    String label, {
    bool numeric = false,
    bool decimal = false,
    bool optional = false,
    int lines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _controllers[key],
        decoration: InputDecoration(labelText: label),
        maxLines: lines,
        keyboardType: numeric || decimal
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        validator: optional
            ? null
            : numeric || decimal
            ? (value) {
                if (decimal && double.tryParse(value ?? '') == null) {
                  return '请输入数字';
                }
                return decimal ? null : _integer(value);
              }
            : _required,
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> values,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: values
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: (selected) {
          if (selected != null) onChanged(selected);
        },
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.children,
    this.description,
  });

  final String title;
  final List<Widget> children;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 5),
              Text(description!, style: Theme.of(context).textTheme.bodyMedium),
            ],
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
