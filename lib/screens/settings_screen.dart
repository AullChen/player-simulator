import 'package:flutter/material.dart';

import '../domain/app_settings.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_scope.dart';
import 'saved_players_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _endpointController = TextEditingController();
  final _tokenController = TextEditingController();
  final _modelController = TextEditingController();
  var _initialized = false;
  var _saving = false;
  var _obscureToken = true;
  var _autoSave = false;
  var _language = AppLanguage.zhHans;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final settings = AppScope.of(context).settings;
    _endpointController.text = settings.apiEndpoint;
    _tokenController.text = settings.apiToken;
    _modelController.text = settings.apiModel;
    _autoSave = settings.autoSavePlayers;
    _language = settings.language;
    _initialized = true;
  }

  @override
  void dispose() {
    _endpointController.dispose();
    _tokenController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  String? _validateEndpoint(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      return context.tr(
        '请输入完整的 HTTP 或 HTTPS 地址',
        'Enter a complete HTTP or HTTPS URL',
      );
    }
    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final controller = AppScope.of(context);
    await controller.updateSettings(
      AppSettings(
        language: _language,
        apiEndpoint: _endpointController.text.trim(),
        apiToken: _tokenController.text.trim(),
        apiModel: _modelController.text.trim(),
        autoSavePlayers: _autoSave,
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('设置已保存', 'Settings saved'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return AppScaffold(
      title: context.tr('设置', 'Settings'),
      child: ContentWidth(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionLabel('Control room'),
              const SizedBox(height: 8),
              Text(
                context.tr('控制你的档案室', 'Control your dossier room'),
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                context.tr(
                  '语言、故事服务与本地球员都保存在这台设备上。',
                  'Language, story service, and saved players stay on this device.',
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 22),
              _SettingsSection(
                icon: Icons.translate,
                title: context.tr('语言', 'Language'),
                status: _language == AppLanguage.en ? 'English' : '简体中文',
                child: DropdownButtonFormField<AppLanguage>(
                  value: _language,
                  decoration: InputDecoration(
                    labelText: context.tr('界面语言', 'Interface language'),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: AppLanguage.zhHans,
                      child: Text('简体中文'),
                    ),
                    DropdownMenuItem(
                      value: AppLanguage.en,
                      child: Text('English'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _language = value);
                  },
                ),
              ),
              const SizedBox(height: 14),
              _SettingsSection(
                icon: Icons.hub_outlined,
                title: context.tr('故事 API', 'Story API'),
                status: _endpointController.text.trim().isEmpty
                    ? context.tr('本地示例', 'Local demo')
                    : context.tr('远程服务', 'Remote service'),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _endpointController,
                      decoration: InputDecoration(
                        labelText: context.tr('API 地址', 'API endpoint'),
                        hintText: 'https://api.example.com/player-story',
                      ),
                      keyboardType: TextInputType.url,
                      validator: _validateEndpoint,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _tokenController,
                      obscureText: _obscureToken,
                      decoration: InputDecoration(
                        labelText: context.tr('访问令牌', 'Access token'),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscureToken = !_obscureToken),
                          icon: Icon(
                            _obscureToken
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _modelController,
                      decoration: InputDecoration(
                        labelText: context.tr(
                          '模型名（可选）',
                          'Model name (optional)',
                        ),
                        hintText: 'your-model-id',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF5DD),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            color: Color(0xFF8B6424),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              context.tr(
                                '令牌会以普通本地偏好保存，不是安全密钥库。正式发布时请使用自有后端代理。',
                                'The token is stored as a normal local preference, not in a secure vault. Use your own backend proxy in production.',
                              ),
                              style: const TextStyle(
                                color: Color(0xFF76551F),
                                fontSize: 12,
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
              const SizedBox(height: 14),
              _SettingsSection(
                icon: Icons.inventory_2_outlined,
                title: context.tr('本地档案', 'Local dossiers'),
                status: context.tr(
                  '${controller.savedPlayers.length} 名球员',
                  '${controller.savedPlayers.length} players',
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      value: _autoSave,
                      contentPadding: EdgeInsets.zero,
                      title: Text(context.tr('自动保存最终档案', 'Auto-save dossiers')),
                      subtitle: Text(
                        context.tr(
                          '相同档案不会重复保存，最多保留 50 名球员。',
                          'Duplicate dossiers are skipped; up to 50 players are kept.',
                        ),
                      ),
                      onChanged: (value) => setState(() => _autoSave = value),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const SavedPlayersScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.folder_open_outlined),
                        label: Text(
                          context.tr('打开已保存球员', 'Open saved players'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(
                  _saving
                      ? context.tr('保存中…', 'Saving…')
                      : context.tr('保存设置', 'Save settings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.icon,
    required this.title,
    required this.status,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String status;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.mist,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.pitchDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F5EF),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: AppColors.pitchDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}
