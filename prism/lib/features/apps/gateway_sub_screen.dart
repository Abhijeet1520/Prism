/// Gateway sub-screen — AI Host Server controls and endpoint info.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/ai_host_server.dart';

class GatewaySubScreen extends ConsumerWidget {
  final bool isDark;
  final Color cardColor, borderColor, textPrimary, textSecondary;

  const GatewaySubScreen({
    super.key,
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final host = ref.watch(aiHostProvider);
    final accentColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Server status card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: host.isRunning
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      host.isRunning ? 'Server Running' : 'Server Stopped',
                      style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                    ),
                    const Spacer(),
                    Switch.adaptive(
                      value: host.isRunning,
                      onChanged: (_) {
                        final notifier = ref.read(aiHostProvider.notifier);
                        if (host.isRunning) {
                          notifier.stop();
                        } else {
                          notifier.start();
                        }
                      },
                      activeTrackColor: accentColor,
                    ),
                  ],
                ),
                if (host.isRunning) ...[
                  const SizedBox(height: 12),
                  _infoRow('Endpoint',
                      'http://localhost:${host.port}/v1/chat/completions'),
                  const SizedBox(height: 6),
                  _infoRow('Port', '${host.port}'),
                  const SizedBox(height: 6),
                  _infoRow('Requests Served', '${host.requestCount}'),
                ],
                if (host.error != null) ...[
                  const SizedBox(height: 8),
                  Text(host.error!,
                      style: const TextStyle(
                          color: Color(0xFFEF4444), fontSize: 12)),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('About Gateway',
                    style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  'Gateway exposes your loaded AI model as an OpenAI-compatible API on localhost. '
                  'Other apps on this device can send requests to use your model — no cloud needed.',
                  style: TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                      height: 1.5),
                ),
                const SizedBox(height: 12),
                Text('Compatible endpoints:',
                    style: TextStyle(
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 12)),
                const SizedBox(height: 6),
                _endpoint('GET', '/health', textSecondary),
                _endpoint('GET', '/v1/models', textSecondary),
                _endpoint('POST', '/v1/chat/completions', textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(label,
              style: TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Text(value,
              style: TextStyle(color: textPrimary, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _endpoint(String method, String path, Color secondary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: method == 'GET'
                  ? const Color(0xFF10B981).withValues(alpha: 0.12)
                  : const Color(0xFF3B82F6).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(method,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: method == 'GET'
                        ? const Color(0xFF10B981)
                        : const Color(0xFF3B82F6))),
          ),
          const SizedBox(width: 8),
          Text(path, style: TextStyle(color: secondary, fontSize: 12)),
        ],
      ),
    );
  }
}
