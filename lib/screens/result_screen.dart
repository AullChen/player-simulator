import 'package:flutter/material.dart';

import '../domain/player_profile.dart';
import '../l10n/app_localizations.dart';
import '../services/story_api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_scope.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.profile, this.storyClient});

  final PlayerProfile profile;
  final StoryApiClient? storyClient;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late StoryApiClient _storyClient;
  var _initialized = false;
  var _autoSaveStarted = false;
  String? _story;
  Object? _storyError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final controller = AppScope.maybeOf(context);
    _storyClient =
        widget.storyClient ??
        controller?.createStoryClient() ??
        StoryApiClient.fromEnvironment();
    _initialized = true;
    _loadStory();
    if (controller?.settings.autoSavePlayers == true && !_autoSaveStarted) {
      _autoSaveStarted = true;
      controller!.savePlayer(widget.profile);
    }
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

  Future<void> _savePlayer() async {
    final controller = AppScope.maybeOf(context);
    if (controller == null) return;
    final added = await controller.savePlayer(widget.profile);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? context.tr('球员已保存到本地档案', 'Player saved locally')
              : context.tr('这份球员档案已经保存过', 'This dossier is already saved'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    return AppScaffold(
      title: context.tr('球员生涯档案', 'Player career dossier'),
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
                  label: context.tr('巅峰能力', 'Peak rating'),
                  emphasized: true,
                ),
                MetricTile(
                  value: '${profile.stats.appearances}',
                  label: context.tr('俱乐部出场', 'Club appearances'),
                ),
                MetricTile(
                  value: '${profile.stats.goals}',
                  label: context.tr('生涯进球', 'Career goals'),
                ),
                MetricTile(
                  value: '${profile.stats.championships.length}',
                  label: context.tr('冠军数量', 'Trophies'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _RegistrationPanel(profile: profile),
            const SizedBox(height: 18),
            _PerformancePanel(profile: profile),
            const SizedBox(height: 18),
            _TransferPanel(profile: profile),
            const SizedBox(height: 18),
            _HealthAndValuePanel(profile: profile),
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
            FilledButton.icon(
              onPressed: AppScope.maybeOf(context) == null ? null : _savePlayer,
              icon: const Icon(Icons.save_outlined),
              label: Text(context.tr('保存球员档案', 'Save player dossier')),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              icon: const Icon(Icons.home_outlined),
              label: Text(context.tr('返回首页', 'Back to home')),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegistrationPanel extends StatelessWidget {
  const _RegistrationPanel({required this.profile});

  final PlayerProfile profile;

  @override
  Widget build(BuildContext context) {
    final citizenships = profile.citizenships.isEmpty
        ? profile.nationality
        : profile.citizenships.join(' / ');
    return _DossierSection(
      label: 'Registration & contract',
      title: '注册、位置与合同',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 680
              ? 4
              : constraints.maxWidth >= 420
              ? 2
              : 1;
          const gap = 12.0;
          final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: 12,
            children: [
              _FactCell(
                width: width,
                label: '出生',
                value: '${profile.birthDate}\n${profile.birthPlace}',
              ),
              _FactCell(
                width: width,
                label: '成长协会',
                value: profile.developmentAssociation,
              ),
              _FactCell(width: width, label: '公民身份', value: citizenships),
              _FactCell(
                width: width,
                label: '身体',
                value:
                    '${profile.heightCm} cm / '
                    '${profile.weightKg == 0 ? '未记录' : '${profile.weightKg} kg'}',
              ),
              _FactCell(
                width: width,
                label: '位置与号码',
                value:
                    '${profile.primaryPosition} / ${profile.secondaryPosition}\n'
                    '${profile.shirtNumber == 0 ? '号码未记录' : '${profile.shirtNumber} 号'}',
              ),
              _FactCell(
                width: width,
                label: '最后效力',
                value: '${profile.currentClub}\n${profile.currentLeague}',
              ),
              _FactCell(
                width: width,
                label: '合同',
                value:
                    '加盟 ${profile.joinedClubDate}\n'
                    '当前合同 ${profile.contractStartDate} 起\n'
                    '到期 ${profile.contractUntil}',
              ),
              _FactCell(
                width: width,
                label: '青训与职业入口',
                value:
                    '${profile.academyEntryAge} 岁进入青训\n'
                    '${profile.debutAge} 岁完成职业首秀',
              ),
              _FactCell(width: width, label: '经纪人', value: profile.agent),
              _FactCell(
                width: width,
                label: '国家队',
                value:
                    '${profile.nationalTeam}\n'
                    '首秀 ${profile.nationalTeamDebut}',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PerformancePanel extends StatelessWidget {
  const _PerformancePanel({required this.profile});

  final PlayerProfile profile;

  @override
  Widget build(BuildContext context) {
    final stats = profile.stats;
    return _DossierSection(
      label: 'Performance record',
      title: '职业比赛数据',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoTag('${stats.starts} 次首发'),
              InfoTag('${stats.substituteAppearances} 次替补'),
              InfoTag('${_formatNumber(stats.minutesPlayed)} 分钟'),
              InfoTag('${stats.assists} 次助攻'),
              InfoTag('${stats.yellowCards} 黄牌'),
              InfoTag('${stats.secondYellowCards} 两黄变红'),
              InfoTag('${stats.redCards} 直接红牌'),
              if (stats.cleanSheets > 0) InfoTag('${stats.cleanSheets} 场零封'),
              if (stats.penaltiesScored > 0)
                InfoTag('${stats.penaltiesScored} 粒点球'),
            ],
          ),
          if (profile.competitionStats.isNotEmpty) ...[
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
                dataTextStyle: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 13,
                ),
                columns: const [
                  DataColumn(label: Text('赛事')),
                  DataColumn(label: Text('出场'), numeric: true),
                  DataColumn(label: Text('进球'), numeric: true),
                  DataColumn(label: Text('助攻'), numeric: true),
                  DataColumn(label: Text('分钟'), numeric: true),
                ],
                rows: [
                  for (final competition in profile.competitionStats)
                    DataRow(
                      cells: [
                        DataCell(Text(competition.competition)),
                        DataCell(Text('${competition.appearances}')),
                        DataCell(Text('${competition.goals}')),
                        DataCell(Text('${competition.assists}')),
                        DataCell(
                          Text(_formatNumber(competition.minutesPlayed)),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TransferPanel extends StatelessWidget {
  const _TransferPanel({required this.profile});

  final PlayerProfile profile;

  @override
  Widget build(BuildContext context) {
    return _DossierSection(
      label: 'Transfer ledger',
      title: '转会记录',
      trailing:
          '累计 €${profile.stats.totalTransferFeeMillions.toStringAsFixed(1)}M',
      child: profile.transferHistory.isEmpty
          ? const Text(
              '职业生涯没有发生俱乐部转会。',
              style: TextStyle(color: AppColors.muted),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
                dataTextStyle: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 13,
                ),
                columns: const [
                  DataColumn(label: Text('赛季')),
                  DataColumn(label: Text('年龄'), numeric: true),
                  DataColumn(label: Text('原俱乐部')),
                  DataColumn(label: Text('新俱乐部')),
                  DataColumn(label: Text('形式')),
                  DataColumn(label: Text('费用')),
                ],
                rows: [
                  for (final transfer in profile.transferHistory)
                    DataRow(
                      cells: [
                        DataCell(Text(transfer.season)),
                        DataCell(Text('${transfer.age}')),
                        DataCell(Text(transfer.fromClub)),
                        DataCell(Text(transfer.toClub)),
                        DataCell(Text(transfer.type)),
                        DataCell(
                          Text(
                            transfer.feeMillions == 0
                                ? '—'
                                : '€${transfer.feeMillions.toStringAsFixed(1)}M',
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}

class _HealthAndValuePanel extends StatelessWidget {
  const _HealthAndValuePanel({required this.profile});

  final PlayerProfile profile;

  @override
  Widget build(BuildContext context) {
    final peakValue = profile.marketValueHistory.fold<double>(
      profile.marketValueMillions,
      (highest, point) =>
          point.valueMillions > highest ? point.valueMillions : highest,
    );
    return _DossierSection(
      label: 'Availability & value',
      title: '伤病与模拟身价',
      trailing: '峰值 €${peakValue.toStringAsFixed(1)}M',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            profile.injuryRecord,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          if (profile.injuryHistory.isEmpty)
            const InfoTag('没有结构化伤停记录')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final injury in profile.injuryHistory)
                  InfoTag(
                    '${injury.season} ${injury.type} · '
                    '${injury.daysAbsent} 天 / ${injury.matchesMissed} 场',
                  ),
              ],
            ),
          if (profile.marketValueHistory.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Text(
              '年龄身价轨迹（模拟值）',
              style: TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final point in profile.marketValueHistory)
                  InfoTag(
                    '${point.age} 岁 · '
                    '€${point.valueMillions.toStringAsFixed(1)}M',
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DossierSection extends StatelessWidget {
  const _DossierSection({
    required this.label,
    required this.title,
    required this.child,
    this.trailing,
  });

  final String label;
  final String title;
  final Widget child;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionLabel(label),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                if (trailing != null)
                  Text(
                    trailing!,
                    style: const TextStyle(
                      color: AppColors.pitchDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _FactCell extends StatelessWidget {
  const _FactCell({
    required this.width,
    required this.label,
    required this.value,
  });

  final double width;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.mist,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatNumber(int value) {
  final digits = value.toString().split('');
  final output = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) output.write(',');
    output.write(digits[index]);
  }
  return output.toString();
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
                    client.usesDemo ? '本地示例' : client.providerName,
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
