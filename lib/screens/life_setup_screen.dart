import 'package:flutter/material.dart';

import '../data/football_catalog.dart';
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
      title: '模拟球员 · 基础设定',
      child: ContentWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionLabel('Life simulation'),
            const SizedBox(height: 10),
            Text(
              '只决定起点，\n把过程交给选择。',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 10),
            Text(
              '你只指定国籍、场上位置和选择密度。能力、俱乐部与荣誉会被每一次生涯抉择逐步塑造。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '基础信息',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<String>(
                      value: _nationality,
                      decoration: const InputDecoration(
                        labelText: '国籍',
                        prefixIcon: Icon(Icons.public),
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
                      decoration: const InputDecoration(
                        labelText: '球场位置',
                        prefixIcon: Icon(Icons.sports_soccer),
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
                    const Text(
                      '选择密度',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '密度只改变叙事细节，最终属性会按等效 5 次选择归一化。',
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
                      label: Text('开始 ${_density.nodeCount} 个生涯选择'),
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
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF2E5D9F)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '没有“正确答案”。激进选择提升能力与声望，稳定选择通常带来更长的出场时间。',
                      style: TextStyle(color: Color(0xFF29445F), height: 1.5),
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
                            density.label,
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          '${density.nodeCount} 节点 · ${density.estimatedTime}',
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
                      density.description,
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
