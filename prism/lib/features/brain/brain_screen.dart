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
import '../settings/personas_section.dart';
import '../settings/soul_section.dart';

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
    ('Personas', Icons.person_outline_rounded),
    ('Soul', Icons.auto_awesome_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _isNoteTab => _tabController.index < 4;

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
                if (_isNoteTab) ...[
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
                isScrollable: true,
                tabAlignment: TabAlignment.start,
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
            child: _isNoteTab
                ? LayoutBuilder(
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
                          onDeleted: () =>
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
            )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _tabController.index == 4
                        ? PersonasSection(
                            cardColor: cardColor,
                            borderColor: borderColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            accentColor: accentColor)
                        : SoulDocumentSection(
                            cardColor: cardColor,
                            borderColor: borderColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            accentColor: accentColor),
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
    final bgColor = isDark ? const Color(0xFF16162A) : Colors.white;
    final textPri = isDark ? const Color(0xFFE2E2EC) : const Color(0xFF1A1A2E);
    final textSec = isDark ? const Color(0xFF7A7A90) : const Color(0xFF6B6B80);
    final border = isDark ? const Color(0xFF252540) : const Color(0xFFE2E2EC);

    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    final tagsCtrl = TextEditingController();
    String selectedCategory = _currentCategory;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDS) => AlertDialog(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(children: [
            Icon(Icons.note_add_rounded, size: 20, color: accentColor),
            const SizedBox(width: 8),
            Text('New Note', style: TextStyle(
                color: textPri, fontSize: 16, fontWeight: FontWeight.w600)),
          ]),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category (PARA)
                  Text('Category', style: TextStyle(
                      color: textSec, fontSize: 11, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Wrap(spacing: 6, children: [
                    for (final cat in [('project', 'Projects', Icons.rocket_launch_outlined),
                                       ('area', 'Areas', Icons.layers_outlined),
                                       ('resource', 'Resources', Icons.bookmark_outline_rounded),
                                       ('archive', 'Archives', Icons.archive_outlined)])
                      GestureDetector(
                        onTap: () => setDS(() => selectedCategory = cat.$1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: selectedCategory == cat.$1
                                ? accentColor.withValues(alpha: 0.15) : border.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: selectedCategory == cat.$1 ? accentColor : border,
                                width: selectedCategory == cat.$1 ? 1 : 0.5),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(cat.$3, size: 14,
                                color: selectedCategory == cat.$1 ? accentColor : textSec),
                            const SizedBox(width: 4),
                            Text(cat.$2, style: TextStyle(fontSize: 11,
                                color: selectedCategory == cat.$1 ? accentColor : textSec,
                                fontWeight: selectedCategory == cat.$1 ? FontWeight.w600 : FontWeight.w400)),
                          ]),
                        ),
                      ),
                  ]),
                  const SizedBox(height: 14),
                  _buildTextField(titleCtrl, 'Title', 'Enter note title',
                      textPri, textSec, border, accentColor),
                  const SizedBox(height: 12),
                  _buildTextField(contentCtrl, 'Content', 'Write your note content...',
                      textPri, textSec, border, accentColor, maxLines: 6),
                  const SizedBox(height: 12),
                  _buildTextField(tagsCtrl, 'Tags', 'comma, separated, tags',
                      textPri, textSec, border, accentColor),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel', style: TextStyle(color: textSec))),
            FilledButton(onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: accentColor),
                child: const Text('Save Note')),
          ],
        ),
      ),
    );

    if (confirmed == true && titleCtrl.text.isNotEmpty) {
      final tags = [selectedCategory, ...tagsCtrl.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty)].join(',');
      await db.createNote(
        uuid: const Uuid().v4(),
        title: titleCtrl.text,
        content: contentCtrl.text,
        tags: tags,
      );
    }
  }

  Widget _buildTextField(TextEditingController ctrl, String label, String hint,
      Color textPri, Color textSec, Color border, Color accent, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: textSec, fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl, maxLines: maxLines,
          style: TextStyle(color: textPri, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: textSec.withValues(alpha: 0.5), fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            filled: true, fillColor: border.withValues(alpha: 0.3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: border, width: 0.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: border, width: 0.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: accent, width: 1)),
          ),
        ),
      ],
    );
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

// ─── Note Detail Panel (with edit & delete) ─────────

class _NoteDetail extends ConsumerStatefulWidget {
  final Note note;
  final VoidCallback onClose;
  final VoidCallback onDeleted;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;
  final Color cardColor;
  final Color borderColor;

  const _NoteDetail({
    required this.note,
    required this.onClose,
    required this.onDeleted,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  ConsumerState<_NoteDetail> createState() => _NoteDetailState();
}

class _NoteDetailState extends ConsumerState<_NoteDetail> {
  bool _isEditing = false;
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  late TextEditingController _tagsCtrl;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(covariant _NoteDetail old) {
    super.didUpdateWidget(old);
    if (widget.note.id != old.note.id) {
      _isEditing = false;
      _initControllers();
    }
  }

  void _initControllers() {
    _titleCtrl = TextEditingController(text: widget.note.title);
    _contentCtrl = TextEditingController(text: widget.note.content);
    _tagsCtrl = TextEditingController(text: widget.note.tags);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

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
              const Text('📝', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: _isEditing
                    ? TextField(
                        controller: _titleCtrl,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                            color: widget.textPrimary),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: widget.accentColor)),
                        ),
                      )
                    : Text(widget.note.title, style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600, color: widget.textPrimary)),
              ),
              if (!_isEditing) ...[
                IconButton(
                  onPressed: () => setState(() => _isEditing = true),
                  icon: Icon(Icons.edit_rounded, size: 16, color: widget.textSecondary),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                  tooltip: 'Delete',
                ),
              ],
              IconButton(
                onPressed: widget.onClose,
                icon: Icon(Icons.close_rounded, size: 18, color: widget.textSecondary),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: widget.borderColor),

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
                    Icon(Icons.calendar_today_rounded, size: 12, color: widget.textSecondary),
                    const SizedBox(width: 4),
                    Text(DateFormat('MMMM d, yyyy').format(widget.note.updatedAt),
                        style: TextStyle(fontSize: 12, color: widget.textSecondary)),
                    const SizedBox(width: 12),
                    Icon(Icons.source_outlined, size: 12, color: widget.textSecondary),
                    const SizedBox(width: 4),
                    Text(widget.note.source,
                        style: TextStyle(fontSize: 12, color: widget.textSecondary)),
                  ],
                ),
                const SizedBox(height: 16),

                // Tags
                if (_isEditing) ...[
                  Text('Tags', style: TextStyle(color: widget.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _tagsCtrl,
                    style: TextStyle(color: widget.textPrimary, fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'comma, separated, tags',
                      hintStyle: TextStyle(color: widget.textSecondary.withValues(alpha: 0.5), fontSize: 12),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      filled: true, fillColor: widget.borderColor.withValues(alpha: 0.3),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: widget.borderColor, width: 0.5)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: widget.borderColor, width: 0.5)),
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else if (widget.note.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: widget.note.tags.split(',').map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6)),
                        child: Text(tag.trim(), style: TextStyle(
                            fontSize: 11, color: widget.accentColor, fontWeight: FontWeight.w500)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Content
                if (_isEditing)
                  TextField(
                    controller: _contentCtrl, maxLines: null, minLines: 10,
                    style: TextStyle(fontSize: 13, color: widget.textPrimary, height: 1.6),
                    decoration: InputDecoration(
                      hintText: 'Write note content...',
                      hintStyle: TextStyle(color: widget.textSecondary.withValues(alpha: 0.5), fontSize: 13),
                      contentPadding: const EdgeInsets.all(12),
                      filled: true, fillColor: widget.borderColor.withValues(alpha: 0.3),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: widget.borderColor, width: 0.5)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: widget.borderColor, width: 0.5)),
                    ),
                  )
                else
                  SelectableText(
                    widget.note.content,
                    style: TextStyle(fontSize: 14, color: widget.textPrimary, height: 1.6),
                  ),
              ],
            ),
          ),
        ),

        // Edit action bar
        if (_isEditing)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: widget.borderColor, width: 0.5))),
            child: Row(children: [
              Expanded(child: FilledButton.icon(
                onPressed: _saveNote,
                icon: const Icon(Icons.save_rounded, size: 14),
                label: const Text('Save', style: TextStyle(fontSize: 12)),
                style: FilledButton.styleFrom(backgroundColor: widget.accentColor,
                    foregroundColor: Colors.white, minimumSize: const Size(0, 36)),
              )),
              const SizedBox(width: 8),
              TextButton(onPressed: () {
                _initControllers();
                setState(() => _isEditing = false);
              }, child: Text('Cancel', style: TextStyle(color: widget.textSecondary, fontSize: 12))),
            ]),
          ),
      ],
    );
  }

  Future<void> _saveNote() async {
    await ref.read(databaseProvider).updateNote(
      widget.note.uuid,
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text,
      tags: _tagsCtrl.text.trim(),
    );
    setState(() => _isEditing = false);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note?'),
        content: Text('Delete "${widget.note.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(databaseProvider).deleteNote(widget.note.uuid);
      widget.onDeleted();
    }
  }
}
