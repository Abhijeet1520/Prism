import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moon_design/moon_design.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  List<dynamic> _files = [];
  String _currentParentId = 'file_root';
  final _breadcrumb = <Map<String, dynamic>>[];
  String? _selectedFileId;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  Future<void> _loadMockData() async {
    final json = await rootBundle.loadString('assets/mock_data/files/files.json');
    setState(() {
      _files = jsonDecode(json) as List;
      final root = _files.firstWhere((f) => f['id'] == 'file_root');
      _breadcrumb.add(root as Map<String, dynamic>);
    });
  }

  List<dynamic> get _currentItems {
    return _files.where((f) => f['parentId'] == _currentParentId).toList()
      ..sort((a, b) {
        if (a['isFolder'] == true && b['isFolder'] != true) return -1;
        if (a['isFolder'] != true && b['isFolder'] == true) return 1;
        return (a['name'] as String).compareTo(b['name'] as String);
      });
  }

  void _navigateToFolder(Map<String, dynamic> folder) {
    setState(() {
      _currentParentId = folder['id'] as String;
      _breadcrumb.add(folder);
      _selectedFileId = null;
    });
  }

  void _navigateToBreadcrumb(int index) {
    setState(() {
      final target = _breadcrumb[index];
      _currentParentId = target['id'] as String;
      _breadcrumb.removeRange(index + 1, _breadcrumb.length);
      _selectedFileId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.moonColors!;

    return Column(
      children: [
        // Breadcrumb bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: colors.goten,
            border: Border(bottom: BorderSide(color: colors.beerus)),
          ),
          child: Row(
            children: [
              ..._buildBreadcrumbs(colors),
              const Spacer(),
              MoonButton.icon(
                onTap: () {},
                icon: Icon(Icons.search, size: 20, color: colors.trunks),
                buttonSize: MoonButtonSize.sm,
              ),
              const SizedBox(width: 4),
              MoonFilledButton(
                onTap: () {},
                buttonSize: MoonButtonSize.sm,
                label: const Text('New'),
                leading: const Icon(Icons.add, size: 16),
              ),
            ],
          ),
        ),
        // File list
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 700 && _selectedFileId != null) {
                return Row(
                  children: [
                    Expanded(child: _buildFileList(colors)),
                    VerticalDivider(width: 1, color: colors.beerus),
                    SizedBox(width: 320, child: _buildFilePreview(colors)),
                  ],
                );
              }
              return _buildFileList(colors);
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildBreadcrumbs(MoonColors colors) {
    final widgets = <Widget>[];
    for (var i = 0; i < _breadcrumb.length; i++) {
      if (i > 0) {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(Icons.chevron_right, size: 16, color: colors.trunks),
        ));
      }
      final isLast = i == _breadcrumb.length - 1;
      widgets.add(
        GestureDetector(
          onTap: isLast ? null : () => _navigateToBreadcrumb(i),
          child: Text(
            _breadcrumb[i]['name'] as String,
            style: TextStyle(
              color: isLast ? colors.bulma : colors.piccolo,
              fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _buildFileList(MoonColors colors) {
    final items = _currentItems;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open, size: 48, color: colors.trunks.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text('This folder is empty', style: TextStyle(color: colors.trunks)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final file = items[i] as Map<String, dynamic>;
        final isFolder = file['isFolder'] == true;
        final selected = file['id'] == _selectedFileId;

        return MoonMenuItem(
          onTap: () {
            if (isFolder) {
              _navigateToFolder(file);
            } else {
              setState(() => _selectedFileId = file['id'] as String);
            }
          },
          backgroundColor: selected ? colors.piccolo.withValues(alpha: 0.08) : Colors.transparent,
          leading: Icon(
            isFolder ? Icons.folder_rounded : _fileIcon(file['mimeType'] as String?),
            color: isFolder ? const Color(0xFFF59E0B) : colors.trunks,
            size: 20,
          ),
          label: Text(
            file['name'] as String,
            style: TextStyle(
              color: colors.bulma,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 14,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isFolder && file['size'] != null)
                Text(
                  _formatSize(file['size'] as int),
                  style: TextStyle(color: colors.trunks, fontSize: 11),
                ),
              if (file['isFavorite'] == true) ...[
                const SizedBox(width: 8),
                Icon(Icons.star_rounded, size: 14, color: colors.krillin),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilePreview(MoonColors colors) {
    final file = _files.firstWhere((f) => f['id'] == _selectedFileId, orElse: () => null);
    if (file == null) return const SizedBox.shrink();

    return Container(
      color: colors.goten,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _fileIcon(file['mimeType'] as String?),
                  size: 32,
                  color: colors.piccolo,
                ),
                const SizedBox(height: 12),
                Text(
                  file['name'] as String,
                  style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                if (file['mimeType'] != null)
                  MoonTag(
                    tagSize: MoonTagSize.x2s,
                    backgroundColor: colors.piccolo.withValues(alpha: 0.1),
                    label: Text(file['mimeType'] as String, style: TextStyle(fontSize: 10, color: colors.piccolo)),
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.beerus),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow(colors, 'Size', file['size'] != null ? _formatSize(file['size'] as int) : 'N/A'),
                _detailRow(colors, 'Modified', (file['modifiedAt'] as String).substring(0, 10)),
                _detailRow(colors, 'Created', (file['createdAt'] as String).substring(0, 10)),
                _detailRow(colors, 'Path', file['path'] as String),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(MoonColors colors, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label, style: TextStyle(color: colors.trunks, fontSize: 12)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: colors.bulma, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  IconData _fileIcon(String? mimeType) {
    if (mimeType == null) return Icons.insert_drive_file_outlined;
    if (mimeType.startsWith('image/')) return Icons.image_outlined;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf_outlined;
    if (mimeType.contains('markdown') || mimeType.contains('text')) return Icons.description_outlined;
    if (mimeType.contains('spreadsheet') || mimeType.contains('excel')) return Icons.table_chart_outlined;
    if (mimeType.contains('word') || mimeType.contains('document')) return Icons.article_outlined;
    if (mimeType.contains('yaml') || mimeType.contains('json')) return Icons.code_outlined;
    return Icons.insert_drive_file_outlined;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
