import 'package:flutter/material.dart';

import '../domain/player_profile.dart';
import '../services/random_career_generator.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/probability_wheel.dart';
import 'result_screen.dart';

class RandomModeScreen extends StatefulWidget {
  const RandomModeScreen({super.key});

  @override
  State<RandomModeScreen> createState() => _RandomModeScreenState();
}

class _RandomModeScreenState extends State<RandomModeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late PlayerProfile _profile;
  var _step = 0;
  var _spinning = false;

  late final List<_DrawStep> _steps;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1650),
    );
    _resetProfile();
  }

  void _resetProfile() {
    _profile = RandomCareerGenerator().generate();
    _steps = [
      _DrawStep(
        title: '出生地与足球文化',
        category: '国籍',
        value: _profile.nationality,
        labels: const ['巴西', '法国', '西班牙', '英格兰', '德国', '阿根廷', '亚洲', '其他'],
      ),
      _DrawStep(
        title: '身体习惯',
        category: '惯用脚',
        value: _profile.preferredFoot,
        labels: const ['右脚', '右脚', '左脚', '右脚', '双足', '左脚'],
      ),
      _DrawStep(
        title: '球场上的职责',
        category: '位置',
        value: '${_profile.primaryPosition} · ${_profile.heightCm} cm',
        labels: const ['门将', '中后卫', '边后卫', '后腰', '中前卫', '前腰', '边锋', '中锋'],
      ),
      _DrawStep(
        title: '第一堂职业课',
        category: '青训',
        value: _profile.academy,
        labels: const ['豪门梯队', '精英学院', '地区青训', '校园足球', '海外学院', '社区球队'],
      ),
      _DrawStep(
        title: '漫长职业生涯',
        category: '生涯',
        value:
            '巅峰 ${_profile.peakRating} · ${_profile.stats.transferCount} 次转会',
        labels: const ['稳步成长', '天才爆发', '伤病考验', '豪门征召', '国家队', '冠军时刻'],
      ),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _spin() async {
    if (_spinning || _step >= _steps.length) return;
    setState(() => _spinning = true);
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      await _controller.forward(from: 0);
    }
    if (!mounted) return;
    setState(() {
      _step += 1;
      _spinning = false;
    });
  }

  void _restart() {
    setState(() {
      _step = 0;
      _spinning = false;
      _controller.reset();
      _resetProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = _step == _steps.length;
    final current = _steps[isComplete ? _steps.length - 1 : _step];

    return AppScaffold(
      title: '全随机 · 真实概率',
      actions: [
        IconButton(
          onPressed: _spinning ? null : _restart,
          tooltip: '重新开始',
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: ContentWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionLabel('Probability draw'),
                Text(
                  '$_step / ${_steps.length}',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              isComplete ? '球员档案已经完成' : current.title,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              isComplete
                  ? '所有抽取已写入履历，现在可以查看数据并生成故事。'
                  : '轮盘扇区反映加权类别，最终结果由领域层概率表决定。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            Card(
              color: AppColors.navy,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 26, 18, 24),
                child: Column(
                  children: [
                    ProbabilityWheel(
                      animation: _controller,
                      labels: current.labels,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isComplete ? '抽取完成' : '本轮：${current.category}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: isComplete || _spinning ? null : _spin,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.navy,
                        ),
                        child: Text(_spinning ? '轮盘转动中…' : '转动轮盘'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            if (_step > 0) ...[
              const Text('已抽取', style: TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              for (var index = 0; index < _step; index++)
                _RevealRow(step: _steps[index]),
            ],
            if (isComplete) ...[
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ResultScreen(profile: _profile),
                  ),
                ),
                icon: const Icon(Icons.description_outlined),
                label: const Text('打开完整球员档案'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DrawStep {
  const _DrawStep({
    required this.title,
    required this.category,
    required this.value,
    required this.labels,
  });

  final String title;
  final String category;
  final String value;
  final List<String> labels;
}

class _RevealRow extends StatelessWidget {
  const _RevealRow({required this.step});

  final _DrawStep step;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFFE6F5EF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 18,
              color: AppColors.pitchDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.category,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  step.value,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
