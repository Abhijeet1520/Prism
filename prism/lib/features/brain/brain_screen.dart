/// Brain Screen — PARA-method knowledge management with tabs and note grid.
///
/// Matches ux_preview design: PARA tabs (Projects/Areas/Resources/Archives),
/// responsive grid with item cards, note detail panel on wide screens.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/database.dart';

class BrainScreen extends ConsumerStatefulWidget {
  const BrainScreen({super.key});

  @override
  ConsumerState<BrainScreen> createState() => _BrainScreenState();
}

class _BrainScreenState extends ConsumerState<BrainScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _searchQuery = '';
  Note? _selectedNote;

  static const _paraTabs = [
    ('Projects', Icons.rocket_launch_outlined),
    ('Areas', Icons.layers_outlined),
    ('Resources', Icons.bookmark_outline_rounded),
    ('Archives', Icons.archive_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _currentCategory {
    return switch (_tabController.index) {
      0 => 'project',
      1 => 'area',
      2 => 'resource',
      3 => 'archive',
      _ => 'project',
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0C0C16) : const Color(0xFFF5F5FA);
    final cardColor = isDark ? const Color(0xFF16162A) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF252540) : const Color(0xFFE2E2EC);
    final textPrimary =
        isDark ? const Color(0xFFE2E2EC) : const Color(0xFF1A1A2E);
    final textSecondary =
        isDark ? const Color(0xFF7A7A90) : const Color(0xFF6B6B80);
    final accentColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // ─── Header ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
            child: Row(
              children: [
                Text(
                  'Second Brain',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    // Toggle search
                    setState(
                        () => _searchQuery = _searchQuery.isEmpty ? ' ' : '');
                  },
                  icon: Icon(Icons.search_rounded,
                      size: 20, color: textSecondary),
                ),
                const SizedBox(width: 4),
                FilledButton.icon(
                  onPressed: () => _createNote(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add New', style: TextStyle(fontSize: 13)),
                  style: FilledButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ),
          ),

          // ─── Search Bar ──────────────────────────
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor, width: 0.5),
                ),
                child: TextField(
                  autofocus: true,
                  onChanged: (q) => setState(() => _searchQuery = q),
                  decoration: InputDecoration(
                    hintText: 'Search notes...',
                    hintStyle: TextStyle(color: textSecondary, fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded,
                        size: 18, color: textSecondary),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _searchQuery = ''),
                      icon: Icon(Icons.close_rounded,
                          size: 16, color: textSecondary),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  style: TextStyle(color: textPrimary, fontSize: 13),
                ),
              ),
            ),

          // ─── PARA Tabs ───────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor, width: 0.5),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: false,
                labelColor: accentColor,
                unselectedLabelColor: textSecondary,
                labelStyle: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontSize: 12),
                indicator: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: _paraTabs
                    .map((t) => Tab(
                          height: 36,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(t.$2, size: 14),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(t.$1,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),

          const SizedBox(height: 12),
          Divider(height: 1, color: borderColor),

          // ─── Content ─────────────────────────────
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;

                return Row(
                  children: [
                    // Note Grid
                    Expanded(
                      child: _NoteGrid(
                        category: _currentCategory,
                        searchQuery:
                            _searchQuery.trim().isEmpty ? '' : _searchQuery,
                        selectedNote: _selectedNote,
                        onSelect: (note) =>
                            setState(() => _selectedNote = note),
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        accentColor: accentColor,
                        cardColor: cardColor,
                        borderColor: borderColor,
                      ),
                    ),

                    // Detail Panel (wide only)
                    if (isWide && _selectedNote != null) ...[
                      VerticalDivider(width: 1, color: borderColor),
                      SizedBox(
                        width: 360,
                        child: _NoteDetail(
                          note: _selectedNote!,
                          onClose: () =>
                              setState(() => _selectedNote = null),
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          accentColor: accentColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createNote(BuildContext context) async {
    final db = ref.read(databaseProvider);
    final accentColor = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titleController = TextEditingController();
    final contentController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF16162A) : Colors.white,
        title: Text('New Note',
            style: TextStyle(
                color:
                    isDark ? const Color(0xFFE2E2EC) : const Color(0xFF1A1A2E))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                  hintText: 'Title', border: OutlineInputBorder()),
              style: TextStyle(
                  color: isDark
                      ? const Color(0xFFE2E2EC)
                      : const Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              maxLines: 4,
              decoration: const InputDecoration(
                  hintText: 'Content', border: OutlineInputBorder()),
              style: TextStyle(
                  color: isDark
                      ? const Color(0xFFE2E2EC)
                      : const Color(0xFF1A1A2E)),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: accentColor),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed == true && titleController.text.isNotEmpty) {
      await db.createNote(
        uuid: const Uuid().v4(),
        title: titleController.text,
        content: contentController.text,
        tags: _currentCategory,
      );
    }
  }
}

// ─── Note Grid ───────────────────────────────────────

class _NoteGrid extends ConsumerWidget {
  final String category;
  final String searchQuery;
  final Note? selectedNote;
  final ValueChanged<Note> onSelect;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;
  final Color cardColor;
  final Color borderColor;

  const _NoteGrid({
    required this.category,
    required this.searchQuery,
    required this.selectedNote,
    required this.onSelect,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return StreamBuilder<List<Note>>(
      stream: db.watchNotes(),
      builder: (context, snap) {
        final allNotes = snap.data ?? [];
        final filtered = allNotes.where((n) {
          final matchesCategory = n.tags.toLowerCase().contains(category);
          final matchesSearch = searchQuery.isEmpty ||
              n.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              n.content.toLowerCase().contains(searchQuery.toLowerCase());
          return matchesCategory && matchesSearch;
        }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.layers_outlined,
                    size: 48, color: textSecondary.withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                Text(
                  'No ${category}s yet',
                  style: TextStyle(fontSize: 14, color: textSecondary),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 340,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final note = filtered[index];
            final isSelected = note.id == selectedNote?.id;

            return _NoteCard(
              note: note,
              isSelected: isSelected,
              onTap: () => onSelect(note),
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              accentColor: accentColor,
              cardColor: cardColor,
              borderColor: borderColor,
            );
          },
        );
      },
    );
  }
}

// ─── Note Card ───────────────────────────────────────

class _NoteCard extends StatelessWidget {
  final Note note;
  final bool isSelected;
  final VoidCallback onTap;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;
  final Color cardColor;
  final Color borderColor;

  const _NoteCard({
    required this.note,
    required this.isSelected,
    required this.onTap,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accentColor : borderColor,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('📝', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    note.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                note.content,
                style: TextStyle(fontSize: 12, color: textSecondary),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (note.tags.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      note.tags.split(',').first.trim(),
                      style: TextStyle(
                        fontSize: 10,
                        color: accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  DateFormat('MMM d').format(note.updatedAt),
                  style: TextStyle(fontSize: 10, color: textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Note Detail Panel ───────────────────────────────

class _NoteDetail extends StatelessWidget {
  final Note note;
  final VoidCallback onClose;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;
  final Color cardColor;
  final Color borderColor;

  const _NoteDetail({
    required this.note,
    required this.onClose,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
          child: Row(
            children: [
              Text('📝', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  note.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: Icon(Icons.close_rounded,
                    size: 18, color: textSecondary),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: borderColor),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meta info
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 12, color: textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMMM d, yyyy').format(note.updatedAt),
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.source_outlined,
                        size: 12, color: textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      note.source,
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tags
                if (note.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: note.tags.split(',').map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag.trim(),
                          style: TextStyle(
                            fontSize: 11,
                            color: accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Content
                SelectableText(
                  note.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: textPrimary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
