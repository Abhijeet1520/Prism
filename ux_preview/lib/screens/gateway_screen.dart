import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

class GatewayScreen extends StatefulWidget {
  const GatewayScreen({super.key});

  @override
  State<GatewayScreen> createState() => _GatewayScreenState();
}

class _GatewayScreenState extends State<GatewayScreen> {
  bool _gatewayEnabled = false;

  // Mock data
  final _apiKeys = [
    {'key': 'pk_live_a1b2c3d4...', 'created': '2025-01-02', 'lastUsed': '2025-01-06', 'requests': 142},
    {'key': 'pk_test_x9y8z7w6...', 'created': '2024-12-20', 'lastUsed': '2025-01-05', 'requests': 53},
  ];

  final _recentRequests = [
    {'method': 'POST', 'path': '/v1/chat/completions', 'status': 200, 'latency': '245ms', 'time': '14:02:30'},
    {'method': 'POST', 'path': '/v1/chat/completions', 'status': 200, 'latency': '312ms', 'time': '14:01:15'},
    {'method': 'GET', 'path': '/v1/models', 'status': 200, 'latency': '12ms', 'time': '14:00:50'},
    {'method': 'POST', 'path': '/v1/embeddings', 'status': 429, 'latency': '5ms', 'time': '13:58:22'},
    {'method': 'POST', 'path': '/v1/chat/completions', 'status': 500, 'latency': '1024ms', 'time': '13:55:10'},
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.moonColors!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gateway toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.goten,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.beerus, width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (_gatewayEnabled ? colors.roshi : colors.trunks).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.bolt,
                    color: _gatewayEnabled ? colors.roshi : colors.trunks,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Gateway',
                        style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      Text(
                        _gatewayEnabled ? 'Running on http://localhost:8080' : 'Gateway is offline',
                        style: TextStyle(color: colors.trunks, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                MoonSwitch(
                  value: _gatewayEnabled,
                  onChanged: (v) => setState(() => _gatewayEnabled = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Stats
          if (_gatewayEnabled) ...[
            Row(
              children: [
                Expanded(child: _statCard(colors, 'Requests', '195', Icons.call_made_rounded)),
                const SizedBox(width: 10),
                Expanded(child: _statCard(colors, 'Active', '2', Icons.people_outline)),
                const SizedBox(width: 10),
                Expanded(child: _statCard(colors, 'Uptime', '6h 12m', Icons.timer_outlined)),
              ],
            ),
            const SizedBox(height: 16),
            // Rate limit
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.goten,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.beerus, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Rate Limit', style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w500, fontSize: 14)),
                      const Spacer(),
                      Text('195 / 1000 req/hr', style: TextStyle(color: colors.trunks, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  MoonLinearProgress(
                    value: 0.195,
                    color: colors.piccolo,
                    backgroundColor: colors.beerus,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          // API Keys
          _sectionHeader(colors, 'API Keys'),
          const SizedBox(height: 8),
          ...List.generate(_apiKeys.length, (i) {
            final key = _apiKeys[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.goten,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.beerus, width: 0.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.key, size: 16, color: colors.trunks),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          key['key'] as String,
                          style: TextStyle(color: colors.bulma, fontSize: 13, fontFamily: 'monospace'),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Created ${key['created']} \u00b7 Last used ${key['lastUsed']} \u00b7 ${key['requests']} requests',
                          style: TextStyle(color: colors.trunks, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  MoonTextButton(
                    onTap: () {},
                    buttonSize: MoonButtonSize.sm,
                    label: Text('Revoke', style: TextStyle(color: colors.chichi, fontSize: 12)),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          // Recent requests
          _sectionHeader(colors, 'Recent Requests'),
          const SizedBox(height: 8),
          ...List.generate(_recentRequests.length, (i) {
            final req = _recentRequests[i];
            final status = req['status'] as int;
            final isOk = status >= 200 && status < 300;

            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              child: MoonMenuItem(
                backgroundColor: colors.goten,
                leading: MoonTag(
                  tagSize: MoonTagSize.x2s,
                  backgroundColor: isOk ? colors.roshi.withValues(alpha: 0.15) : colors.chichi.withValues(alpha: 0.15),
                  label: Text(
                    '$status',
                    style: TextStyle(fontSize: 10, color: isOk ? colors.roshi : colors.chichi, fontWeight: FontWeight.w600),
                  ),
                ),
                label: Row(
                  children: [
                    Text(
                      req['method'] as String,
                      style: TextStyle(color: colors.piccolo, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        req['path'] as String,
                        style: TextStyle(color: colors.bulma, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(req['latency'] as String, style: TextStyle(color: colors.trunks, fontSize: 10)),
                    Text(req['time'] as String, style: TextStyle(color: colors.trunks, fontSize: 10)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _statCard(MoonColors colors, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.goten,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.beerus, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: colors.trunks),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w700, fontSize: 20)),
          Text(label, style: TextStyle(color: colors.trunks, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _sectionHeader(MoonColors colors, String title) {
    return Text(
      title,
      style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w600, fontSize: 14),
    );
  }
}
