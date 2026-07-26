import 'package:flutter/material.dart';

import '../services/life_simulator.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import 'result_screen.dart';

class LifeModeScreen extends StatefulWidget {
  const LifeModeScreen({
    super.key,
    required this.nationality,
    required this.position,
  });

  final String nationality;
  final String position;

  @override
  State<LifeModeScreen> createState() => _LifeModeScreenState();
}

class _LifeModeScreenState extends State<LifeModeScreen> {
  late final LifeSimulator _simulator;
  var _stageIndex = 0;

  @override
  void initState() {
    super.initState();
    _simulator = LifeSimulator(
      nationality: widget.nationality,
      position: widget.position,
    );
  }

  void _choose(int choiceIndex) {
    _simulator.choose(_stageIndex, choiceIndex);
    setState(() => _stageIndex += 1);
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = _stageIndex == LifeSimulator.stages.length;
    final stage = isComplete ? null : LifeSimulator.stages[_stageIndex];

    return AppScaffold(
      title: '${widget.nationality} · ${widget.position}',
      child: ContentWidth(
        child: AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 280),
          child: isComplete
              ? _CompletionPanel(
                  key: const ValueKey('complete'),
                  simulator: _simulator,
                )
              : Column(
                  key: ValueKey(_stageIndex),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _StageProgress(current: _stageIndex),
                    const SizedBox(height: 28),
                    SectionLabel('Age ${stage!.age}'),
                    const SizedBox(height: 8),
                    Text(
                      stage.title,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      stage.context,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    for (var index = 0; index < stage.choices.length; index++)
                      _ChoiceCard(
                        index: index,
                        choice: stage.choices[index],
                        onTap: () => _choose(index),
                      ),
                    if (_simulator.decisions.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Text(
                        '此前选择：${_simulator.decisions.map((decision) => decision.choice.title).join(' → ')}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _StageProgress extends StatelessWidget {
  const _StageProgress({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < LifeSimulator.stages.length; index++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 5,
              decoration: BoxDecoration(
                color: index <= current
                    ? const Color(0xFF2E5D9F)
                    : AppColors.line,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          if (index != LifeSimulator.stages.length - 1)
            const SizedBox(width: 6),
        ],
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
                      Text(
                        choice.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        choice.description,
                        style: Theme.of(context).textTheme.bodyMedium,
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
  const _CompletionPanel({super.key, required this.simulator});

  final LifeSimulator simulator;

  @override
  Widget build(BuildContext context) {
    final profile = simulator.finish();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Career complete'),
        const SizedBox(height: 10),
        Text('五次选择，\n一段完整人生。', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 20),
        Card(
          color: AppColors.navy,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '选择轨迹',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                for (final decision in simulator.decisions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 52,
                          child: Text(
                            '${decision.stage.age} 岁',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            decision.choice.title,
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
          label: const Text('查看最终档案与故事'),
        ),
      ],
    );
  }
}
