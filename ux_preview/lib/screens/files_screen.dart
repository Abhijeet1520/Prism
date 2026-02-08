import 'package:shadcn_flutter/shadcn_flutter.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  int _selectedFile = 0;

  static const _files = [
    _FileItem(name: 'Documents', isFolder: true, children: [
      _FileItem(name: 'project-plan.md', isFolder: false, size: '12 KB', modified: 'Jan 6'),
      _FileItem(name: 'meeting-notes.md', isFolder: false, size: '8 KB', modified: 'Jan 5'),
      _FileItem(name: 'api-spec.yaml', isFolder: false, size: '24 KB', modified: 'Jan 4'),
    ]),
    _FileItem(name: 'Code', isFolder: true, children: [
      _FileItem(name: 'main.dart', isFolder: false, size: '4 KB', modified: 'Jan 6'),
      _FileItem(name: 'utils.dart', isFolder: false, size: '2 KB', modified: 'Jan 3'),
      _FileItem(name: 'config.json', isFolder: false, size: '1 KB', modified: 'Jan 2'),
    ]),
    _FileItem(name: 'Research', isFolder: true, children: [
      _FileItem(name: 'llm-comparison.md', isFolder: false, size: '18 KB', modified: 'Jan 5'),
      _FileItem(name: 'architecture-decisions.md', isFolder: false, size: '6 KB', modified: 'Jan 1'),
    ]),
    _FileItem(name: 'quick-notes.md', isFolder: false, size: '3 KB', modified: 'Today'),
    _FileItem(name: 'todo.md', isFolder: false, size: '1 KB', modified: 'Today'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Files'),
          trailing: [
            Button.secondary(
              leading: const Icon(RadixIcons.filePlus),
              onPressed: () {},
              child: const Text('New File'),
            ),
            const SizedBox(width: 8),
            Button.primary(
              leading: const Icon(RadixIcons.upload),
              onPressed: () {},
              child: const Text('Import'),
            ),
          ],
        ),
      ],
      child: Row(
        children: [
          // File tree sidebar
          SizedBox(
            width: 280,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    placeholder: const Text('Search files...'),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int i = 0; i < _files.length; i++)
                          _buildFileNode(_files[i], 0, i),
                      ],
                    ),
                  ),
                ),
                // Storage info
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Card(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Storage', style: TextStyle(fontSize: 12, color: theme.colorScheme.mutedForeground)),
                        const SizedBox(height: 6),
                        const Progress(progress: 0.23),
                        const SizedBox(height: 4),
                        const Text('79 KB / 50 MB used', style: TextStyle(fontSize: 11, color: Colors.gray)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(),
          // File content area
          Expanded(
            child: _selectedFile == 0 ? _buildFilePreview() : _buildEmptyState(),
          ),
        ],
      ),
    );
  }

  Widget _buildFileNode(_FileItem file, int depth, int index) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Clickable(
            onPressed: () => setState(() => _selectedFile = index),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Row(
                children: [
                  Icon(
                    file.isFolder
                        ? RadixIcons.chevronDown
                        : _fileIcon(file.name),
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      file.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: file.isFolder ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (!file.isFolder)
                    Text(file.size ?? '', style: const TextStyle(fontSize: 11, color: Colors.gray)),
                ],
              ),
            ),
          ),
          if (file.isFolder && file.children != null)
            for (int i = 0; i < file.children!.length; i++)
              _buildFileNode(file.children![i], depth + 1, index * 100 + i),
        ],
      ),
    );
  }

  IconData _fileIcon(String name) {
    if (name.endsWith('.md')) return RadixIcons.file;
    if (name.endsWith('.dart')) return RadixIcons.code;
    if (name.endsWith('.json') || name.endsWith('.yaml')) return RadixIcons.gear;
    return RadixIcons.fileText;
  }

  Widget _buildFilePreview() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File header
          Row(
            children: [
              const Icon(RadixIcons.file, size: 18),
              const SizedBox(width: 8),
              const Text('project-plan.md', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              OutlineBadge(child: const Text('Markdown')),
              const SizedBox(width: 8),
              const Text('12 KB • Modified Jan 6', style: TextStyle(fontSize: 12, color: Colors.gray)),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(),
          const SizedBox(height: 16),
          // File content preview
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('# Prism Project Plan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('## Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text(
                    'Prism is an AI-powered personal assistant built with Flutter. '
                    'It serves as a central hub for intelligence, combining local and cloud LLM providers '
                    'with a comprehensive set of productivity tools.',
                    style: TextStyle(fontSize: 14, height: 1.6),
                  ),
                  const SizedBox(height: 16),
                  const Text('## Core Features', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  for (final feature in [
                    '- Multi-provider AI chat with conversation branching',
                    '- Second Brain with PARA method organization',
                    '- Task management with kanban and calendar views',
                    '- Financial tracker with notification capture',
                    '- AI Gateway for exposing models via API',
                    '- MCP protocol support for tool integration',
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(feature, style: const TextStyle(fontSize: 14, height: 1.5)),
                    ),
                  const SizedBox(height: 16),
                  const Text('## Tech Stack', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Card(
                    padding: const EdgeInsets.all(12),
                    child: const Text(
                      'framework: Flutter 3.x\n'
                      'state: Riverpod 2.x\n'
                      'database: Drift (SQLite)\n'
                      'ui: shadcn/ui for Flutter\n'
                      'ai: LangChain.dart + llama_cpp_dart',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(RadixIcons.file, size: 48),
          SizedBox(height: 16),
          Text('Select a file to preview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          Text('Choose a file from the sidebar to view its contents', style: TextStyle(color: Colors.gray)),
        ],
      ),
    );
  }
}

class _FileItem {
  final String name;
  final bool isFolder;
  final String? size;
  final String? modified;
  final List<_FileItem>? children;

  const _FileItem({
    required this.name,
    required this.isFolder,
    this.size,
    this.modified,
    this.children,
  });
}
