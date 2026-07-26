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
    'nationality': TextEditingController(text: '中国'),
    'height': TextEditingController(text: '181'),
    'academy': TextEditingController(text: '梦想足球学院'),
    'debut': TextEditingController(text: '17'),
    'retirement': TextEditingController(text: '38'),
    'initial': TextEditingController(text: '68'),
    'peak': TextEditingController(text: '94'),
    'final': TextEditingController(text: '78'),
    'style': TextEditingController(text: '自由组织核心'),
    'injury': TextEditingController(text: '生涯健康，只有短期伤停'),
    'clubs': TextEditingController(text: '家乡俱乐部, 欧洲新星队, 世界全明星'),
    'appearances': TextEditingController(text: '628'),
    'goals': TextEditingController(text: '214'),
    'assists': TextEditingController(text: '286'),
    'caps': TextEditingController(text: '126'),
    'nationalGoals': TextEditingController(text: '48'),
    'transfers': TextEditingController(text: '2'),
    'fees': TextEditingController(text: '188.5'),
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
    final profile = PlayerProfile(
      mode: CareerMode.dream,
      name: _text('name'),
      nationality: _text('nationality'),
      preferredFoot: _preferredFoot,
      heightCm: int.parse(_controllers['height']!.text),
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
      career: chapters,
      stats: CareerStats(
        appearances: int.parse(_controllers['appearances']!.text),
        goals: int.parse(_controllers['goals']!.text),
        assists: int.parse(_controllers['assists']!.text),
        nationalCaps: int.parse(_controllers['caps']!.text),
        nationalGoals: int.parse(_controllers['nationalGoals']!.text),
        transferCount: int.parse(_controllers['transfers']!.text),
        totalTransferFeeMillions: double.parse(_controllers['fees']!.text),
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
                '下面的字段会原样进入故事生成请求。逗号分隔的俱乐部将按顺序组成生涯时间轴。',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _FormSection(
                title: '个人信息',
                children: [
                  _field('name', '球员姓名'),
                  _field('nationality', '国籍'),
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
                  _field('style', '比赛风格'),
                ],
              ),
              const SizedBox(height: 14),
              _FormSection(
                title: '能力与生涯',
                children: [
                  _field('academy', '青训'),
                  _field('debut', '首秀年龄', numeric: true),
                  _field('retirement', '退役年龄', numeric: true),
                  _field('initial', '初始能力', numeric: true),
                  _field('peak', '巅峰能力', numeric: true),
                  _field('final', '退役能力', numeric: true),
                  _field('injury', '伤病记录', lines: 2),
                  _field('clubs', '俱乐部顺序（逗号分隔）', lines: 2),
                ],
              ),
              const SizedBox(height: 14),
              _FormSection(
                title: '数据与荣誉',
                children: [
                  _field('appearances', '俱乐部出场', numeric: true),
                  _field('goals', '俱乐部进球', numeric: true),
                  _field('assists', '俱乐部助攻', numeric: true),
                  _field('caps', '国家队出场', numeric: true),
                  _field('nationalGoals', '国家队进球', numeric: true),
                  _field('transfers', '转会次数', numeric: true),
                  _field('fees', '累计转会费（百万欧元）', decimal: true),
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
        validator: numeric || decimal
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
  const _FormSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

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
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
