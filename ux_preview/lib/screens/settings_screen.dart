import 'package:shadcn_flutter/shadcn_flutter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _section = 0;

  final _sections = const [
    'General',
    'Appearance',
    'Providers',
    'Inference',
    'Privacy',
    'Sync',
    'Notifications',
    'About',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(title: const Text('Settings')),
      ],
      child: Row(
        children: [
          // Settings sidebar
          SizedBox(
            width: 220,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < _sections.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Button(
                        style: _section == i
                            ? const ButtonStyle.secondary(density: ButtonDensity.comfortable)
                            : const ButtonStyle.ghost(density: ButtonDensity.comfortable),
                        onPressed: () => setState(() => _section = i),
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(_sections[i]),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const VerticalDivider(),
          // Settings content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildSection(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection() {
    return switch (_section) {
      0 => _buildGeneral(),
      1 => _buildAppearance(),
      2 => _buildProviders(),
      3 => _buildInference(),
      4 => _buildPrivacy(),
      5 => _buildSync(),
      6 => _buildNotifications(),
      7 => _buildAbout(),
      _ => const SizedBox(),
    };
  }

  Widget _buildGeneral() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('General', 'Basic application preferences'),
        _settingRow(
          'Default Persona',
          'The AI persona used for new conversations',
          child: SizedBox(
            width: 200,
            child: Select<String>(
              value: 'Helpful Assistant',
              onChanged: (_) {},
              itemBuilder: (context, item) => Text(item),
              popupConstraints: const BoxConstraints(maxHeight: 200),
              popup: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final p in ['Helpful Assistant', 'Code Expert', 'Creative Writer', 'Researcher'])
                    SelectItemButton(value: p, child: Text(p)),
                ],
              ),
            ),
          ),
        ),
        _settingRow(
          'Default Model',
          'The model used when starting new conversations',
          child: SizedBox(
            width: 200,
            child: Select<String>(
              value: 'gemma-3n-e4b',
              onChanged: (_) {},
              itemBuilder: (context, item) => Text(item),
              popupConstraints: const BoxConstraints(maxHeight: 200),
              popup: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final m in ['gemma-3n-e4b', 'gpt-4o', 'claude-3.5-sonnet', 'mistral-7b', 'llama-3.1-8b'])
                    SelectItemButton(value: m, child: Text(m)),
                ],
              ),
            ),
          ),
        ),
        _settingRow(
          'Send with Enter',
          'Press Enter to send messages (Shift+Enter for new line)',
          child: Switch(value: true, onChanged: (_) {}),
        ),
        _settingRow(
          'Stream Responses',
          'Show AI responses as they are generated',
          child: Switch(value: true, onChanged: (_) {}),
        ),
      ],
    );
  }

  Widget _buildAppearance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Appearance', 'Customize the look and feel'),
        _settingRow(
          'Theme',
          'Choose between light, dark, or system theme',
          child: SizedBox(
            width: 150,
            child: Select<String>(
              value: 'System',
              onChanged: (_) {},
              itemBuilder: (context, item) => Text(item),
              popupConstraints: const BoxConstraints(maxHeight: 200),
              popup: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final t in ['Light', 'Dark', 'System'])
                    SelectItemButton(value: t, child: Text(t)),
                ],
              ),
            ),
          ),
        ),
        _settingRow(
          'Color Scheme',
          'Primary color accent for the UI',
          child: SizedBox(
            width: 150,
            child: Select<String>(
              value: 'Zinc',
              onChanged: (_) {},
              itemBuilder: (context, item) => Text(item),
              popupConstraints: const BoxConstraints(maxHeight: 200),
              popup: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final c in ['Zinc', 'Slate', 'Blue', 'Green', 'Orange', 'Rose'])
                    SelectItemButton(value: c, child: Text(c)),
                ],
              ),
            ),
          ),
        ),
        _settingRow(
          'Font Size',
          'Adjust the base font size',
          child: SizedBox(
            width: 150,
            child: Select<String>(
              value: 'Medium',
              onChanged: (_) {},
              itemBuilder: (context, item) => Text(item),
              popupConstraints: const BoxConstraints(maxHeight: 200),
              popup: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final s in ['Small', 'Medium', 'Large'])
                    SelectItemButton(value: s, child: Text(s)),
                ],
              ),
            ),
          ),
        ),
        _settingRow(
          'Compact Mode',
          'Reduce spacing and padding throughout the UI',
          child: Switch(value: false, onChanged: (_) {}),
        ),
      ],
    );
  }

  Widget _buildProviders() {
    final providers = [
      ('Ollama', 'Local LAN', 'http://localhost:11434', true),
      ('llama.cpp', 'On-device GGUF', 'Local FFI', true),
      ('OpenAI', 'Cloud API', 'https://api.openai.com', false),
      ('Anthropic', 'Cloud API', 'https://api.anthropic.com', false),
      ('Google AI', 'Cloud API', 'https://generativelanguage.googleapis.com', false),
      ('Mistral', 'Cloud API', 'https://api.mistral.ai', false),
      ('OpenRouter', 'Cloud Aggregator', 'https://openrouter.ai', false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('AI Providers', 'Configure AI model providers and API keys'),
        for (final (name, type, endpoint, connected) in providers)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(width: 8),
                            connected
                                ? const PrimaryBadge(child: Text('Connected'))
                                : const OutlineBadge(child: Text('Not configured')),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('$type • $endpoint', style: const TextStyle(fontSize: 12, color: Colors.gray)),
                      ],
                    ),
                  ),
                  Button.secondary(
                    onPressed: () {},
                    child: const Text('Configure'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInference() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Inference', 'Default parameters for AI generation'),
        _settingRow(
          'Temperature',
          'Controls randomness (0.0 = deterministic, 2.0 = creative)',
          child: SizedBox(width: 200, child: Slider(value: const SliderValue.single(0.7), onChanged: (_) {})),
        ),
        _settingRow(
          'Max Tokens',
          'Maximum output length for responses',
          child: const SizedBox(width: 120, child: TextField(initialValue: '4096')),
        ),
        _settingRow(
          'Top P',
          'Nucleus sampling threshold',
          child: SizedBox(width: 200, child: Slider(value: const SliderValue.single(0.9), onChanged: (_) {})),
        ),
        _settingRow(
          'System Prompt',
          'Default system prompt appended to all conversations',
          child: const SizedBox(
            width: 400,
            child: TextField(
              initialValue: 'You are Prism, a helpful AI assistant.',
              maxLines: 3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Privacy & Security', 'Control your data and privacy settings'),
        _settingRow(
          'Local-Only Mode',
          'Only use on-device models (no cloud API calls)',
          child: Switch(value: false, onChanged: (_) {}),
        ),
        _settingRow(
          'Encrypt Database',
          'Encrypt the local SQLite database with a passphrase',
          child: Switch(value: true, onChanged: (_) {}),
        ),
        _settingRow(
          'Telemetry',
          'Send anonymous usage statistics to help improve Prism',
          child: Switch(value: false, onChanged: (_) {}),
        ),
        _settingRow(
          'Auto-delete History',
          'Automatically delete conversations older than',
          child: SizedBox(
            width: 150,
            child: Select<String>(
              value: 'Never',
              onChanged: (_) {},
              itemBuilder: (context, item) => Text(item),
              popupConstraints: const BoxConstraints(maxHeight: 200),
              popup: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final d in ['Never', '30 days', '90 days', '1 year'])
                    SelectItemButton(value: d, child: Text(d)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Button.destructive(
          leading: const Icon(RadixIcons.trash),
          onPressed: () {},
          child: const Text('Delete All Data'),
        ),
      ],
    );
  }

  Widget _buildSync() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Cloud Sync', 'Sync data across devices with Supabase'),
        _settingRow(
          'Enable Sync',
          'Synchronize conversations, notes, and settings',
          child: Switch(value: false, onChanged: (_) {}),
        ),
        _settingRow(
          'Supabase URL',
          'Your Supabase project URL',
          child: const SizedBox(width: 300, child: TextField(placeholder: Text('https://xxx.supabase.co'))),
        ),
        _settingRow(
          'Sync Frequency',
          'How often to sync data',
          child: SizedBox(
            width: 150,
            child: Select<String>(
              value: 'Real-time',
              onChanged: (_) {},
              itemBuilder: (context, item) => Text(item),
              popupConstraints: const BoxConstraints(maxHeight: 200),
              popup: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final f in ['Real-time', 'Every 5 min', 'Every 15 min', 'Manual'])
                    SelectItemButton(value: f, child: Text(f)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotifications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Smart Notifications', 'AI-powered notification management'),
        _settingRow(
          'Notification Listener',
          'Allow Prism to read device notifications (Android)',
          child: Switch(value: false, onChanged: (_) {}),
        ),
        _settingRow(
          'Financial Capture',
          'Auto-detect payment notifications and log transactions',
          child: Switch(value: true, onChanged: (_) {}),
        ),
        _settingRow(
          'Task Reminders',
          'Intelligent reminders based on task deadlines',
          child: Switch(value: true, onChanged: (_) {}),
        ),
        _settingRow(
          'Procrastination Alerts',
          'Gentle nudges when tasks are overdue',
          child: Switch(value: false, onChanged: (_) {}),
        ),
      ],
    );
  }

  Widget _buildAbout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('About Prism', 'Application information'),
        Card(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Prism', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('The central hub for your intelligence', style: TextStyle(color: Theme.of(context).colorScheme.mutedForeground)),
              const SizedBox(height: 16),
              for (final (label, value) in [
                ('Version', '0.1.0-dev'),
                ('Flutter', '3.32.x'),
                ('Dart', '3.8.x'),
                ('License', 'AGPL-3.0'),
                ('Database', 'Drift (SQLite)'),
                ('UI Framework', 'shadcn/ui for Flutter'),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
                      Text(value, style: const TextStyle(color: Colors.gray)),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Button.outline(
                    leading: const Icon(RadixIcons.githubLogo),
                    onPressed: () {},
                    child: const Text('GitHub'),
                  ),
                  const SizedBox(width: 8),
                  Button.outline(
                    leading: const Icon(RadixIcons.file),
                    onPressed: () {},
                    child: const Text('Licenses'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.mutedForeground)),
          const SizedBox(height: 12),
          const Divider(),
        ],
      ),
    );
  }

  Widget _settingRow(String title, String description, {required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.mutedForeground)),
              ],
            ),
          ),
          const SizedBox(width: 24),
          child,
        ],
      ),
    );
  }
}
