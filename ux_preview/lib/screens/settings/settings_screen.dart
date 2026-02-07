import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import 'providers_screen.dart';
import 'persona_screen.dart';
import 'model_manager_screen.dart';
import 'ollama_discovery_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('⚙ Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile card
          Card(
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              leading: CircleAvatar(
                backgroundColor: cs.primaryContainer,
                child: const Text('A', style: TextStyle(fontSize: 20)),
              ),
              title: const Text('Abhij',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('abhij@email.com'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),

          const SizedBox(height: 16),
          _sectionTitle('AI Configuration', context),
          Card(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.smart_toy,
                  title: 'AI Providers',
                  subtitle: '${MockData.providers.where((p) => p.status == "connected").length} connected',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProvidersScreen()),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.download,
                  title: 'Local Models',
                  subtitle: '1 downloaded · 1.8 GB',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ModelManagerScreen()),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.dns_outlined,
                  title: 'Ollama Servers',
                  subtitle: '1 server connected',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const OllamaDiscoveryScreen()),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.theater_comedy,
                  title: 'Agent Persona',
                  subtitle: 'Default',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PersonaScreen()),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          _sectionTitle('App Settings', context),
          Card(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.palette,
                  title: 'Theme & Appearance',
                  subtitle: 'System default',
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Permissions Overview',
                  subtitle: '3 active grants',
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.storage,
                  title: 'Storage Management',
                  subtitle: '1.8 GB / 32 GB used',
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.cloud_outlined,
                  title: 'Sync Settings',
                  subtitle: 'Supabase · Not configured',
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          _sectionTitle('About', context),
          Card(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.security,
                  title: 'Privacy & Data',
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Licenses',
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: 'About Gemmie',
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Center(
            child: Text(
              'App v0.1.0 · Made with 💚',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

Widget _sectionTitle(String title, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    ),
  );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
