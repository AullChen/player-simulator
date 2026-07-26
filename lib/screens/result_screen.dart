import 'package:flutter/material.dart';

import '../domain/player_profile.dart';
import '../services/story_api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.profile, this.storyClient});

  final PlayerProfile profile;
  final StoryApiClient? storyClient;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final StoryApiClient _storyClient;
  String? _story;
  Object? _storyError;

  @override
  void initState() {
    super.initState();
    _storyClient = widget.storyClient ?? StoryApiClient.fromEnvironment();
    _loadStory();
  }

  Future<void> _loadStory() async {
    setState(() {
      _story = null;
      _storyError = null;
    });
    try {
      final story = await _storyClient.generate(widget.profile);
      if (!mounted) return;
      setState(() => _story = story);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _storyError = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    return AppScaffold(
      title: '球员生涯档案',
      child: ContentWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DossierHeader(profile: profile),
            const SizedBox(height: 18),
            GridView.count(
              crossAxisCount: MediaQuery.sizeOf(context).width >= 620 ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.45,
              children: [
                MetricTile(
                  value: '${profile.peakRating}',
                  label: '巅峰能力',
                  emphasized: true,
                ),
                MetricTile(
                  value: '${profile.stats.appearances}',
                  label: '俱乐部出场',
                ),
                MetricTile(value: '${profile.stats.goals}', label: '生涯进球'),
                MetricTile(
                  value: '${profile.stats.championships.length}',
                  label: '冠军数量',
                ),
              ],
            ),
            const SizedBox(height: 18),
            _CareerTimeline(profile: profile),
            const SizedBox(height: 18),
            _HonorsPanel(profile: profile),
            const SizedBox(height: 18),
            _StoryPanel(
              client: _storyClient,
              story: _story,
              error: _storyError,
              onRetry: _loadStory,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              icon: const Icon(Icons.home_outlined),
              label: const Text('返回首页'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DossierHeader extends StatelessWidget {
  const _DossierHeader({required this.profile});

  final PlayerProfile profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.navy,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('Final dossier', light: true),
            const SizedBox(height: 10),
            Text(
              profile.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${profile.nationality} · ${profile.primaryPosition} · ${profile.heightCm} cm',
              style: const TextStyle(color: Color(0xFFB7C8D0), fontSize: 15),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                InfoTag(profile.preferredFoot, icon: Icons.directions_run),
                InfoTag(profile.playStyle, icon: Icons.bolt),
                InfoTag('${profile.debutAge} 岁首秀', icon: Icons.flag_outlined),
                InfoTag(
                  '${profile.retirementAge} 岁退役',
                  icon: Icons.sports_score,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CareerTimeline extends StatelessWidget {
  const _CareerTimeline({required this.profile});

  final PlayerProfile profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('Career timeline'),
            const SizedBox(height: 6),
            Text('职业生涯轨迹', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 18),
            for (var index = 0; index < profile.career.length; index++)
              _TimelineRow(
                chapter: profile.career[index],
                isLast: index == profile.career.length - 1,
              ),
          ],
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.chapter, required this.isLast});

  final CareerChapter chapter;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 42,
            child: Column(
              children: [
                Container(
                  width: 13,
                  height: 13,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: AppColors.line)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${chapter.age} 岁 · ${chapter.club}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${chapter.event} · 能力 ${chapter.rating}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HonorsPanel extends StatelessWidget {
  const _HonorsPanel({required this.profile});

  final PlayerProfile profile;

  @override
  Widget build(BuildContext context) {
    final honors = [
      ...profile.stats.championships,
      ...profile.stats.personalHonors,
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('Honors & records'),
            const SizedBox(height: 6),
            Text('荣誉与纪录', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: honors.isEmpty
                  ? const [InfoTag('没有冠军，但留下了完整职业生涯')]
                  : honors.map((honor) => InfoTag(honor)).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              '国家队 ${profile.stats.nationalCaps} 场 / ${profile.stats.nationalGoals} 球　'
              '转会 ${profile.stats.transferCount} 次 / 累计 €${profile.stats.totalTransferFeeMillions}M',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryPanel extends StatelessWidget {
  const _StoryPanel({
    required this.client,
    required this.story,
    required this.error,
    required this.onRetry,
  });

  final StoryApiClient client;
  final String? story;
  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: SectionLabel('Generated story')),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: client.usesDemo
                        ? const Color(0xFFFFF3D6)
                        : const Color(0xFFE4F5EE),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    client.usesDemo ? '本地示例' : 'API',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('球员故事', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 14),
            if (story == null && error == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (error != null) ...[
              Text(
                '$error',
                style: const TextStyle(color: AppColors.danger, height: 1.5),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('重新生成'),
              ),
            ] else
              SelectableText(
                story!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
          ],
        ),
      ),
    );
  }
}
