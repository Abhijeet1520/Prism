import 'package:shadcn_flutter/shadcn_flutter.dart';

class GatewayScreen extends StatefulWidget {
  const GatewayScreen({super.key});

  @override
  State<GatewayScreen> createState() => _GatewayScreenState();
}

class _GatewayScreenState extends State<GatewayScreen> {
  bool _serverRunning = false;
  int _tab = 0;

  static const _tokens = [
    _GatewayToken(name: 'Development', token: 'prism_dev_a1b2c3...', created: 'Jan 1', lastUsed: 'Today', requests: 142),
    _GatewayToken(name: 'VS Code Extension', token: 'prism_vsc_d4e5f6...', created: 'Jan 3', lastUsed: 'Jan 6', requests: 87),
    _GatewayToken(name: 'CI Pipeline', token: 'prism_ci_g7h8i9...', created: 'Jan 5', lastUsed: 'Never', requests: 0),
  ];

  static const _logs = [
    _RequestLog(timestamp: '14:32:05', method: 'POST', path: '/v1/chat/completions', model: 'gemma-3n', status: 200, latency: '1.2s', tokens: 384),
    _RequestLog(timestamp: '14:31:42', method: 'POST', path: '/v1/chat/completions', model: 'gpt-4o', status: 200, latency: '2.8s', tokens: 1024),
    _RequestLog(timestamp: '14:30:18', method: 'GET', path: '/v1/models', model: '-', status: 200, latency: '12ms', tokens: 0),
    _RequestLog(timestamp: '14:28:55', method: 'POST', path: '/v1/completions', model: 'mistral-7b', status: 200, latency: '890ms', tokens: 256),
    _RequestLog(timestamp: '14:25:10', method: 'POST', path: '/v1/chat/completions', model: 'gemma-3n', status: 429, latency: '-', tokens: 0),
    _RequestLog(timestamp: '14:22:03', method: 'POST', path: '/v1/chat/completions', model: 'claude-3.5', status: 200, latency: '3.1s', tokens: 2048),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('AI Gateway'),
          trailing: [
            _serverRunning
              ? PrimaryBadge(child: Text('Running on :8080'))
              : OutlineBadge(child: Text('Stopped')),
            const SizedBox(width: 12),
            Button.primary(
              leading: Icon(_serverRunning ? RadixIcons.stop : RadixIcons.play),
              onPressed: () => setState(() => _serverRunning = !_serverRunning),
              child: Text(_serverRunning ? 'Stop Server' : 'Start Server'),
            ),
          ],
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Stats row
            SizedBox(
              height: 90,
              child: Row(
                children: [
                  _statCard(theme, 'Total Requests', '229', RadixIcons.activityLog),
                  const SizedBox(width: 12),
                  _statCard(theme, 'Active Tokens', '2', RadixIcons.lockOpen1),
                  const SizedBox(width: 12),
                  _statCard(theme, 'Avg Latency', '1.6s', RadixIcons.timer),
                  const SizedBox(width: 12),
                  _statCard(theme, 'Error Rate', '0.4%', RadixIcons.crossCircled),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TabList(
                  index: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                  children: const [
                    TabItem(child: Text('Request Logs')),
                    TabItem(child: Text('API Tokens')),
                    TabItem(child: Text('Configuration')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _tab == 0
                  ? _buildLogs()
                  : _tab == 1
                      ? _buildTokens()
                      : _buildConfig(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(ThemeData theme, String label, String value, IconData icon) {
    return Expanded(
      child: Card(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: theme.colorScheme.mutedForeground),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(fontSize: 12, color: theme.colorScheme.mutedForeground)),
              ],
            ),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogs() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(child: _tableHeader('Time')),
                SizedBox(width: 60, child: _tableHeader('Method')),
                Expanded(flex: 2, child: _tableHeader('Path')),
                Expanded(child: _tableHeader('Model')),
                SizedBox(width: 60, child: _tableHeader('Status')),
                SizedBox(width: 70, child: _tableHeader('Latency')),
                SizedBox(width: 70, child: _tableHeader('Tokens')),
              ],
            ),
          ),
          const Divider(),
          for (final log in _logs)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Expanded(child: Text(log.timestamp, style: const TextStyle(fontSize: 13, fontFamily: 'monospace'))),
                  SizedBox(width: 60, child: SecondaryBadge(child: Text(log.method, style: const TextStyle(fontSize: 11)))),
                  Expanded(flex: 2, child: Text(log.path, style: const TextStyle(fontSize: 13, fontFamily: 'monospace'))),
                  Expanded(child: Text(log.model, style: const TextStyle(fontSize: 13))),
                  SizedBox(
                    width: 60,
                    child: log.status == 200
                      ? PrimaryBadge(child: Text('${log.status}'))
                      : DestructiveBadge(child: Text('${log.status}')),
                  ),
                  SizedBox(width: 70, child: Text(log.latency, style: const TextStyle(fontSize: 13))),
                  SizedBox(width: 70, child: Text('${log.tokens}', style: const TextStyle(fontSize: 13))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Text(
      text,
      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Theme.of(context).colorScheme.mutedForeground),
    );
  }

  Widget _buildTokens() {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (final token in _tokens)
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
                              Text(token.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(width: 8),
                              SecondaryBadge(child: Text('${token.requests} requests')),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(token.token, style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Colors.gray)),
                          const SizedBox(height: 4),
                          Text('Created ${token.created} • Last used ${token.lastUsed}',
                              style: const TextStyle(fontSize: 12, color: Colors.gray)),
                        ],
                      ),
                    ),
                    Button(
                      style: const ButtonStyle.destructive(density: ButtonDensity.compact),
                      onPressed: () {},
                      child: const Text('Revoke'),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Button.primary(
            leading: const Icon(RadixIcons.plus),
            onPressed: () {},
            child: const Text('Generate Token'),
          ),
        ],
      ),
    );
  }

  Widget _buildConfig(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Server Configuration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bind Address', style: TextStyle(fontSize: 13, color: theme.colorScheme.mutedForeground)),
                          const SizedBox(height: 6),
                          const TextField(initialValue: '127.0.0.1'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Port', style: TextStyle(fontSize: 13, color: theme.colorScheme.mutedForeground)),
                          const SizedBox(height: 6),
                          const TextField(initialValue: '8080'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rate Limit (req/min)', style: TextStyle(fontSize: 13, color: theme.colorScheme.mutedForeground)),
                          const SizedBox(height: 6),
                          const TextField(initialValue: '60'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Max Token Budget', style: TextStyle(fontSize: 13, color: theme.colorScheme.mutedForeground)),
                          const SizedBox(height: 6),
                          const TextField(initialValue: '100000'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Model Routing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(
                  'Map model aliases to specific providers. Clients request an alias, and Prism routes to the configured provider.',
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.mutedForeground),
                ),
                const SizedBox(height: 16),
                for (final route in [
                  ('gpt-4o', 'OpenAI → gpt-4o'),
                  ('gemma-3n', 'Local → llama_cpp_dart'),
                  ('claude-3.5', 'Anthropic → claude-3-5-sonnet'),
                  ('mistral-7b', 'Ollama → mistral:7b'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        OutlineBadge(child: Text(route.$1)),
                        const SizedBox(width: 12),
                        const Icon(RadixIcons.arrowRight, size: 14),
                        const SizedBox(width: 12),
                        Text(route.$2, style: const TextStyle(fontSize: 13)),
                      ],
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

class _GatewayToken {
  final String name;
  final String token;
  final String created;
  final String lastUsed;
  final int requests;

  const _GatewayToken({required this.name, required this.token, required this.created, required this.lastUsed, required this.requests});
}

class _RequestLog {
  final String timestamp;
  final String method;
  final String path;
  final String model;
  final int status;
  final String latency;
  final int tokens;

  const _RequestLog({
    required this.timestamp,
    required this.method,
    required this.path,
    required this.model,
    required this.status,
    required this.latency,
    required this.tokens,
  });
}
