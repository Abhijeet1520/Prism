import 'package:flutter/material.dart';
import '../../../data/mock_data.dart';

class ModelSelectorSheet extends StatelessWidget {
  const ModelSelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Model',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Local models section
                  _SectionHeader('Local Models', cs),
                  ...MockData.localModels.map(
                    (m) => _ModelTile(
                      model: m,
                      subtitle: '${m.params} params · ${m.quant} · ${m.size}',
                      trailing: m.status == 'ready'
                          ? Icon(Icons.check_circle, color: cs.primary, size: 20)
                          : m.status == 'gated'
                              ? Icon(Icons.lock, color: cs.error, size: 20)
                              : OutlinedButton(
                                  onPressed: () {},
                                  child: const Text('Download'),
                                ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ollama section
                  _SectionHeader('Ollama Servers', cs),
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Desktop PC',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '192.168.1.42:11434',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        ...MockData.ollamaModels.map(
                          (m) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(Icons.radio_button_unchecked, size: 20, color: cs.onSurfaceVariant),
                                const SizedBox(width: 8),
                                Text(m.name),
                                const Spacer(),
                                Text(
                                  m.size,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cloud section
                  _SectionHeader('Cloud Providers', cs),
                  ...MockData.cloudModels.map(
                    (m) => _ModelTile(
                      model: m,
                      subtitle: '${m.provider} · ${m.context} context',
                      trailing: Icon(Icons.radio_button_unchecked, size: 20, color: cs.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Manage Models →'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final ColorScheme cs;
  const _SectionHeader(this.title, this.cs);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _ModelTile extends StatelessWidget {
  final AIModel model;
  final String subtitle;
  final Widget? trailing;
  const _ModelTile({required this.model, required this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(model.name, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle),
        trailing: trailing,
        onTap: () => Navigator.pop(context),
      ),
    );
  }
}
