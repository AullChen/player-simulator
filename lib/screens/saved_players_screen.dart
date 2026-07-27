import 'package:flutter/material.dart';

import '../domain/saved_player.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_scope.dart';
import 'result_screen.dart';

class SavedPlayersScreen extends StatelessWidget {
  const SavedPlayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return AppScaffold(
      title: context.tr('已保存球员', 'Saved players'),
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          final players = controller.savedPlayers;
          return ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionLabel('Dossier archive'),
                const SizedBox(height: 8),
                Text(
                  context.tr('你的球员档案柜', 'Your player archive'),
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr(
                    '档案保存在本机。打开后可以重新生成故事或查看完整生涯。',
                    'Dossiers stay on this device. Open one to revisit the career or regenerate its story.',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 22),
                if (players.isEmpty)
                  _EmptyArchive()
                else
                  for (final player in players) ...[
                    _SavedPlayerCard(player: player),
                    const SizedBox(height: 10),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyArchive extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: AppColors.muted,
            ),
            const SizedBox(height: 14),
            Text(
              context.tr('还没有保存球员', 'No saved players yet'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              context.tr(
                '完成任意模式后，在最终档案页点击保存。',
                'Finish any mode and save the player from the final dossier.',
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

class _SavedPlayerCard extends StatelessWidget {
  const _SavedPlayerCard({required this.player});

  final SavedPlayer player;

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('删除这份档案？', 'Delete this dossier?')),
        content: Text(
          context.tr(
            '“${player.profile.name}”将从本机档案柜移除。',
            '“${player.profile.name}” will be removed from this device.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.tr('取消', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.tr('删除', 'Delete')),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await AppScope.of(context).deletePlayer(player.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = player.savedAt;
    final savedDate =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ResultScreen(profile: player.profile),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '${player.profile.peakRating}',
                  style: const TextStyle(
                    color: AppColors.gold,
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
                      player.profile.name,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${player.profile.nationality} · '
                      '${player.profile.primaryPosition} · $savedDate',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _delete(context),
                tooltip: context.tr('删除档案', 'Delete dossier'),
                icon: const Icon(Icons.delete_outline),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
