import 'package:flutter/material.dart';

import '../domain/player_profile.dart';
import '../l10n/app_localizations.dart';
import '../services/life_simulator.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import 'result_screen.dart';

class LifeModeScreen extends StatefulWidget {
  const LifeModeScreen({
    super.key,
    required this.nationality,
    required this.position,
    this.density = CareerDecisionDensity.milestones,
  });

  final String nationality;
  final String position;
  final CareerDecisionDensity density;

  @override
  State<LifeModeScreen> createState() => _LifeModeScreenState();
}

class _LifeModeScreenState extends State<LifeModeScreen> {
  late final LifeSimulator _simulator;
  PlayerProfile? _completedProfile;

  @override
  void initState() {
    super.initState();
    _simulator = LifeSimulator(
      nationality: widget.nationality,
      position: widget.position,
      density: widget.density,
    );
  }

  void _choose(int choiceIndex) {
    _simulator.choose(_simulator.decisions.length, choiceIndex);
    if (_simulator.isComplete) {
      _completedProfile = _simulator.finish();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final recentDecisions = _simulator.decisions.length <= 3
        ? _simulator.decisions
        : _simulator.decisions.sublist(_simulator.decisions.length - 3);

    return AppScaffold(
      title: '${widget.nationality} · ${widget.position}',
      child: ContentWidth(
        child: AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 280),
          child: _simulator.isComplete
              ? _CompletionPanel(
                  key: const ValueKey('complete'),
                  simulator: _simulator,
                  profile: _completedProfile!,
                )
              : _CareerStage(
                  key: ValueKey(_simulator.decisions.length),
                  simulator: _simulator,
                  recentDecisions: recentDecisions,
                  onChoose: _choose,
                ),
        ),
      ),
    );
  }
}

class _CareerStage extends StatelessWidget {
  const _CareerStage({
    super.key,
    required this.simulator,
    required this.recentDecisions,
    required this.onChoose,
  });

  final LifeSimulator simulator;
  final List<LifeDecision> recentDecisions;
  final ValueChanged<int> onChoose;

  @override
  Widget build(BuildContext context) {
    final stage = simulator.currentStage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StageProgress(
          current: simulator.decisions.length,
          total: simulator.totalStages,
          density: context.tr(
            simulator.density.label,
            simulator.density.labelEn,
          ),
        ),
        const SizedBox(height: 24),
        SectionLabel('AGE ${stage.age}'),
        const SizedBox(height: 8),
        Text(
          context.tr(stage.titleZh, stage.titleEn),
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 10),
        Text(
          context.tr(stage.contextZh, stage.contextEn),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PoolChip(
              icon: Icons.stadium_outlined,
              text: context.tr(
                '当前俱乐部：${simulator.currentClub}',
                'Current club: ${simulator.currentClub}',
              ),
            ),
            _PoolChip(
              icon: Icons.style_outlined,
              text: context.tr(
                '本轮有 ${stage.choices.length} 条可选道路',
                '${stage.choices.length} paths this round',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        for (var index = 0; index < stage.choices.length; index++)
          _ChoiceCard(
            index: index,
            choice: stage.choices[index],
            onTap: () => onChoose(index),
          ),
        if (recentDecisions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            '${context.tr('近期轨迹', 'Recent path')}: '
            '${recentDecisions.map((decision) => context.tr(decision.choice.titleZh, decision.choice.titleEn)).join(' → ')}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }
}

class _PoolChip extends StatelessWidget {
  const _PoolChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF6),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF2E5D9F)),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF2E5D9F),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StageProgress extends StatelessWidget {
  const _StageProgress({
    required this.current,
    required this.total,
    required this.density,
  });

  final int current;
  final int total;
  final String density;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$density · ${current + 1} / $total',
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '${((current + 1) / total * 100).round()}%',
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: (current + 1) / total,
            minHeight: 6,
            backgroundColor: AppColors.line,
            color: const Color(0xFF2E5D9F),
          ),
        ),
      ],
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.index,
    required this.choice,
    required this.onTap,
  });

  final int index;
  final LifeChoice choice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EEF6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: const TextStyle(
                      color: Color(0xFF2E5D9F),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5EF),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: AppColors.pitchDark.withValues(alpha: 0.24),
                          ),
                        ),
                        child: Text(
                          context.tr(
                            choice.actionLabelZh,
                            choice.actionLabelEn,
                          ),
                          style: const TextStyle(
                            color: AppColors.pitchDark,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr(choice.titleZh, choice.titleEn),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${context.tr('背景：', 'Context: ')}'
                        '${context.tr(choice.backgroundZh, choice.backgroundEn)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 9),
                      Text(
                        '${context.tr('你要做：', 'Your action: ')}'
                        '${context.tr(choice.descriptionZh, choice.descriptionEn)}',
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F7FA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Text(
                          '${context.tr('确认结果：', 'Confirmed outcome: ')}'
                          '${context.tr(choice.outcomeZh, choice.outcomeEn)}',
                          style: const TextStyle(
                            color: Color(0xFF29445F),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompletionPanel extends StatelessWidget {
  const _CompletionPanel({
    super.key,
    required this.simulator,
    required this.profile,
  });

  final LifeSimulator simulator;
  final PlayerProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(context.tr('生涯完成', 'CAREER COMPLETE')),
        const SizedBox(height: 10),
        Text(
          context.tr(
            '${simulator.decisions.length} 次选择，\n一段完整人生。',
            '${simulator.decisions.length} choices.\nOne complete career.',
          ),
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 20),
        if (simulator.retirementOutcome case final outcome?) ...[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4DF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5BE6A)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.flag_outlined, color: Color(0xFF8A5A00)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(outcome.titleZh, outcome.titleEn),
                        style: const TextStyle(
                          color: Color(0xFF6D4800),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        context.tr(outcome.contextZh, outcome.contextEn),
                        style: const TextStyle(
                          color: Color(0xFF6D531F),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],
        Card(
          color: AppColors.navy,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('选择轨迹', 'Decision path'),
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                for (final decision in simulator.decisions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 52,
                          child: Text(
                            context.tr(
                              '${decision.stage.age} 岁',
                              'Age ${decision.stage.age}',
                            ),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            context.tr(
                              decision.choice.titleZh,
                              decision.choice.titleEn,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ResultScreen(profile: profile),
            ),
          ),
          icon: const Icon(Icons.description_outlined),
          label: Text(context.tr('查看最终档案与故事', 'View dossier and story')),
        ),
      ],
    );
  }
}
