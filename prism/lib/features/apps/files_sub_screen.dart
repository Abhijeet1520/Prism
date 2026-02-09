/// Files sub-screen — breadcrumb-based folder navigation with file details.
///
/// Loads file hierarchy from assets/mock_data/app_data.json and provides
/// navigable folder tree with type-based icons and a detail panel.
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Data Model ──────────────────────────────────────

class _FileNode {
  final String id;
  final String name;
  final String? parentId;
  final bool isFolder;
  final String path;
  final String? mimeType;
  final int? size;
  final String? createdAt;
  final String? modifiedAt;
  final List<_FileNode> children;

  _FileNode({
    required this.id,
    required this.name,
    this.parentId,
    required this.isFolder,
    required this.path,
    this.mimeType,
    this.size,
    this.createdAt,
    this.modifiedAt,
    List<_FileNode>? children,
  }) : children = children ?? [];

  factory _FileNode.fromJson(Map<String, dynamic> j) => _FileNode(
        id: j['id'] as String,
        name: j['name'] as String,
        parentId: j['parentId'] as String?,
        isFolder: j['isFolder'] as bool,
        path: j['path'] as String,
        mimeType: j['mimeType'] as String?,
        size: j['size'] as int?,
        createdAt: j['createdAt'] as String?,
        modifiedAt: j['modifiedAt'] as String?,
      );

  String get sizeFormatted {
    if (size == null) return '--';
    if (size! < 1024) return '$size B';
    if (size! < 1024 * 1024) return '${(size! / 1024).toStringAsFixed(1)} KB';
    return '${(size! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get extension {
    final dot = name.lastIndexOf('.');
    return dot == -1 ? '' : name.substring(dot + 1).toLowerCase();
  }
}

// ─── Widget ──────────────────────────────────────────

class FilesSubScreen extends ConsumerStatefulWidget {
  final bool isDark;
  final Color cardColor, borderColor, textPrimary, textSecondary;

  const FilesSubScreen({
    super.key,
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  ConsumerState<FilesSubScreen> createState() => _FilesSubScreenState();
}

class _FilesSubScreenState extends ConsumerState<FilesSubScreen> {
  List<_FileNode> _allNodes = [];
  _FileNode? _root;

  /// Stack of folder IDs representing the navigation path.
  /// First element is always the root folder.
  List<String> _breadcrumbIds = [];

  /// Currently selected file (non-folder) for the detail panel.
  _FileNode? _selectedFile;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFileData();
  }

  Future<void> _loadFileData() async {
    try {
      final raw =
          await rootBundle.loadString('assets/mock_data/app_data.json');
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final filesJson = json['files'] as List<dynamic>;
      final nodes =
          filesJson.map((e) => _FileNode.fromJson(e as Map<String, dynamic>)).toList();

      // Build parent→children map
      final byId = <String, _FileNode>{};
      for (final n in nodes) {
        byId[n.id] = n;
      }
      for (final n in nodes) {
        if (n.parentId != null && byId.containsKey(n.parentId)) {
          byId[n.parentId]!.children.add(n);
        }
      }

      // Sort children: folders first, then alphabetical
      for (final n in nodes) {
        n.children.sort((a, b) {
          if (a.isFolder != b.isFolder) return a.isFolder ? -1 : 1;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
      }

      final root = nodes.firstWhere((n) => n.parentId == null);

      setState(() {
        _allNodes = nodes;
        _root = root;
        _breadcrumbIds = [root.id];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load file data: $e';
        _loading = false;
      });
    }
  }

  _FileNode? _nodeById(String id) {
    try {
      return _allNodes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  _FileNode get _currentFolder => _nodeById(_breadcrumbIds.last) ?? _root!;

  void _navigateInto(_FileNode folder) {
    setState(() {
      _breadcrumbIds.add(folder.id);
      _selectedFile = null;
    });
  }

  void _navigateToBreadcrumb(int index) {
    setState(() {
      _breadcrumbIds = _breadcrumbIds.sublist(0, index + 1);
      _selectedFile = null;
    });
  }

  void _selectFile(_FileNode file) {
    setState(() => _selectedFile = file);
  }

  IconData _iconFor(_FileNode node) {
    if (node.isFolder) return Icons.folder_rounded;
    return switch (node.extension) {
      'pdf' => Icons.description_rounded,
      'md' => Icons.article_rounded,
      'txt' => Icons.text_snippet_rounded,
      'csv' => Icons.table_chart_rounded,
      'jpg' || 'jpeg' || 'png' || 'gif' || 'webp' || 'svg' =>
        Icons.image_rounded,
      'dart' || 'py' || 'js' || 'ts' || 'sh' => Icons.code_rounded,
      'json' || 'xml' || 'yaml' || 'yml' => Icons.data_object_rounded,
      'zip' || 'tar' || 'gz' => Icons.archive_rounded,
      'mp3' || 'wav' || 'flac' => Icons.audio_file_rounded,
      'mp4' || 'mov' || 'avi' => Icons.video_file_rounded,
      _ => Icons.insert_drive_file_rounded,
    };
  }

  Color _iconColorFor(_FileNode node) {
    if (node.isFolder) return const Color(0xFFF59E0B);
    return switch (node.extension) {
      'pdf' => const Color(0xFFEF4444),
      'md' || 'txt' => const Color(0xFF3B82F6),
      'csv' => const Color(0xFF10B981),
      'jpg' || 'jpeg' || 'png' || 'gif' || 'webp' || 'svg' =>
        const Color(0xFF10B981),
      'dart' || 'py' || 'js' || 'ts' || 'sh' => const Color(0xFF8B5CF6),
      'json' || 'xml' || 'yaml' || 'yml' => const Color(0xFFF59E0B),
      _ => const Color(0xFF6B7280),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null || _root == null) {
      return Center(
        child: Text(_error ?? 'No file data',
            style: TextStyle(color: widget.textSecondary, fontSize: 14)),
      );
    }

    final current = _currentFolder;

    return Column(
      children: [
        // ─── Storage usage ───────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: widget.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.borderColor, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Storage',
                    style: TextStyle(
                        color: widget.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.35,
                    backgroundColor: widget.borderColor,
                    color: Theme.of(context).colorScheme.primary,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Text('1.2 GB of 4.0 GB used',
                    style: TextStyle(
                        color: widget.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ),

        // ─── Breadcrumb navigation ───────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _breadcrumbIds.length,
              separatorBuilder: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(Icons.chevron_right_rounded,
                    size: 16, color: widget.textSecondary),
              ),
              itemBuilder: (context, i) {
                final node = _nodeById(_breadcrumbIds[i]);
                final isLast = i == _breadcrumbIds.length - 1;
                final label = i == 0 ? 'Home' : (node?.name ?? '?');

                return GestureDetector(
                  onTap: isLast ? null : () => _navigateToBreadcrumb(i),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isLast
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.10)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isLast
                              ? Theme.of(context).colorScheme.primary
                              : widget.textSecondary,
                          fontWeight:
                              isLast ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        Divider(height: 1, color: widget.borderColor),

        // ─── File list ───────────────────────────
        Expanded(
          child: current.children.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder_open_rounded,
                          size: 48,
                          color:
                              widget.textSecondary.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      Text('This folder is empty',
                          style: TextStyle(
                              color: widget.textSecondary, fontSize: 14)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  itemCount: current.children.length,
                  itemBuilder: (context, i) {
                    final node = current.children[i];
                    final icon = _iconFor(node);
                    final iconColor = _iconColorFor(node);
                    final isSelected =
                        _selectedFile != null && _selectedFile!.id == node.id;

                    return GestureDetector(
                      onTap: () {
                        if (node.isFolder) {
                          _navigateInto(node);
                        } else {
                          _selectFile(node);
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.08)
                              : widget.cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.3)
                                : widget.borderColor,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: iconColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child:
                                  Icon(icon, color: iconColor, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(node.name,
                                      style: TextStyle(
                                          color: widget.textPrimary,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14)),
                                  if (!node.isFolder)
                                    Text(
                                      '${node.sizeFormatted}  •  ${node.modifiedAt ?? ''}',
                                      style: TextStyle(
                                          color: widget.textSecondary,
                                          fontSize: 11),
                                    ),
                                  if (node.isFolder)
                                    Text(
                                      '${node.children.length} item${node.children.length == 1 ? '' : 's'}',
                                      style: TextStyle(
                                          color: widget.textSecondary,
                                          fontSize: 11),
                                    ),
                                ],
                              ),
                            ),
                            Icon(
                              node.isFolder
                                  ? Icons.chevron_right_rounded
                                  : Icons.info_outline_rounded,
                              size: 18,
                              color: widget.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        // ─── File detail panel ───────────────────
        if (_selectedFile != null) _buildDetailPanel(_selectedFile!),
      ],
    );
  }

  Widget _buildDetailPanel(_FileNode file) {
    final iconColor = _iconColorFor(file);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.cardColor,
        border: Border(
          top: BorderSide(color: widget.borderColor, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag indicator
          Container(
            width: 32,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: widget.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_iconFor(file), color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(file.name,
                        style: TextStyle(
                            color: widget.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(file.path,
                        style: TextStyle(
                            color: widget.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _selectedFile = null),
                icon: Icon(Icons.close_rounded,
                    size: 18, color: widget.textSecondary),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _detailChip('Size', file.sizeFormatted),
              const SizedBox(width: 8),
              _detailChip('Modified', file.modifiedAt ?? '--'),
              const SizedBox(width: 8),
              _detailChip(
                  'Type', file.extension.isNotEmpty ? '.${file.extension}' : 'folder'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailChip(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: widget.isDark
              ? const Color(0xFF1E1E36)
              : const Color(0xFFF0F0F8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(
                    color: widget.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: widget.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
