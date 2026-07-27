import 'package:flutter/material.dart';

import '../domain/player_profile.dart';
import '../domain/random_draw_step.dart';
import '../l10n/app_localizations.dart';
import '../services/random_career_generator.dart';
import '../services/random_draw_plan.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/probability_wheel.dart';
import 'dream_mode_screen.dart';
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
  late List<RandomDrawStep> _steps;
  var _step = 0;
  var _spinning = false;
  var _holdingResult = false;

  bool get _busy => _spinning || _holdingResult;

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
    _steps = RandomDrawPlan.build(_profile);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _spin() async {
    if (_busy || _step >= _steps.length) return;
    setState(() => _spinning = true);
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      await _controller.forward(from: 0);
    }
    if (!mounted) return;
    setState(() {
      _spinning = false;
      _holdingResult = true;
    });
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _step += 1;
      _holdingResult = false;
      _controller.reset();
    });
  }

  void _finishCurrentTrack() {
    if (_busy || _step >= _steps.length) return;
    final track = _steps[_step].track;
    var next = _step;
    while (next < _steps.length && _steps[next].track == track) {
      next += 1;
    }
    setState(() {
      _step = next;
      _controller.reset();
    });
  }

  void _restart() {
    setState(() {
      _step = 0;
      _spinning = false;
      _holdingResult = false;
      _controller.reset();
      _resetProfile();
    });
  }

  Future<void> _openEditor() async {
    if (_busy) return;
    final currentId = _step < _steps.length ? _steps[_step].id : null;
    final edited = await Navigator.of(context).push<PlayerProfile>(
      MaterialPageRoute<PlayerProfile>(
        builder: (_) =>
            DreamModeScreen(initialProfile: _profile, returnProfile: true),
      ),
    );
    if (!mounted || edited == null) return;
    final rebuilt = RandomDrawPlan.build(edited);
    var nextStep = currentId == null
        ? rebuilt.length
        : rebuilt.indexWhere((item) => item.id == currentId);
    if (nextStep < 0) nextStep = _step.clamp(0, rebuilt.length);
    setState(() {
      _profile = edited;
      _steps = rebuilt;
      _step = nextStep;
      _controller.reset();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.tr(
            '修改已保存，依赖字段和时间线已重新校验。',
            'Changes saved; dependent fields and the timeline were revalidated.',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final complete = _step == _steps.length;
    final current = complete ? null : _steps[_step];
    final recentStart = (_step - 6).clamp(0, _step);
    final recent = _steps.sublist(recentStart, _step).reversed;

    return AppScaffold(
      title: context.tr('全随机 · 比例转盘', 'Full random · Proportionate wheels'),
      actions: [
        IconButton(
          onPressed: _busy ? null : _restart,
          tooltip: context.tr('重新开始', 'Restart'),
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: ContentWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TrackRail(steps: _steps, completed: _step),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: SectionLabel('Career draw timeline')),
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
              complete
                  ? context.tr('所有履历字段已经完成', 'Every dossier field is complete')
                  : context.isEnglish
                  ? current!.titleEn
                  : current!.titleZh,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              complete
                  ? context.tr(
                      '个人信息、俱乐部和国家队三条线已经汇合，可以打开完整档案。',
                      'Personal, club, and national-team timelines have converged into one complete dossier.',
                    )
                  : context.tr(
                      '扇区面积严格等于该项权重；当前结果会落在指针所指的扇区。',
                      'Each sector’s area exactly matches its weight; the selected result lands under the pointer.',
                    ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            if (!complete) ...[
              Card(
                color: AppColors.navy,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _TrackBadge(track: current!.track),
                          const Spacer(),
                          if (current.age != null)
                            Text(
                              context.tr(
                                '${current.age} 岁',
                                'Age ${current.age}',
                              ),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ProbabilityWheel(
                        animation: _controller,
                        segments: current.segments,
                        selectedValue: current.selectedSegment,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        context.isEnglish
                            ? current.categoryEn
                            : current.categoryZh,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _holdingResult
                            ? (context.isEnglish
                                  ? current.resultEn
                                  : current.resultZh)
                            : _spinning
                            ? context.tr('正在决定…', 'Deciding…')
                            : context.tr('等待转盘', 'Waiting for the wheel'),
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _busy ? null : _spin,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.navy,
                          ),
                          child: Text(
                            _holdingResult
                                ? context.tr('结果锁定中…', 'Result held on screen…')
                                : _spinning
                                ? context.tr('轮盘转动中…', 'Wheel spinning…')
                                : context.tr('转动当前轮盘', 'Spin current wheel'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextButton(
                        onPressed: _busy ? null : _finishCurrentTrack,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                        ),
                        child: Text(
                          context.tr(
                            '快速完成本条主线',
                            'Quick-complete this timeline',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _ProbabilityNote(step: current),
            ],
            if (recent.isNotEmpty) ...[
              const SizedBox(height: 22),
              Text(
                context.tr('最近抽取', 'Recent draws'),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              for (final step in recent)
                _RevealRow(step: step, onEdit: _openEditor),
            ],
            if (_step > 6) ...[
              const SizedBox(height: 2),
              Text(
                context.tr(
                  '另有 ${_step - 6} 项已写入最终档案。',
                  '${_step - 6} earlier fields are already in the final dossier.',
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (complete) ...[
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ResultScreen(profile: _profile),
                  ),
                ),
                icon: const Icon(Icons.description_outlined),
                label: Text(
                  context.tr('打开完整球员档案', 'Open complete player dossier'),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _openEditor,
                icon: const Icon(Icons.edit_note_outlined),
                label: Text(
                  context.tr('手动校正抽取档案', 'Manually revise the drawn dossier'),
                ),
              ),
            ],
            const SizedBox(height: 18),
            Text(
              context.tr(
                '点击下方已抽取项目的编辑按钮，可载入完整档案并同步修改相关字段。',
                'Use the edit button beside a revealed item to revise the full dossier and its dependent fields.',
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackRail extends StatelessWidget {
  const _TrackRail({required this.steps, required this.completed});

  final List<RandomDrawStep> steps;
  final int completed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final track in RandomDrawTrack.values) ...[
          Expanded(
            child: _TrackProgress(
              track: track,
              total: steps.where((step) => step.track == track).length,
              completed: steps
                  .take(completed)
                  .where((step) => step.track == track)
                  .length,
            ),
          ),
          if (track != RandomDrawTrack.values.last)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 7),
              child: Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.muted,
              ),
            ),
        ],
      ],
    );
  }
}

class _TrackProgress extends StatelessWidget {
  const _TrackProgress({
    required this.track,
    required this.total,
    required this.completed,
  });

  final RandomDrawTrack track;
  final int total;
  final int completed;

  @override
  Widget build(BuildContext context) {
    final active = completed < total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(_trackIcon(track), size: 15, color: _trackColor(track)),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                _trackName(context, track),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '$completed/$total',
              style: const TextStyle(color: AppColors.muted, fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: total == 0 ? 0 : completed / total,
          minHeight: active ? 5 : 4,
          color: _trackColor(track),
          backgroundColor: AppColors.line,
          borderRadius: BorderRadius.circular(99),
        ),
      ],
    );
  }
}

class _TrackBadge extends StatelessWidget {
  const _TrackBadge({required this.track});

  final RandomDrawTrack track;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _trackColor(track).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_trackIcon(track), color: _trackColor(track), size: 15),
          const SizedBox(width: 6),
          Text(
            _trackName(context, track),
            style: TextStyle(
              color: _trackColor(track),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProbabilityNote extends StatelessWidget {
  const _ProbabilityNote({required this.step});

  final RandomDrawStep step;

  @override
  Widget build(BuildContext context) {
    final probability = step.selectedProbability * 100;
    final probabilityText = probability < 0.01
        ? '<0.01%'
        : '${probability.toStringAsFixed(probability < 1 ? 2 : 1)}%';
    final kind = switch (step.probabilityKind) {
      DrawProbabilityKind.official => context.tr('FIFA 原始值', 'FIFA source'),
      DrawProbabilityKind.calibrated => context.tr(
        '公开数据校准',
        'Public-data calibrated',
      ),
      DrawProbabilityKind.modeled => context.tr('模型权重', 'Model weight'),
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.data_usage_outlined,
            color: AppColors.pitchDark,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$kind · ${context.tr('命中扇区', 'selected sector')} $probabilityText',
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  context.isEnglish ? step.sourceNoteEn : step.sourceNoteZh,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RevealRow extends StatelessWidget {
  const _RevealRow({required this.step, required this.onEdit});

  final RandomDrawStep step;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
            decoration: BoxDecoration(
              color: _trackColor(step.track).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _trackIcon(step.track),
              size: 17,
              color: _trackColor(step.track),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.isEnglish ? step.categoryEn : step.categoryZh,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  context.isEnglish ? step.resultEn : step.resultZh,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(step.selectedProbability * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onEdit,
            tooltip: context.tr('手动修改档案', 'Edit dossier'),
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.edit_outlined, size: 18),
          ),
        ],
      ),
    );
  }
}

String _trackName(BuildContext context, RandomDrawTrack track) {
  return switch (track) {
    RandomDrawTrack.personal => context.tr('个人', 'Personal'),
    RandomDrawTrack.club => context.tr('俱乐部', 'Club'),
    RandomDrawTrack.nationalTeam => context.tr('国家队', 'National'),
  };
}

IconData _trackIcon(RandomDrawTrack track) => switch (track) {
  RandomDrawTrack.personal => Icons.badge_outlined,
  RandomDrawTrack.club => Icons.stadium_outlined,
  RandomDrawTrack.nationalTeam => Icons.flag_outlined,
};

Color _trackColor(RandomDrawTrack track) => switch (track) {
  RandomDrawTrack.personal => AppColors.gold,
  RandomDrawTrack.club => AppColors.pitch,
  RandomDrawTrack.nationalTeam => const Color(0xFF6FA8DC),
};
