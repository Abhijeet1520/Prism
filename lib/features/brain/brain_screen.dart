/// Brain Screen — Simplified Notes-only Knowledge Base with Search & Tag Filters.
///
/// Three tabs: Knowledge (notes), Personas, Soul
/// Knowledge panel features:
/// - Search bar for filtering notes
/// - Tag filter chips (extracted from all notes)
/// - Responsive notes grid with detail panel
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/database.dart';
import '../settings/personas_section.dart';
import '../settings/soul_section.dart';

const _uuid = Uuid();

class BrainScreen extends ConsumerStatefulWidget {
  const BrainScreen({super.key});

  @override
  ConsumerState<BrainScreen> createState() => _BrainScreenState();
}

class _BrainScreenState extends ConsumerState<BrainScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [
    ('Knowledge', Icons.auto_stories_outlined),
    ('Personas', Icons.person_outline_rounded),
    ('Soul', Icons.auto_awesome_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0C0C16) : const Color(0xFFF5F5FA);
    final cardColor = isDark ? const Color(0xFF16162A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF252540) : const Color(0xFFE2E2EC);
    final textPrimary = isDark ? const Color(0xFFE2E2EC) : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? const Color(0xFF7A7A90) : const Color(0xFF6B6B80);
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
              ],
            ),
          ),

          // ─── Tabs ────────────────────────────────
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
                labelColor: accentColor,
                unselectedLabelColor: textSecondary,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontSize: 12),
                indicator: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: _tabs.map((t) => Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(t.$2, size: 16),
                      const SizedBox(width: 6),
                      Text(t.$1),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),

          // ─── Tab Content ─────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Knowledge Tab
                  _KnowledgePanel(
                    isDark: isDark,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    accentColor: accentColor,
                  ),
                  // Personas Tab
                  PersonasSection(
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    accentColor: accentColor,
                  ),
                  // Soul Tab
                  SoulDocumentSection(
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    accentColor: accentColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// KNOWLEDGE PANEL — Notes with Search & Tag Filters
// ============================================================================

class _KnowledgePanel extends ConsumerStatefulWidget {
  final bool isDark;
  final Color cardColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;

  const _KnowledgePanel({
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
  });

  @override
  ConsumerState<_KnowledgePanel> createState() => _KnowledgePanelState();
}

class _KnowledgePanelState extends ConsumerState<_KnowledgePanel> {
  String _searchQuery = '';
  Set<String> _selectedTags = {};
  int? _expandedNoteIndex;
  final TextEditingController _searchController = TextEditingController();

  // Controllers for inline editing
  TextEditingController? _titleController;
  TextEditingController? _contentController;
  TextEditingController? _tagsController;
  bool _hasChanges = false;

  @override
  void dispose() {
    _searchController.dispose();
    _titleController?.dispose();
    _contentController?.dispose();
    _tagsController?.dispose();
    super.dispose();
  }

  void _initEditControllers(Note note) {
    _titleController?.dispose();
    _contentController?.dispose();
    _tagsController?.dispose();
    _titleController = TextEditingController(text: note.title);
    _contentController = TextEditingController(text: note.content ?? '');
    _tagsController = TextEditingController(text: note.tags ?? '');
    _hasChanges = false;
  }

  /// Extract all unique tags from notes
  List<String> _extractAllTags(List<Note> notes) {
    final tags = <String>{};
    for (final note in notes) {
      if (note.tags != null && note.tags!.isNotEmpty) {
        for (final tag in note.tags!.split(',')) {
          final trimmed = tag.trim();
          if (trimmed.isNotEmpty) tags.add(trimmed);
        }
      }
    }
    return tags.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  /// Filter notes by search query and selected tags
  List<Note> _filterNotes(List<Note> notes) {
    return notes.where((note) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = note.title.toLowerCase().contains(query);
        final matchesContent = note.content?.toLowerCase().contains(query) ?? false;
        final matchesTags = note.tags?.toLowerCase().contains(query) ?? false;
        if (!matchesTitle && !matchesContent && !matchesTags) return false;
      }
      // Tag filter
      if (_selectedTags.isNotEmpty) {
        if (note.tags == null || note.tags!.isEmpty) return false;
        final noteTags = note.tags!.split(',').map((t) => t.trim().toLowerCase()).toSet();
        final hasTag = _selectedTags.any((selected) => noteTags.contains(selected.toLowerCase()));
        if (!hasTag) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);

    return StreamBuilder<List<Note>>(
      stream: db.watchNotes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: widget.textSecondary)));
        }

        final notes = snapshot.data ?? [];
        final allTags = _extractAllTags(notes);
        final filteredNotes = _filterNotes(notes);

        // Reset expanded index if note no longer exists
        if (_expandedNoteIndex != null && _expandedNoteIndex! >= filteredNotes.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _expandedNoteIndex = null);
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            _buildSearchBar(),
            const SizedBox(height: 12),

            // Tag filters
            if (allTags.isNotEmpty) ...[
              _buildTagFilters(allTags),
              const SizedBox(height: 12),
            ],

            // Notes header with count and add button
            _buildNotesHeader(filteredNotes.length, notes.isEmpty),

            const SizedBox(height: 8),

            // Notes list
            Expanded(
              child: filteredNotes.isEmpty
                  ? _buildEmptyState(notes.isEmpty)
                  : _buildNotesList(filteredNotes),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: widget.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.borderColor, width: 0.5),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: widget.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search notes...',
          hintStyle: TextStyle(color: widget.textSecondary.withValues(alpha: 0.6)),
          prefixIcon: Icon(Icons.search_rounded, color: widget.textSecondary, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: widget.textSecondary, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildTagFilters(List<String> allTags) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Clear filters button
          if (_selectedTags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: Text('Clear', style: TextStyle(fontSize: 12, color: widget.textSecondary)),
                avatar: Icon(Icons.close_rounded, size: 14, color: widget.textSecondary),
                backgroundColor: widget.borderColor.withValues(alpha: 0.3),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                onPressed: () => setState(() => _selectedTags.clear()),
              ),
            ),
          // Tag chips
          ...allTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(tag, style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : widget.textPrimary,
                )),
                selected: isSelected,
                selectedColor: widget.accentColor,
                backgroundColor: widget.cardColor,
                checkmarkColor: Colors.white,
                side: BorderSide(color: isSelected ? widget.accentColor : widget.borderColor, width: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNotesHeader(int count, bool isEmpty) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$count note${count == 1 ? '' : 's'}${_searchQuery.isNotEmpty || _selectedTags.isNotEmpty ? ' found' : ''}',
          style: TextStyle(color: widget.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: widget.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.add_rounded, color: widget.accentColor, size: 18),
          ),
          tooltip: 'Add Note',
          onPressed: () => _showCreateNoteDialog(),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool noNotes) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            noNotes ? Icons.note_alt_outlined : Icons.search_off_rounded,
            size: 48,
            color: widget.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            noNotes ? 'No notes yet' : 'No notes match your filters',
            style: TextStyle(color: widget.textSecondary, fontSize: 14),
          ),
          if (noNotes) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _showCreateNoteDialog(),
              icon: Icon(Icons.add_rounded, size: 18, color: widget.accentColor),
              label: Text('Create your first note', style: TextStyle(color: widget.accentColor)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesList(List<Note> notes) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        final isExpanded = _expandedNoteIndex == index;

        return Column(
          children: [
            // Note header row
            GestureDetector(
              onTap: () {
                if (isExpanded) {
                  setState(() => _expandedNoteIndex = null);
                } else {
                  _initEditControllers(note);
                  setState(() => _expandedNoteIndex = index);
                }
              },
              child: Container(
                margin: EdgeInsets.only(bottom: isExpanded ? 0 : 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.cardColor,
                  borderRadius: isExpanded
                      ? const BorderRadius.vertical(top: Radius.circular(10))
                      : BorderRadius.circular(10),
                  border: Border.all(
                    color: isExpanded ? widget.accentColor.withValues(alpha: 0.4) : widget.borderColor,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: widget.accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.note_rounded, color: widget.accentColor, size: 18),
                    ),
                    const SizedBox(width: 12),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: widget.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            note.content?.isNotEmpty == true ? note.content! : 'No content',
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Date
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat('MMM d').format(note.updatedAt),
                          style: TextStyle(fontSize: 11, color: widget.textSecondary.withValues(alpha: 0.7)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('yyyy').format(note.updatedAt),
                          style: TextStyle(fontSize: 10, color: widget.textSecondary.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      size: 20,
                      color: widget.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            // Inline edit panel
            if (isExpanded)
              _buildInlineNoteEditor(note, index),
          ],
        );
      },
    );
  }

  Widget _buildInlineNoteEditor(Note note, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      decoration: BoxDecoration(
        color: widget.cardColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
        border: Border.all(color: widget.accentColor.withValues(alpha: 0.4), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          // Title
          Text('Title', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: widget.textSecondary)),
          const SizedBox(height: 4),
          TextField(
            controller: _titleController,
            style: TextStyle(fontSize: 14, color: widget.textPrimary, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Note title',
              hintStyle: TextStyle(color: widget.textSecondary.withValues(alpha: 0.5)),
              filled: true,
              fillColor: widget.borderColor.withValues(alpha: 0.3),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: (_) => setState(() => _hasChanges = true),
          ),
          const SizedBox(height: 10),

          // Content
          Text('Content', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: widget.textSecondary)),
          const SizedBox(height: 4),
          TextField(
            controller: _contentController,
            maxLines: 4,
            style: TextStyle(fontSize: 13, color: widget.textPrimary, height: 1.4),
            decoration: InputDecoration(
              hintText: 'Write your note...',
              hintStyle: TextStyle(color: widget.textSecondary.withValues(alpha: 0.5)),
              filled: true,
              fillColor: widget.borderColor.withValues(alpha: 0.3),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(12),
            ),
            onChanged: (_) => setState(() => _hasChanges = true),
          ),
          const SizedBox(height: 10),

          // Tags
          Text('Tags', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: widget.textSecondary)),
          const SizedBox(height: 4),
          TextField(
            controller: _tagsController,
            style: TextStyle(fontSize: 13, color: widget.textPrimary),
            decoration: InputDecoration(
              hintText: 'comma, separated, tags',
              hintStyle: TextStyle(color: widget.textSecondary.withValues(alpha: 0.5), fontSize: 13),
              filled: true,
              fillColor: widget.borderColor.withValues(alpha: 0.3),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: (_) => setState(() => _hasChanges = true),
          ),
          const SizedBox(height: 12),

          Divider(color: widget.borderColor, height: 1),
          const SizedBox(height: 8),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: _hasChanges ? () async {
                    final db = ref.read(databaseProvider);
                    await db.updateNote(
                      note.uuid,
                      title: _titleController!.text.trim(),
                      content: _contentController!.text,
                      tags: _tagsController!.text.trim(),
                    );
                    if (mounted) {
                      setState(() {
                        _hasChanges = false;
                        _expandedNoteIndex = null;
                      });
                    }
                  } : null,
                  icon: Icon(Icons.check_rounded, size: 16, color: _hasChanges ? Colors.green : widget.textSecondary),
                  label: Text('Save', style: TextStyle(fontSize: 12, color: _hasChanges ? Colors.green : widget.textSecondary)),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: widget.cardColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        title: Text('Delete Note?', style: TextStyle(color: widget.textPrimary, fontSize: 16)),
                        content: Text('This action cannot be undone.', style: TextStyle(color: widget.textSecondary, fontSize: 14)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text('Cancel', style: TextStyle(color: widget.textSecondary)),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: FilledButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      final db = ref.read(databaseProvider);
                      await db.deleteNote(note.uuid);
                      if (mounted) setState(() => _expandedNoteIndex = null);
                    }
                  },
                  icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                  label: const Text('Delete', style: TextStyle(fontSize: 12, color: Color(0xFFEF4444))),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateNoteDialog() async {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    final tagsCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.note_add_rounded, size: 20, color: widget.accentColor),
            const SizedBox(width: 8),
            Text('New Note', style: TextStyle(color: widget.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DialogTextField(
                  controller: titleCtrl,
                  label: 'Title',
                  hint: 'Note title',
                  multiline: false,
                  textPrimary: widget.textPrimary,
                  textSecondary: widget.textSecondary,
                  borderColor: widget.borderColor,
                  accentColor: widget.accentColor,
                ),
                const SizedBox(height: 12),
                _DialogTextField(
                  controller: contentCtrl,
                  label: 'Content',
                  hint: 'Write your note...',
                  multiline: true,
                  maxLines: 6,
                  textPrimary: widget.textPrimary,
                  textSecondary: widget.textSecondary,
                  borderColor: widget.borderColor,
                  accentColor: widget.accentColor,
                ),
                const SizedBox(height: 12),
                _DialogTextField(
                  controller: tagsCtrl,
                  label: 'Tags',
                  hint: 'comma, separated, tags',
                  multiline: false,
                  textPrimary: widget.textPrimary,
                  textSecondary: widget.textSecondary,
                  borderColor: widget.borderColor,
                  accentColor: widget.accentColor,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: widget.textSecondary)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: widget.accentColor),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (confirmed == true && titleCtrl.text.trim().isNotEmpty) {
      final db = ref.read(databaseProvider);
      await db.createNote(
        uuid: _uuid.v4(),
        title: titleCtrl.text.trim(),
        content: contentCtrl.text,
        tags: tagsCtrl.text.trim(),
      );
    }
  }
}

// ============================================================================
// DIALOG TEXT FIELD HELPER
// ============================================================================

class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool multiline;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderColor;
  final Color accentColor;
  final int maxLines;

  const _DialogTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.multiline,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderColor,
    required this.accentColor,
    this.maxLines = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: multiline ? maxLines : 1,
          style: TextStyle(color: textPrimary, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.5), fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            filled: true,
            fillColor: borderColor.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: accentColor, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
