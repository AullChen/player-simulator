import 'package:flutter/material.dart';

import '../data/football_catalog.dart';
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
              '你只能指定国籍和场上位置。能力、俱乐部与荣誉会被五次生涯抉择逐步塑造。',
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
                    const SizedBox(height: 22),
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => LifeModeScreen(
                            nationality: _nationality,
                            position: _position,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('进入 15 岁的第一个选择'),
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
