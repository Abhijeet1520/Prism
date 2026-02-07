import 'package:flutter/material.dart';
import '../../data/mock_data.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Group tools by category
    final grouped = <String, List<Tool>>{};
    for (final t in MockData.tools) {
      grouped.putIfAbsent(t.category, () => []).add(t);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔧 Tools'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final entry in grouped.entries) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 8),
              child: Text(
                entry.key,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            _ToolGrid(tools: entry.value),
          ],
        ],
      ),
    );
  }
}

class _ToolGrid extends StatelessWidget {
  final List<Tool> tools;
  const _ToolGrid({required this.tools});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tools.map((tool) {
        return SizedBox(
          width: 110,
          child: Card(
            color: tool.isEnabled
                ? cs.surfaceContainerHighest
                : cs.surfaceContainerLow,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showToolDetail(context, tool),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(tool.icon, style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 8),
                    Text(
                      tool.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tool.isEnabled ? '✅ On' : '⬜ Off',
                      style: TextStyle(
                        fontSize: 11,
                        color: tool.isEnabled
                            ? cs.primary
                            : cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showToolDetail(BuildContext context, Tool tool) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (context, controller) {
          return ListView(
            controller: controller,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Text(tool.icon, style: const TextStyle(fontSize: 48)),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  tool.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  tool.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 24),
              _ConfigRow('Enabled', Switch(value: tool.isEnabled, onChanged: (_) {})),
              _ConfigRow('Timeout', const Text('30 sec')),
              _ConfigRow('Memory Limit', const Text('256 MB')),
              _ConfigRow('Network Access', Switch(value: false, onChanged: (_) {})),
              _ConfigRow('Auto-approve', Switch(value: false, onChanged: (_) {})),
              const SizedBox(height: 16),
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
                      'Permission: 🔐 Gated',
                      style: TextStyle(color: cs.onTertiaryContainer),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Recent Invocations',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              _InvocationItem('Calculate monthly avgs', 'Today 2:30 PM', true),
              _InvocationItem('Parse CSV data', 'Yesterday', true),
              _InvocationItem('Generate chart', '2 days ago', false),
            ],
          );
        },
      ),
    );
  }
}

class _ConfigRow extends StatelessWidget {
  final String label;
  final Widget trailing;
  const _ConfigRow(this.label, this.trailing);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          trailing,
        ],
      ),
    );
  }
}

class _InvocationItem extends StatelessWidget {
  final String title, time;
  final bool success;
  const _InvocationItem(this.title, this.time, this.success);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Text(success ? '✅' : '❌'),
      title: Text(title, style: const TextStyle(fontSize: 13)),
      subtitle: Text(time, style: const TextStyle(fontSize: 11)),
      visualDensity: VisualDensity.compact,
    );
  }
}
