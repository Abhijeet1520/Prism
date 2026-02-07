import 'package:flutter/material.dart';
import '../../data/mock_data.dart';

class FileExplorerScreen extends StatelessWidget {
  const FileExplorerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final folders = MockData.files.where((f) => f.isFolder).toList();
    final files = MockData.files.where((f) => !f.isFolder).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('📁 Files'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.create_new_folder_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Breadcrumb
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.home, size: 16, color: cs.primary),
                Text(' > ', style: TextStyle(color: cs.onSurfaceVariant)),
                Text(
                  'Documents',
                  style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(' > ', style: TextStyle(color: cs.onSurfaceVariant)),
                Text(
                  'Project Alpha',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Folders
          ...folders.map((item) => _FileListTile(item: item)),

          // Files with header
          if (files.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Name',
                        style: Theme.of(context).textTheme.labelSmall),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text('Modified',
                        style: Theme.of(context).textTheme.labelSmall),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text('Lock',
                        style: Theme.of(context).textTheme.labelSmall),
                  ),
                ],
              ),
            ),
          const Divider(height: 1),
          ...files.map((item) => _FileListTile(item: item)),

          // Footer
          const SizedBox(height: 12),
          Center(
            child: Text(
              '${MockData.files.length} items · 265 KB',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
          ),

          // Quick access
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Access',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ListTile(
                  dense: true,
                  leading: const Text('⭐'),
                  title: const Text('budget_q1.csv'),
                  visualDensity: VisualDensity.compact,
                  onTap: () {},
                ),
                ListTile(
                  dense: true,
                  leading: const Text('⭐'),
                  title: const Text('soul.md'),
                  visualDensity: VisualDensity.compact,
                  onTap: () {},
                ),
                ListTile(
                  dense: true,
                  leading: const Text('🕐'),
                  title: const Text('meeting-notes.md'),
                  subtitle: const Text('recent'),
                  visualDensity: VisualDensity.compact,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FileListTile extends StatelessWidget {
  final FileItem item;
  const _FileListTile({required this.item});

  String get _permissionIcon {
    switch (item.permission) {
      case 'locked':
        return '🔒';
      case 'gated':
        return '🔐';
      case 'open':
        return '🔓';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(item.icon, style: const TextStyle(fontSize: 20)),
      title: Text(
        item.name,
        style: TextStyle(
          fontWeight: item.isFolder ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      subtitle: item.isFolder
          ? null
          : Text('${item.modified} · ${item.size}'),
      trailing: Text(_permissionIcon),
      onTap: () {
        if (!item.isFolder) {
          _showFileInfo(context);
        }
      },
      onLongPress: () => _showContextMenu(context),
    );
  }

  void _showFileInfo(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.name, style: Theme.of(context).textTheme.headlineSmall),
            const Divider(),
            _InfoRow('Type', item.icon),
            _InfoRow('Size', item.size ?? '—'),
            _InfoRow('Modified', item.modified ?? '—'),
            _InfoRow('Permission', _permissionIcon),
            _InfoRow('Versions', '14'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.history, size: 16),
                  label: const Text('View History'),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit Info'),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.lock, size: 16, color: cs.error),
                  label: const Text('Change Permission'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(item.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            const Divider(height: 1),
            ListTile(leading: const Text('📖'), title: const Text('Open'), onTap: () {}),
            ListTile(leading: const Text('✏️'), title: const Text('Edit'), onTap: () {}),
            ListTile(leading: const Text('📋'), title: const Text('Copy'), onTap: () {}),
            ListTile(leading: const Text('📁'), title: const Text('Move to...'), onTap: () {}),
            ListTile(leading: const Text('🏷️'), title: const Text('Tags...'), onTap: () {}),
            const Divider(height: 1),
            ListTile(leading: const Text('📜'), title: const Text('Version History'), onTap: () {}),
            ListTile(leading: const Text('📤'), title: const Text('Export'), onTap: () {}),
            const Divider(height: 1),
            ListTile(
              leading: const Text('🗑️'),
              title: const Text('Move to Trash'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
