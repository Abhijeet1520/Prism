import 'package:flutter/material.dart';
import '../../data/mock_data.dart';

class ProvidersScreen extends StatelessWidget {
  const ProvidersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('AI Providers')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...MockData.providers.map((provider) {
            final isConnected = provider.status == 'connected';
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          provider.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isConnected
                                ? Colors.green.withAlpha(30)
                                : cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isConnected ? '✅ Connected' : '⬜ Not configured',
                            style: TextStyle(
                              fontSize: 12,
                              color: isConnected
                                  ? Colors.green.shade700
                                  : cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (provider.isKeyless)
                      Text(
                        '🌐 No API key required',
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                        ),
                      )
                    else if (isConnected)
                      Row(
                        children: [
                          Icon(Icons.key, size: 14, color: cs.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            provider.keyMasked ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'monospace',
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        'Tap to configure',
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    if (isConnected) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: () {},
                            child: const Text('Edit'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () {},
                            child: const Text('Test'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: cs.error,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () {},
                        child: const Text('+ Add Key'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Add Custom Provider'),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.lock, size: 16, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'All keys are stored encrypted in your device\'s secure keystore.',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
