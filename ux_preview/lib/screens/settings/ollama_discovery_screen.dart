import 'package:flutter/material.dart';

class OllamaDiscoveryScreen extends StatefulWidget {
  const OllamaDiscoveryScreen({super.key});

  @override
  State<OllamaDiscoveryScreen> createState() => _OllamaDiscoveryScreenState();
}

class _OllamaDiscoveryScreenState extends State<OllamaDiscoveryScreen> {
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ollama Servers'),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.stop : Icons.radar),
            tooltip: _isScanning ? 'Stop Scanning' : 'Scan LAN',
            onPressed: () {
              setState(() => _isScanning = !_isScanning);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Scan indicator
          if (_isScanning)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scanning local network...',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          'Probing port 11434 on 192.168.1.0/24',
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onPrimaryContainer.withAlpha(180),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Connected servers
          Text(
            'Connected Servers',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          _ServerCard(
            name: 'Desktop PC',
            host: '192.168.1.42',
            port: 11434,
            isOnline: true,
            isDiscovered: true,
            models: ['llama3:8b', 'mistral:7b', 'codellama:13b'],
            cs: cs,
          ),

          const SizedBox(height: 16),

          // Discovered (offline)
          Text(
            'Previously Seen',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          _ServerCard(
            name: 'Work Laptop',
            host: '192.168.1.105',
            port: 11434,
            isOnline: false,
            isDiscovered: true,
            models: ['llama3:8b'],
            cs: cs,
          ),

          const SizedBox(height: 16),

          // Add manually
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Server Manually',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Hostname or IP',
                            prefixIcon: const Icon(Icons.dns, size: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '11434',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {},
                        child: const Text('Connect'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Info box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: cs.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(
                      'About Ollama',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Ollama runs AI models on your own hardware. '
                  'Install it on any computer, then connect from Gemmie. '
                  'No API key needed — your data stays on your network.',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
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

class _ServerCard extends StatelessWidget {
  final String name, host;
  final int port;
  final bool isOnline, isDiscovered;
  final List<String> models;
  final ColorScheme cs;

  const _ServerCard({
    required this.name,
    required this.host,
    required this.port,
    required this.isOnline,
    required this.isDiscovered,
    required this.models,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isOnline ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                if (isDiscovered)
                  Chip(
                    label: const Text('Auto-discovered'),
                    labelStyle: const TextStyle(fontSize: 10),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide(color: cs.outlineVariant),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$host:$port',
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'monospace',
                color: cs.onSurfaceVariant,
              ),
            ),
            if (isOnline) ...[
              const SizedBox(height: 12),
              Text(
                'Available Models (${models.length})',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: models
                    .map((m) => Chip(
                          label: Text(m, style: const TextStyle(fontSize: 12)),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Pull Model'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Health Check'),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: cs.error),
                    onPressed: () {},
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                'Offline · Last seen 2 days ago',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
