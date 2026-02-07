import 'package:flutter/material.dart';
import '../../data/mock_data.dart';

class ModelManagerScreen extends StatelessWidget {
  const ModelManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Local Models')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Downloaded section
          Text(
            'Downloaded',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          ...MockData.localModels
              .where((m) => m.status == 'ready')
              .map((m) => _ModelCard(model: m, isDownloaded: true)),

          const SizedBox(height: 16),
          Text(
            'Available',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          ...MockData.localModels
              .where((m) => m.status != 'ready')
              .map((m) => _ModelCard(model: m, isDownloaded: false)),

          const SizedBox(height: 16),

          // Import button
          Card(
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              leading: const Icon(Icons.folder_open),
              title: const Text('Import Local Model File'),
              subtitle: const Text('GGUF format supported'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),

          const SizedBox(height: 16),

          // Storage indicator
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Storage',
                      style: Theme.of(context).textTheme.bodySmall),
                  Text('1.8 GB / 32 GB used',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: 0.056,
                backgroundColor: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 4),
              Text('5.6%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      )),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  final AIModel model;
  final bool isDownloaded;
  const _ModelCard({required this.model, required this.isDownloaded});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isDownloaded ? '✅' : model.status == 'gated' ? '🔒' : '⬇️',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${model.params} · ${model.quant} · ${model.size}',
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isDownloaded) ...[
              const SizedBox(height: 4),
              Text(
                'Last used: ${model.lastUsed ?? "Never"}',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Configure'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(foregroundColor: cs.error),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 8),
              if (model.status == 'gated')
                FilledButton(
                  onPressed: () {},
                  child: const Text('Login to Download'),
                )
              else
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
