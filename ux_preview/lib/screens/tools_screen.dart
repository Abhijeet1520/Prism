import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moon_design/moon_design.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  List<dynamic> _tools = [];
  List<dynamic> _servers = [];
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  Future<void> _loadMockData() async {
    final toolsJson = await rootBundle.loadString('assets/mock_data/tools/tools.json');
    final serversJson = await rootBundle.loadString('assets/mock_data/tools/mcp_servers.json');
    setState(() {
      _tools = jsonDecode(toolsJson) as List;
      _servers = jsonDecode(serversJson) as List;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.moonColors!;

    return Column(
      children: [
        // Tabs
        Container(
          color: colors.goten,
          child: MoonTabBar(
            tabBarSize: MoonTabBarSize.sm,
            tabs: const [
              MoonTab(label: Text('Tools')),
              MoonTab(label: Text('MCP Servers')),
            ],
            onTabChanged: (i) => setState(() => _activeTab = i),
          ),
        ),
        Divider(height: 1, color: colors.beerus),
        Expanded(
          child: _activeTab == 0 ? _buildToolsList(colors) : _buildServersList(colors),
        ),
      ],
    );
  }

  Widget _buildToolsList(MoonColors colors) {
    if (_tools.isEmpty) {
      return Center(child: MoonCircularLoader(color: colors.piccolo));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _tools.length,
      itemBuilder: (context, i) {
        final tool = _tools[i] as Map<String, dynamic>;
        return MoonAccordion<void>(
          backgroundColor: colors.goten,
          expandedBackgroundColor: colors.goten,
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          label: Row(
            children: [
              Expanded(
                child: Text(
                  tool['displayName'] as String,
                  style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w500, fontSize: 14),
                ),
              ),
              MoonTag(
                tagSize: MoonTagSize.x2s,
                backgroundColor: tool['provider'] == 'built-in'
                    ? colors.roshi.withValues(alpha: 0.15)
                    : colors.piccolo.withValues(alpha: 0.15),
                label: Text(
                  tool['provider'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: tool['provider'] == 'built-in' ? colors.roshi : colors.piccolo,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              MoonSwitch(
                switchSize: MoonSwitchSize.x2s,
                value: tool['isEnabled'] as bool,
                onChanged: (_) {},
              ),
            ],
          ),
          children: [
            Text(
              tool['description'] as String,
              style: TextStyle(color: colors.trunks, fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _statChip(colors, '${tool['callCount']} calls'),
                const SizedBox(width: 6),
                _statChip(colors, '${tool['avgLatencyMs']}ms avg'),
                const SizedBox(width: 6),
                _statChip(colors, '${((tool['successRate'] as num) * 100).toInt()}% success'),
              ],
            ),
            if (tool['parameters'] != null) ...[
              const SizedBox(height: 10),
              Text('Parameters', style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w600, fontSize: 12)),
              const SizedBox(height: 4),
              ..._buildParamList(colors, tool['parameters'] as List),
            ],
          ],
        );
      },
    );
  }

  List<Widget> _buildParamList(MoonColors colors, List<dynamic> params) {
    return params.map((p) {
      final param = p as Map<String, dynamic>;
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Text(
              param['name'] as String,
              style: TextStyle(color: colors.piccolo, fontSize: 11, fontFamily: 'monospace'),
            ),
            const SizedBox(width: 6),
            MoonTag(
              tagSize: MoonTagSize.x2s,
              backgroundColor: colors.beerus,
              label: Text(param['type'] as String, style: TextStyle(fontSize: 9, color: colors.trunks)),
            ),
            if (param['required'] == true) ...[
              const SizedBox(width: 4),
              Text('*', style: TextStyle(color: colors.chichi, fontSize: 12)),
            ],
          ],
        ),
      );
    }).toList();
  }

  Widget _buildServersList(MoonColors colors) {
    if (_servers.isEmpty) {
      return Center(child: MoonCircularLoader(color: colors.piccolo));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _servers.length,
      itemBuilder: (context, i) {
        final server = _servers[i] as Map<String, dynamic>;
        final status = server['status'] as String;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
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
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _serverStatusColor(colors, status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      server['name'] as String,
                      style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                  MoonTag(
                    tagSize: MoonTagSize.x2s,
                    backgroundColor: _serverStatusColor(colors, status).withValues(alpha: 0.15),
                    label: Text(
                      status,
                      style: TextStyle(fontSize: 10, color: _serverStatusColor(colors, status)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                server['description'] as String,
                style: TextStyle(color: colors.trunks, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _statChip(colors, '${server['toolCount']} tools'),
                  const SizedBox(width: 6),
                  _statChip(colors, '${server['requestCount']} req'),
                  const SizedBox(width: 6),
                  if (server['uptime'] != null) _statChip(colors, server['uptime'] as String),
                  const Spacer(),
                  MoonSwitch(
                    switchSize: MoonSwitchSize.x2s,
                    value: server['autoConnect'] as bool,
                    onChanged: (_) {},
                  ),
                ],
              ),
              if (status == 'error' && server['lastError'] != null) ...[
                const SizedBox(height: 8),
                MoonAlert(
                  show: true,
                  backgroundColor: colors.chichi.withValues(alpha: 0.08),
                  leading: Icon(Icons.error_outline, size: 16, color: colors.chichi),
                  label: Text(
                    server['lastError'] as String,
                    style: TextStyle(color: colors.chichi, fontSize: 11),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _statChip(MoonColors colors, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.gohan,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(color: colors.trunks, fontSize: 10)),
    );
  }

  Color _serverStatusColor(MoonColors colors, String status) {
    return switch (status) {
      'connected' => colors.roshi,
      'disconnected' => colors.trunks,
      'error' => colors.chichi,
      _ => colors.krillin,
    };
  }
}
