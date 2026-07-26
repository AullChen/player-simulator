import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import 'dream_mode_screen.dart';
import 'life_setup_screen.dart';
import 'random_mode_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _HeroPanel()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionLabel('Choose a career path'),
                      SizedBox(height: 8),
                      Text(
                        '选择一条职业生涯',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                          color: AppColors.ink,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '概率、选择或想象——三种方式，都会生成一份完整球员档案与生涯故事。',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 15,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cards = [
                        _ModeCard(
                          number: '01',
                          title: '全随机',
                          subtitle: '真实概率模式',
                          description: '逐项转动概率轮盘，抽出国籍、位置、青训与完整职业履历。',
                          icon: Icons.casino_outlined,
                          accent: AppColors.pitchDark,
                          onTap: () => _open(context, const RandomModeScreen()),
                        ),
                        _ModeCard(
                          number: '02',
                          title: '模拟球员',
                          subtitle: '生涯选择模式',
                          description: '只指定国籍和位置，在五个关键年龄做出改变命运的选择。',
                          icon: Icons.account_tree_outlined,
                          accent: const Color(0xFF2E5D9F),
                          onTap: () => _open(context, const LifeSetupScreen()),
                        ),
                        _ModeCard(
                          number: '03',
                          title: '梦想球员',
                          subtitle: '完全创作模式',
                          description: '亲手填写能力、俱乐部、数据与荣誉，让理想生涯成为故事。',
                          icon: Icons.auto_awesome_outlined,
                          accent: AppColors.gold,
                          onTap: () => _open(context, const DreamModeScreen()),
                        ),
                      ];
                      if (constraints.maxWidth >= 780) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var index = 0; index < cards.length; index++)
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: index == cards.length - 1 ? 0 : 14,
                                  ),
                                  child: cards[index],
                                ),
                              ),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          for (var index = 0; index < cards.length; index++)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: index == cards.length - 1 ? 0 : 14,
                              ),
                              child: cards[index],
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }
}

class _HeroPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 355),
      color: AppColors.navy,
      child: CustomPaint(
        painter: _PitchBlueprintPainter(),
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 42, 24, 46),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionLabel('Career Lab / 2026', light: true),
                          const SizedBox(height: 18),
                          Text(
                            '这一回，\n由你书写球员生涯。',
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            '从第一份青训合同到告别赛场，把概率与选择变成一条能被讲述的足球人生。',
                            style: TextStyle(
                              color: Color(0xFFC4D0D5),
                              fontSize: 16,
                              height: 1.65,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (MediaQuery.sizeOf(context).width >= 760) ...[
                      const SizedBox(width: 48),
                      const Expanded(flex: 2, child: _ScoutBadge()),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoutBadge extends StatelessWidget {
  const _ScoutBadge();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.gold, width: 2),
          color: AppColors.navySoft.withValues(alpha: 0.82),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_soccer, color: AppColors.gold, size: 54),
            SizedBox(height: 14),
            Text(
              'PLAYER\nDOSSIER',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 3.5,
                height: 1.35,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'EST. 2026',
              style: TextStyle(
                color: Color(0xFF96AAB4),
                fontSize: 10,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String number;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: accent),
                  ),
                  Text(
                    number,
                    style: TextStyle(
                      color: accent.withValues(alpha: 0.45),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(subtitle, style: TextStyle(color: accent, fontSize: 12)),
              const SizedBox(height: 4),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    '开始模拟',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18, color: accent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PitchBlueprintPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.055)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final field = Rect.fromLTWH(
      size.width * 0.48,
      -40,
      size.width * 0.62,
      size.height + 80,
    );
    canvas.drawRect(field, paint);
    canvas.drawLine(
      Offset(field.center.dx, field.top),
      Offset(field.center.dx, field.bottom),
      paint,
    );
    canvas.drawCircle(field.center, size.height * 0.18, paint);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(field.left, field.center.dy),
        width: size.width * 0.16,
        height: size.height * 0.46,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(field.right, field.center.dy),
        width: size.width * 0.16,
        height: size.height * 0.46,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
