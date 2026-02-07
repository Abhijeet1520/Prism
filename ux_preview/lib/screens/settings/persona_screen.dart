import 'package:flutter/material.dart';
import '../../data/mock_data.dart';

class PersonaScreen extends StatelessWidget {
  const PersonaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Agent Persona')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Active persona selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('Active Persona: '),
                  const Spacer(),
                  DropdownButton<String>(
                    value: 'Default',
                    items: const [
                      DropdownMenuItem(value: 'Default', child: Text('Default')),
                      DropdownMenuItem(value: 'Work', child: Text('Work')),
                      DropdownMenuItem(value: 'Creative', child: Text('Creative')),
                    ],
                    onChanged: (_) {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Persona files
          Text(
            'Persona Files',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: MockData.personaFiles.asMap().entries.map((entry) {
                final file = entry.value;
                final isLast = entry.key == MockData.personaFiles.length - 1;
                return Column(
                  children: [
                    ListTile(
                      leading: Text(file.icon, style: const TextStyle(fontSize: 24)),
                      title: Text(file.name,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(file.summary),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showPersonaFileEditor(context, file),
                    ),
                    if (!isLast) const Divider(height: 1, indent: 56),
                  ],
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Quick Preview
          Card(
            color: cs.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick Preview',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text(
                    '"Hi! I\'m Gemmie. I keep things concise and casual. I\'ll ask before touching your files."',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Personality sliders
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Personality Tuning',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 16),
                  _PersonalitySlider('Tone', 'Formal', 'Casual', 0.7, cs),
                  _PersonalitySlider('Verbosity', 'Concise', 'Verbose', 0.3, cs),
                  _PersonalitySlider('Humor', 'Serious', 'Humorous', 0.5, cs),
                  _PersonalitySlider('Empathy', 'Neutral', 'Empathetic', 0.6, cs),
                  _PersonalitySlider('Creativity', 'Factual', 'Creative', 0.4, cs),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('New Persona'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.refresh),
                label: const Text('Reset Default'),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showPersonaFileEditor(BuildContext context, PersonaFile file) {
    final cs = Theme.of(context).colorScheme;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text('${file.icon} ${file.name}'),
            actions: [
              IconButton(icon: const Icon(Icons.save), onPressed: () {}),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.tertiaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock, size: 16, color: cs.onTertiaryContainer),
                      const SizedBox(width: 8),
                      Text(
                        '🔐 1 pending AI change request',
                        style: TextStyle(color: cs.onTertiaryContainer),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Review →'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TextField(
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: 'Edit ${file.name.toLowerCase()} content...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: cs.surfaceContainerLow,
                    ),
                    controller: TextEditingController(
                      text: _sampleContent(file.name),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _sampleContent(String name) {
    switch (name) {
      case 'Soul':
        return '''# Soul

You are Gemmie, an AI personal assistant.

## Core Values
- Be helpful, honest, and harmless
- Respect user privacy — never access files without permission
- Be transparent about capabilities and limitations
- Ask clarifying questions rather than making assumptions

## Identity
- Name: Gemmie
- Created by: User
- Purpose: Personal productivity assistant''';
      case 'Rules':
        return '''# Rules

1. Never access files marked as 🔒 Locked
2. Always ask before modifying 🔐 Gated files
3. Never share conversation data externally
4. Keep responses concise unless asked for detail
5. Always show code diffs before applying changes
6. Warn before destructive operations
7. Respect the user's timezone for scheduling
8. Log all tool invocations for transparency''';
      default:
        return '# $name\n\nEdit this content...';
    }
  }
}

class _PersonalitySlider extends StatelessWidget {
  final String label, leftLabel, rightLabel;
  final double value;
  final ColorScheme cs;

  const _PersonalitySlider(
      this.label, this.leftLabel, this.rightLabel, this.value, this.cs);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(leftLabel,
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
              Expanded(
                child: Slider(
                  value: value,
                  onChanged: (_) {},
                ),
              ),
              Text(rightLabel,
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}
