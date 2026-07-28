import 'package:flutter/material.dart';

import '../domain/app_settings.dart';
import '../l10n/app_localizations.dart';
import '../services/story_api_client.dart';
import '../services/story_transport.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_scope.dart';
import 'saved_players_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.storyTransport});

  final StoryTransport? storyTransport;

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
  var _testing = false;
  var _obscureToken = true;
  var _autoSave = false;
  var _language = AppLanguage.zhHans;
  var _provider = StoryApiProvider.openAi;
  StoryConnectionResult? _connectionResult;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final settings = AppScope.of(context).settings;
    _endpointController.text = settings.apiEndpoint;
    _tokenController.text = settings.apiToken;
    _provider = settings.apiProvider;
    _modelController.text = settings.apiModel.trim().isEmpty
        ? settings.apiProvider.defaultModel
        : settings.apiModel;
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
        apiProvider: _provider,
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

  void _providerChanged(StoryApiProvider provider) {
    final previous = _provider;
    final endpoint = _endpointController.text.trim();
    final model = _modelController.text.trim();
    setState(() {
      _provider = provider;
      if (endpoint == previous.defaultEndpoint) {
        _endpointController.clear();
      }
      if (model.isEmpty || model == previous.defaultModel) {
        _modelController.text = provider.defaultModel;
      }
      _connectionResult = null;
    });
  }

  void _configurationChanged() {
    setState(() => _connectionResult = null);
  }

  Future<void> _testConnection() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _testing = true;
      _connectionResult = null;
    });
    final result = await StoryApiClient(
      provider: _provider,
      endpoint: _endpointController.text.trim(),
      token: _tokenController.text.trim(),
      model: _modelController.text.trim(),
      language: _language == AppLanguage.en ? 'en' : 'zh-CN',
      transport: widget.storyTransport,
    ).testConnection();
    if (!mounted) return;
    setState(() {
      _testing = false;
      _connectionResult = result;
    });
  }

  String _providerDescription(StoryApiProvider provider) => switch (provider) {
    StoryApiProvider.openAi => context.tr(
      'OpenAI Chat Completions 格式',
      'OpenAI Chat Completions format',
    ),
    StoryApiProvider.anthropic => context.tr(
      'Anthropic Messages API 格式',
      'Anthropic Messages API format',
    ),
    StoryApiProvider.deepSeek => context.tr(
      'DeepSeek Chat Completions 与思考模式',
      'DeepSeek Chat Completions with thinking mode',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final hasApiKey = _tokenController.text.trim().isNotEmpty;
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
                status: !hasApiKey
                    ? context.tr('本地示例', 'Local demo')
                    : _connectionResult?.isSuccess == true
                    ? context.tr('连接正常', 'Connected')
                    : context.tr('等待测试', 'Not tested'),
                child: Column(
                  children: [
                    DropdownButtonFormField<StoryApiProvider>(
                      value: _provider,
                      decoration: InputDecoration(
                        labelText: context.tr('API 供应商', 'API provider'),
                        helperText: _providerDescription(_provider),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: StoryApiProvider.openAi,
                          child: Text('OpenAI'),
                        ),
                        DropdownMenuItem(
                          value: StoryApiProvider.anthropic,
                          child: Text('Anthropic'),
                        ),
                        DropdownMenuItem(
                          value: StoryApiProvider.deepSeek,
                          child: Text('DeepSeek'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) _providerChanged(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _endpointController,
                      decoration: InputDecoration(
                        labelText: context.tr(
                          '自定义 API 地址（可选）',
                          'Custom API endpoint (optional)',
                        ),
                        hintText: _provider.defaultEndpoint,
                        helperText: context.tr(
                          '留空时使用当前供应商的官方地址。',
                          'Leave blank to use the provider’s official endpoint.',
                        ),
                      ),
                      keyboardType: TextInputType.url,
                      validator: _validateEndpoint,
                      onChanged: (_) => _configurationChanged(),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _tokenController,
                      obscureText: _obscureToken,
                      decoration: InputDecoration(
                        labelText: context.tr('API 密钥', 'API key'),
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
                      onChanged: (_) => _configurationChanged(),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _modelController,
                      decoration: InputDecoration(
                        labelText: context.tr('模型名称', 'Model name'),
                        hintText: _provider == StoryApiProvider.openAi
                            ? context.tr(
                                '填写当前账户可用的 OpenAI 模型',
                                'Enter an OpenAI model available to your account',
                              )
                            : _provider.defaultModel,
                      ),
                      onChanged: (_) => _configurationChanged(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _testing ? null : _testConnection,
                        icon: _testing
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.cable_outlined),
                        label: Text(
                          _testing
                              ? context.tr('正在测试…', 'Testing…')
                              : context.tr('测试连接', 'Test connection'),
                        ),
                      ),
                    ),
                    if (_connectionResult != null) ...[
                      const SizedBox(height: 12),
                      _ConnectionResultCard(result: _connectionResult!),
                    ],
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
                                '测试会发送一次极短请求，可能产生少量费用。密钥会以普通本地偏好保存，并非安全密钥库；正式发布时请使用自有后端代理。',
                                'The test sends one very short request and may incur a small charge. The key is stored as a normal local preference, not a secure vault; use your own backend proxy in production.',
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

class _ConnectionResultCard extends StatelessWidget {
  const _ConnectionResultCard({required this.result});

  final StoryConnectionResult result;

  @override
  Widget build(BuildContext context) {
    final success = result.isSuccess;
    final color = success ? AppColors.pitchDark : AppColors.danger;
    final background = success
        ? const Color(0xFFE6F5EF)
        : const Color(0xFFFFECE8);
    final milliseconds = result.elapsed.inMilliseconds;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            success ? Icons.check_circle_outline : Icons.error_outline,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${result.message}${milliseconds > 0 ? ' · $milliseconds ms' : ''}',
              style: TextStyle(color: color, fontSize: 12, height: 1.5),
            ),
          ),
        ],
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
