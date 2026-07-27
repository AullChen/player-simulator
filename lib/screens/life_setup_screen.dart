import 'package:flutter/material.dart';

import '../data/football_catalog.dart';
import '../l10n/app_localizations.dart';
import '../services/life_simulator.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import 'life_mode_screen.dart';

class LifeSetupScreen extends StatefulWidget {
  const LifeSetupScreen({super.key});

  @override
  State<LifeSetupScreen> createState() => _LifeSetupScreenState();
}

class _LifeSetupScreenState extends State<LifeSetupScreen> {
  late String _nationality;
  late String _position;
  CareerDecisionDensity _density = CareerDecisionDensity.milestones;

  @override
  void initState() {
    super.initState();
    _nationality = FootballCatalog.nationalities.first.value;
    _position = FootballCatalog.positions.first.value;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: context.tr('模拟球员 · 基础设定', 'Life player · Setup'),
      child: ContentWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionLabel(context.tr('人生模拟', 'LIFE SIMULATION')),
            const SizedBox(height: 10),
            Text(
              context.tr(
                '只决定起点，\n把过程交给选择。',
                'Choose the starting point.\nLet decisions shape the rest.',
              ),
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 10),
            Text(
              context.tr(
                '你只指定国籍、场上位置和选择密度。能力、俱乐部与荣誉会被每一次生涯抉择逐步塑造。',
                'Choose nationality, position and decision density. Every '
                    'decision shapes abilities, clubs and honours.',
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.tr('基础信息', 'Basic information'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<String>(
                      value: _nationality,
                      decoration: InputDecoration(
                        labelText: context.tr('国籍', 'Nationality'),
                        prefixIcon: const Icon(Icons.public),
                      ),
                      items: FootballCatalog.nationalities
                          .map(
                            (item) => DropdownMenuItem(
                              value: item.value,
                              child: Text(item.value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _nationality = value);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _position,
                      decoration: InputDecoration(
                        labelText: context.tr('球场位置', 'Position'),
                        prefixIcon: const Icon(Icons.sports_soccer),
                      ),
                      items: FootballCatalog.positions
                          .map(
                            (item) => DropdownMenuItem(
                              value: item.value,
                              child: Text(item.value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _position = value);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.tr('选择密度', 'Decision density'),
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      context.tr(
                        '从 5 个关键节点到逐年选择。更多节点意味着更多风险与塑造人物的机会。',
                        'Choose five milestones or every career year. More '
                            'nodes mean more risk and more chances to shape the player.',
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    for (final density in CareerDecisionDensity.values) ...[
                      _DensityCard(
                        density: density,
                        selected: density == _density,
                        onTap: () => setState(() => _density = density),
                      ),
                      if (density != CareerDecisionDensity.values.last)
                        const SizedBox(height: 9),
                    ],
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => LifeModeScreen(
                            nationality: _nationality,
                            position: _position,
                            density: _density,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(
                        context.tr(
                          '开始 ${_density.nodeCount} 个生涯选择',
                          'Start ${_density.nodeCount} career choices',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EEF6),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF2E5D9F)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.tr(
                        '没有“正确答案”。训练会提高能力，也会积累负荷；人物数值会改变未来能看到的分支。',
                        'There is no single right answer. Training builds '
                            'ability and load; character values change future branches.',
                      ),
                      style: const TextStyle(
                        color: Color(0xFF29445F),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DensityCard extends StatelessWidget {
  const _DensityCard({
    required this.density,
    required this.selected,
    required this.onTap,
  });

  final CareerDecisionDensity density;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFE8F5EF) : AppColors.mist,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.pitchDark : AppColors.line,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: selected ? AppColors.pitchDark : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.pitchDark : AppColors.muted,
                    width: 2,
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check, size: 15, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.tr(density.label, density.labelEn),
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          context.tr(
                            '${density.nodeCount} 节点 · ${density.estimatedTime}',
                            '${density.nodeCount} nodes · ${density.estimatedTimeEn}',
                          ),
                          style: const TextStyle(
                            color: AppColors.pitchDark,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr(density.description, density.descriptionEn),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
