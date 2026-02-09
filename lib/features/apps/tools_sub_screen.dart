/// Tools sub-screen — expandable tool list + MCP Servers tab.
///
/// Matches ux_preview: Tools tab with accordion details (stats, params),
/// MCP Servers tab with status indicators, tool counts, error alerts.
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class ToolsSubScreen extends StatefulWidget {
  final bool isDark;
  final Color cardColor, borderColor, textPrimary, textSecondary;

  const ToolsSubScreen({
    super.key,
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  State<ToolsSubScreen> createState() => _ToolsSubScreenState();
}

class _ToolsSubScreenState extends State<ToolsSubScreen> {
  List<dynamic> _tools = [];
  List<dynamic> _servers = [];
  int _activeTab = 0;

  /// Track enabled states locally (editable)
  final Map<String, bool> _toolEnabled = {};
  /// Track server auto-connect states locally
  final Map<String, bool> _serverAutoConnect = {};

  /// IDs of tools that are actually implemented and can work
  static const _implementedToolIds = {
    'tool_calculator',
    'tool_finance',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final raw = await rootBundle.loadString('assets/mock_data/app_data.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    setState(() {
      _tools = (json['tools'] as List?) ?? [];
      _servers = (json['mcp_servers'] as List?) ?? [];
      // Initialize enable states from data
      for (final t in _tools) {
        final tool = t as Map<String, dynamic>;
        final id = tool['id'] as String;
        final isImpl = _implementedToolIds.contains(id);
        _toolEnabled[id] = isImpl && (tool['isEnabled'] as bool);
      }
      for (final s in _servers) {
        final srv = s as Map<String, dynamic>;
        _serverAutoConnect[srv['name'] as String] = srv['autoConnect'] as bool;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        // ─── Tab bar ──────────────────────────────
        Container(
          color: widget.cardColor,
          child: Row(
            children: [
              _TabBtn(
                label: 'Tools', isActive: _activeTab == 0,
                accent: accent, secondary: widget.textSecondary,
                onTap: () => setState(() => _activeTab = 0)),
              _TabBtn(
                label: 'MCP Servers', isActive: _activeTab == 1,
                accent: accent, secondary: widget.textSecondary,
                onTap: () => setState(() => _activeTab = 1)),
            ],
          ),
        ),
        Divider(height: 1, color: widget.borderColor),
        Expanded(
          child: _activeTab == 0
              ? _buildToolsList(accent)
              : _buildServersList(accent),
        ),
      ],
    );
  }

  // ─── Tools List ─────────────────────────────────

  Widget _buildToolsList(Color accent) {
    if (_tools.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.extension_outlined, size: 48,
              color: widget.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text('Loading tools...', style: TextStyle(
              color: widget.textSecondary, fontSize: 14)),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _tools.length,
      itemBuilder: (context, i) {
        final tool = _tools[i] as Map<String, dynamic>;
        final id = tool['id'] as String;
        final isImpl = _implementedToolIds.contains(id);
        return _ToolCard(
          tool: tool,
          isDark: widget.isDark,
          cardColor: widget.cardColor,
          borderColor: widget.borderColor,
          textPrimary: widget.textPrimary,
          textSecondary: widget.textSecondary,
          accent: accent,
          isImplemented: isImpl,
          isEnabled: _toolEnabled[id] ?? false,
          onToggle: isImpl
              ? (val) => setState(() => _toolEnabled[id] = val)
              : null,
        );
      },
    );
  }

  // ─── MCP Servers ────────────────────────────────

  Widget _buildServersList(Color accent) {
    if (_servers.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.dns_outlined, size: 48,
              color: widget.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text('No MCP servers configured',
              style: TextStyle(color: widget.textSecondary, fontSize: 14)),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _servers.length,
      itemBuilder: (context, i) {
        final server = _servers[i] as Map<String, dynamic>;
        final status = server['status'] as String;
        final statusColor = _serverStatusColor(status);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: widget.borderColor, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: status dot + name + status tag
              Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                        color: statusColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(server['name'] as String,
                        style: TextStyle(
                            color: widget.textPrimary,
                            fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4)),
                    child: Text(status,
                        style: TextStyle(fontSize: 10, color: statusColor)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(server['description'] as String,
                  style: TextStyle(
                      color: widget.textSecondary, fontSize: 12),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              // Stats row
              Row(
                children: [
                  _statChip('${server['toolCount']} tools'),
                  const SizedBox(width: 6),
                  _statChip('${server['requestCount']} req'),
                  const SizedBox(width: 6),
                  if (server['uptime'] != null)
                    _statChip(server['uptime'] as String),
                  const Spacer(),
                  // Auto-connect toggle
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Auto', style: TextStyle(
                          color: widget.textSecondary, fontSize: 10)),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 28, height: 16,
                        child: Transform.scale(
                          scale: 0.6,
                          child: Switch(
                            value: _serverAutoConnect[server['name'] as String] ?? false,
                            onChanged: (val) => setState(() =>
                                _serverAutoConnect[server['name'] as String] = val),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Error alert
              if (status == 'error' && server['lastError'] != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, size: 14,
                          color: Color(0xFFEF4444)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(server['lastError'] as String,
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFFEF4444))),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _statChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: widget.isDark
            ? const Color(0xFF1E1E36)
            : const Color(0xFFF0F0F8),
        borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(
          color: widget.textSecondary, fontSize: 10)),
    );
  }

  Color _serverStatusColor(String status) => switch (status) {
        'connected' => const Color(0xFF10B981),
        'disconnected' => const Color(0xFF6B7280),
        'error' => const Color(0xFFEF4444),
        _ => const Color(0xFFF59E0B),
      };
}

// ─── Tool Card (Expandable Accordion) ────────────

class _ToolCard extends StatefulWidget {
  final Map<String, dynamic> tool;
  final bool isDark;
  final Color cardColor, borderColor, textPrimary, textSecondary, accent;
  final bool isImplemented;
  final bool isEnabled;
  final ValueChanged<bool>? onToggle;

  const _ToolCard({
    required this.tool, required this.isDark, required this.cardColor,
    required this.borderColor, required this.textPrimary,
    required this.textSecondary, required this.accent,
    required this.isImplemented, required this.isEnabled, this.onToggle});

  @override
  State<_ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<_ToolCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final tool = widget.tool;
    final provider = tool['provider'] as String;
    final isBuiltIn = provider == 'built-in';
    final providerColor = isBuiltIn
        ? const Color(0xFF10B981)
        : provider == 'ml-kit'
            ? const Color(0xFF3B82F6)
            : widget.accent;
    final enabled = widget.isEnabled;
    final isImpl = widget.isImplemented;

    return Opacity(
      opacity: isImpl ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: widget.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: widget.borderColor, width: 0.5),
        ),
        child: Column(
          children: [
            // Header (tap to expand)
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(tool['displayName'] as String,
                              style: TextStyle(
                                  color: widget.textPrimary,
                                  fontWeight: FontWeight.w500, fontSize: 14)),
                          if (!isImpl) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4)),
                              child: const Text('coming soon',
                                  style: TextStyle(fontSize: 8, color: Color(0xFFF59E0B))),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Provider tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: providerColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4)),
                      child: Text(provider, style: TextStyle(
                          fontSize: 10, color: providerColor)),
                    ),
                    const SizedBox(width: 8),
                    // Enable toggle — smaller with Transform.scale
                    SizedBox(
                      width: 28, height: 16,
                      child: Transform.scale(
                        scale: 0.6,
                        child: Switch(
                          value: enabled,
                          onChanged: isImpl ? (val) => widget.onToggle?.call(val) : null,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                    size: 18, color: widget.textSecondary),
                ],
              ),
            ),
          ),
          // Expandable details
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tool['description'] as String,
                      style: TextStyle(
                          color: widget.textSecondary,
                          fontSize: 12, height: 1.5)),
                  const SizedBox(height: 10),
                  // Stats
                  Row(
                    children: [
                      _stat('${tool['callCount']} calls'),
                      const SizedBox(width: 6),
                      _stat('${tool['avgLatencyMs']}ms avg'),
                      const SizedBox(width: 6),
                      _stat('${((tool['successRate'] as num) * 100).toInt()}% success'),
                    ],
                  ),
                  // Parameters
                  if (tool['parameters'] != null) ...[
                    const SizedBox(height: 10),
                    Text('Parameters',
                        style: TextStyle(color: widget.textPrimary,
                            fontWeight: FontWeight.w600, fontSize: 12)),
                    const SizedBox(height: 4),
                    ...(tool['parameters'] as List).map((p) {
                      final param = p as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(children: [
                          Text(param['name'] as String,
                              style: TextStyle(color: widget.accent,
                                  fontSize: 11, fontFamily: 'monospace')),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: widget.borderColor,
                              borderRadius: BorderRadius.circular(3)),
                            child: Text(param['type'] as String,
                                style: TextStyle(fontSize: 9,
                                    color: widget.textSecondary)),
                          ),
                          if (param['required'] == true) ...[
                            const SizedBox(width: 4),
                            const Text('*', style: TextStyle(
                                color: Color(0xFFEF4444), fontSize: 12)),
                          ],
                        ]),
                      );
                    }),
                  ],
                ],
              ),
            ),
        ],
      ),
      ),
    );
  }

  Widget _stat(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: widget.isDark
            ? const Color(0xFF1E1E36)
            : const Color(0xFFF0F0F8),
        borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(
          color: widget.textSecondary, fontSize: 10)),
    );
  }
}

// ─── Tab Button ───────────────────────────────────

class _TabBtn extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color accent, secondary;
  final VoidCallback onTap;
  const _TabBtn({
    required this.label, required this.isActive,
    required this.accent, required this.secondary, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? accent : Colors.transparent,
                width: 2)),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isActive ? accent : secondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
        ),
      ),
    );
  }
}
