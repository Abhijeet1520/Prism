/// Brain Screen — Unified Areas → Resources → Notes hierarchy.
///
/// Three-panel layout with many-to-many relationships:
/// - Areas can contain multiple Resources
/// - Resources can contain multiple Notes
/// - Notes/Resources can belong to multiple parents
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

  // Selection state for hierarchy
  Set<int> _selectedAreaIds = {};
  Set<int> _selectedResourceIds = {};
  Note? _selectedNote;

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
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: _tabs
                    .map((t) => Tab(
                          height: 36,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(t.$2, size: 14),
                              const SizedBox(width: 4),
                              Text(t.$1),
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
            child: _tabController.index == 0
                ? _KnowledgePanel(
                    selectedAreaIds: _selectedAreaIds,
                    selectedResourceIds: _selectedResourceIds,
                    selectedNote: _selectedNote,
                    onAreasChanged: (ids) => setState(() {
                      _selectedAreaIds = ids;
                      _selectedResourceIds = {};
                      _selectedNote = null;
                    }),
                    onResourcesChanged: (ids) => setState(() {
                      _selectedResourceIds = ids;
                      _selectedNote = null;
                    }),
                    onNoteSelected: (note) => setState(() => _selectedNote = note),
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    accentColor: accentColor,
                    cardColor: cardColor,
                    borderColor: borderColor,
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _tabController.index == 1
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
}

// ─── Knowledge Panel (Areas → Resources → Notes) ─────

class _KnowledgePanel extends ConsumerWidget {
  final Set<int> selectedAreaIds;
  final Set<int> selectedResourceIds;
  final Note? selectedNote;
  final ValueChanged<Set<int>> onAreasChanged;
  final ValueChanged<Set<int>> onResourcesChanged;
  final ValueChanged<Note?> onNoteSelected;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;
  final Color cardColor;
  final Color borderColor;

  const _KnowledgePanel({
    required this.selectedAreaIds,
    required this.selectedResourceIds,
    required this.selectedNote,
    required this.onAreasChanged,
    required this.onResourcesChanged,
    required this.onNoteSelected,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final isMedium = constraints.maxWidth > 600;

        if (isWide) {
          // 3-column layout
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Areas column
              SizedBox(
                width: 240,
                child: _AreasColumn(
                  selectedIds: selectedAreaIds,
                  onSelectionChanged: onAreasChanged,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  accentColor: accentColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
              ),
              VerticalDivider(width: 1, color: borderColor),
              // Resources column
              SizedBox(
                width: 280,
                child: _ResourcesColumn(
                  selectedAreaIds: selectedAreaIds,
                  selectedResourceIds: selectedResourceIds,
                  onSelectionChanged: onResourcesChanged,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  accentColor: accentColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
              ),
              VerticalDivider(width: 1, color: borderColor),
              // Notes column
              Expanded(
                child: _NotesColumn(
                  selectedResourceIds: selectedResourceIds,
                  selectedNote: selectedNote,
                  onNoteSelected: onNoteSelected,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  accentColor: accentColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
              ),
            ],
          );
        } else if (isMedium) {
          // 2-column: Areas+Resources on left, Notes on right
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 280,
                child: _CompactAreasResources(
                  selectedAreaIds: selectedAreaIds,
                  selectedResourceIds: selectedResourceIds,
                  onAreasChanged: onAreasChanged,
                  onResourcesChanged: onResourcesChanged,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  accentColor: accentColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
              ),
              VerticalDivider(width: 1, color: borderColor),
              Expanded(
                child: _NotesColumn(
                  selectedResourceIds: selectedResourceIds,
                  selectedNote: selectedNote,
                  onNoteSelected: onNoteSelected,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  accentColor: accentColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
              ),
            ],
          );
        } else {
          // Single column with expandable sections
          return _MobileKnowledgeView(
            selectedAreaIds: selectedAreaIds,
            selectedResourceIds: selectedResourceIds,
            selectedNote: selectedNote,
            onAreasChanged: onAreasChanged,
            onResourcesChanged: onResourcesChanged,
            onNoteSelected: onNoteSelected,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            accentColor: accentColor,
            cardColor: cardColor,
            borderColor: borderColor,
          );
        }
      },
    );
  }
}

// ─── Areas Column ────────────────────────────────────

class _AreasColumn extends ConsumerWidget {
  final Set<int> selectedIds;
  final ValueChanged<Set<int>> onSelectionChanged;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;
  final Color cardColor;
  final Color borderColor;

  const _AreasColumn({
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: Row(
            children: [
              Icon(Icons.layers_outlined, size: 16, color: accentColor),
              const SizedBox(width: 6),
              Text('Areas', style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
              const Spacer(),
              _AddButton(
                onPressed: () => _createArea(context, ref),
                color: accentColor,
              ),
            ],
          ),
        ),
        Divider(height: 1, color: borderColor),

        // List
        Expanded(
          child: StreamBuilder<List<Area>>(
            stream: db.watchAreas(),
            builder: (context, snap) {
              final areas = snap.data ?? [];
              if (areas.isEmpty) {
                return _EmptyState(
                  icon: Icons.layers_outlined,
                  message: 'No areas yet',
                  textSecondary: textSecondary,
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: areas.length,
                itemBuilder: (context, i) {
                  final area = areas[i];
                  final isSelected = selectedIds.contains(area.id);
                  return _AreaTile(
                    area: area,
                    isSelected: isSelected,
                    onTap: () {
                      final newSet = Set<int>.from(selectedIds);
                      if (isSelected) {
                        newSet.remove(area.id);
                      } else {
                        newSet.add(area.id);
                      }
                      onSelectionChanged(newSet);
                    },
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    accentColor: accentColor,
                    borderColor: borderColor,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _createArea(BuildContext context, WidgetRef ref) async {
    final result = await _showCreateDialog(
      context: context,
      title: 'New Area',
      icon: Icons.layers_outlined,
      fields: [
        ('Name', 'Area name', false),
        ('Description', 'Optional description', true),
      ],
    );
    if (result != null && result['Name']!.isNotEmpty) {
      await ref.read(databaseProvider).createArea(
        uuid: const Uuid().v4(),
        name: result['Name']!,
        description: result['Description'] ?? '',
      );
    }
  }
}

class _AreaTile extends StatelessWidget {
  final Area area;
  final bool isSelected;
  final VoidCallback onTap;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;
  final Color borderColor;

  const _AreaTile({
    required this.area,
    required this.isSelected,
    required this.onTap,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isSelected ? accentColor.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Color(area.color),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        area.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? accentColor : textPrimary,
                        ),
                      ),
                      if (area.description.isNotEmpty)
                        Text(
                          area.description,
                          style: TextStyle(fontSize: 11, color: textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_rounded, size: 16, color: accentColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Resources Column ────────────────────────────────

class _ResourcesColumn extends ConsumerWidget {
  final Set<int> selectedAreaIds;
  final Set<int> selectedResourceIds;
  final ValueChanged<Set<int>> onSelectionChanged;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;
  final Color cardColor;
  final Color borderColor;

  const _ResourcesColumn({
    required this.selectedAreaIds,
    required this.selectedResourceIds,
    required this.onSelectionChanged,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: Row(
            children: [
              Icon(Icons.bookmark_outline_rounded, size: 16, color: accentColor),
              const SizedBox(width: 6),
              Text('Resources', style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
              const Spacer(),
              _AddButton(
                onPressed: () => _createResource(context, ref),
                color: accentColor,
              ),
            ],
          ),
        ),
        Divider(height: 1, color: borderColor),

        // Filter info
        if (selectedAreaIds.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: accentColor.withValues(alpha: 0.05),
            child: Row(
              children: [
                Icon(Icons.filter_alt_outlined, size: 12, color: textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Filtered by ${selectedAreaIds.length} area(s)',
                  style: TextStyle(fontSize: 11, color: textSecondary),
                ),
              ],
            ),
          ),

        // List
        Expanded(
          child: StreamBuilder<List<Resource>>(
            stream: db.watchResources(),
            builder: (context, snap) {
              final allResources = snap.data ?? [];

              return FutureBuilder<List<Resource>>(
                future: _filterResources(db, allResources),
                builder: (context, filterSnap) {
                  final resources = filterSnap.data ?? allResources;

                  if (resources.isEmpty) {
                    return _EmptyState(
                      icon: Icons.bookmark_outline_rounded,
                      message: selectedAreaIds.isEmpty
                          ? 'No resources yet'
                          : 'No resources in selected areas',
                      textSecondary: textSecondary,
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: resources.length,
                    itemBuilder: (context, i) {
                      final resource = resources[i];
                      final isSelected = selectedResourceIds.contains(resource.id);
                      return _ResourceTile(
                        resource: resource,
                        isSelected: isSelected,
                        onTap: () {
                          final newSet = Set<int>.from(selectedResourceIds);
                          if (isSelected) {
                            newSet.remove(resource.id);
                          } else {
                            newSet.add(resource.id);
                          }
                          onSelectionChanged(newSet);
                        },
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        accentColor: accentColor,
                        borderColor: borderColor,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<List<Resource>> _filterResources(PrismDatabase db, List<Resource> all) async {
    if (selectedAreaIds.isEmpty) return all;

    final filtered = <Resource>[];
    for (final resource in all) {
      final areas = await db.getAreasForResource(resource.id);
      if (areas.any((a) => selectedAreaIds.contains(a.id))) {
        filtered.add(resource);
      }
    }
    return filtered;
  }

  Future<void> _createResource(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final areas = await db.watchAreas().first;

    final result = await _showCreateResourceDialog(
      context: context,
      areas: areas,
      selectedAreaIds: selectedAreaIds,
    );

    if (result != null && result.$1.isNotEmpty) {
      final resourceId = await db.createResource(
        uuid: const Uuid().v4(),
        name: result.$1,
        description: result.$2,
      );
      // Link to selected areas
      for (final areaId in result.$3) {
        await db.linkResourceToArea(resourceId, areaId);
      }
    }
  }
}

class _ResourceTile extends StatelessWidget {
  final Resource resource;
  final bool isSelected;
  final VoidCallback onTap;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;
  final Color borderColor;

  const _ResourceTile({
    required this.resource,
    required this.isSelected,
    required this.onTap,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isSelected ? accentColor.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  Icons.bookmark_rounded,
                  size: 16,
                  color: isSelected ? accentColor : textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resource.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? accentColor : textPrimary,
                        ),
                      ),
                      if (resource.description.isNotEmpty)
                        Text(
                          resource.description,
                          style: TextStyle(fontSize: 11, color: textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_rounded, size: 16, color: accentColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Notes Column ────────────────────────────────────

class _NotesColumn extends ConsumerWidget {
  final Set<int> selectedResourceIds;
  final Note? selectedNote;
  final ValueChanged<Note?> onNoteSelected;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;
  final Color cardColor;
  final Color borderColor;

  const _NotesColumn({
    required this.selectedResourceIds,
    required this.selectedNote,
    required this.onNoteSelected,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: Row(
            children: [
              Icon(Icons.note_alt_outlined, size: 16, color: accentColor),
              const SizedBox(width: 6),
              Text('Notes', style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
              const Spacer(),
              _AddButton(
                onPressed: () => _createNote(context, ref),
                color: accentColor,
              ),
            ],
          ),
        ),
        Divider(height: 1, color: borderColor),

        // Filter info
        if (selectedResourceIds.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: accentColor.withValues(alpha: 0.05),
            child: Row(
              children: [
                Icon(Icons.filter_alt_outlined, size: 12, color: textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Filtered by ${selectedResourceIds.length} resource(s)',
                  style: TextStyle(fontSize: 11, color: textSecondary),
                ),
              ],
            ),
          ),

        // Content area
        Expanded(
          child: selectedNote != null
              ? _NoteDetailView(
                  note: selectedNote!,
                  onClose: () => onNoteSelected(null),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  accentColor: accentColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                )
              : StreamBuilder<List<Note>>(
                  stream: db.watchNotes(),
                  builder: (context, snap) {
                    final allNotes = snap.data ?? [];

                    return FutureBuilder<List<Note>>(
                      future: _filterNotes(db, allNotes),
                      builder: (context, filterSnap) {
                        final notes = filterSnap.data ?? allNotes;

                        if (notes.isEmpty) {
                          return _EmptyState(
                            icon: Icons.note_alt_outlined,
                            message: selectedResourceIds.isEmpty
                                ? 'No notes yet'
                                : 'No notes in selected resources',
                            textSecondary: textSecondary,
                          );
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 280,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1.4,
                          ),
                          itemCount: notes.length,
                          itemBuilder: (context, i) {
                            final note = notes[i];
                            return _NoteCard(
                              note: note,
                              onTap: () => onNoteSelected(note),
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
                  },
                ),
        ),
      ],
    );
  }

  Future<List<Note>> _filterNotes(PrismDatabase db, List<Note> all) async {
    if (selectedResourceIds.isEmpty) return all;

    final filtered = <Note>[];
    for (final note in all) {
      final resources = await db.getResourcesForNote(note.id);
      if (resources.any((r) => selectedResourceIds.contains(r.id))) {
        filtered.add(note);
      }
    }
    return filtered;
  }

  Future<void> _createNote(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final resources = await db.watchResources().first;

    final result = await _showCreateNoteDialog(
      context: context,
      resources: resources,
      selectedResourceIds: selectedResourceIds,
    );

    if (result != null && result.$1.isNotEmpty) {
      final noteId = await db.createNote(
        uuid: const Uuid().v4(),
        title: result.$1,
        content: result.$2,
        tags: result.$3,
      );
      // Link to selected resources
      for (final resourceId in result.$4) {
        await db.linkNoteToResource(noteId, resourceId);
      }
    }
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;
  final Color cardColor;
  final Color borderColor;

  const _NoteCard({
    required this.note,
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('📝', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    note.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                note.content,
                style: TextStyle(fontSize: 11, color: textSecondary, height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                if (note.tags.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      note.tags.split(',').first.trim(),
                      style: TextStyle(fontSize: 9, color: accentColor, fontWeight: FontWeight.w500),
                    ),
                  ),
                const Spacer(),
                Text(
                  DateFormat('MMM d').format(note.updatedAt),
                  style: TextStyle(fontSize: 9, color: textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Note Detail View ────────────────────────────────

class _NoteDetailView extends ConsumerStatefulWidget {
  final Note note;
  final VoidCallback onClose;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;
  final Color cardColor;
  final Color borderColor;

  const _NoteDetailView({
    required this.note,
    required this.onClose,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  ConsumerState<_NoteDetailView> createState() => _NoteDetailViewState();
}

class _NoteDetailViewState extends ConsumerState<_NoteDetailView> {
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
  void didUpdateWidget(covariant _NoteDetailView old) {
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
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: Row(
            children: [
              IconButton(
                onPressed: widget.onClose,
                icon: Icon(Icons.arrow_back_rounded, size: 18, color: widget.textSecondary),
                tooltip: 'Back to notes',
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _isEditing
                    ? TextField(
                        controller: _titleCtrl,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: widget.textPrimary,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: widget.accentColor),
                          ),
                        ),
                      )
                    : Text(
                        widget.note.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: widget.textPrimary,
                        ),
                      ),
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
                    Text(
                      DateFormat('MMMM d, yyyy').format(widget.note.updatedAt),
                      style: TextStyle(fontSize: 11, color: widget.textSecondary),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.source_outlined, size: 12, color: widget.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      widget.note.source,
                      style: TextStyle(fontSize: 11, color: widget.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Tags
                if (_isEditing) ...[
                  Text('Tags', style: TextStyle(
                    color: widget.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _tagsCtrl,
                    style: TextStyle(color: widget.textPrimary, fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'comma, separated, tags',
                      hintStyle: TextStyle(color: widget.textSecondary.withValues(alpha: 0.5), fontSize: 12),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      filled: true,
                      fillColor: widget.borderColor.withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: widget.borderColor, width: 0.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: widget.borderColor, width: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else if (widget.note.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget.note.tags.split(',').map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag.trim(),
                          style: TextStyle(
                            fontSize: 11,
                            color: widget.accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                ],

                // Content
                if (_isEditing)
                  TextField(
                    controller: _contentCtrl,
                    maxLines: null,
                    minLines: 10,
                    style: TextStyle(fontSize: 13, color: widget.textPrimary, height: 1.6),
                    decoration: InputDecoration(
                      hintText: 'Write note content...',
                      hintStyle: TextStyle(color: widget.textSecondary.withValues(alpha: 0.5), fontSize: 13),
                      contentPadding: const EdgeInsets.all(12),
                      filled: true,
                      fillColor: widget.borderColor.withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: widget.borderColor, width: 0.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: widget.borderColor, width: 0.5),
                      ),
                    ),
                  )
                else
                  SelectableText(
                    widget.note.content,
                    style: TextStyle(fontSize: 13, color: widget.textPrimary, height: 1.6),
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
              border: Border(top: BorderSide(color: widget.borderColor, width: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _saveNote,
                    icon: const Icon(Icons.save_rounded, size: 14),
                    label: const Text('Save', style: TextStyle(fontSize: 12)),
                    style: FilledButton.styleFrom(
                      backgroundColor: widget.accentColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    _initControllers();
                    setState(() => _isEditing = false);
                  },
                  child: Text('Cancel', style: TextStyle(color: widget.textSecondary, fontSize: 12)),
                ),
              ],
            ),
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
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(databaseProvider).deleteNote(widget.note.uuid);
      widget.onClose();
    }
  }
}

// ─── Compact Areas + Resources (Medium screens) ──────

class _CompactAreasResources extends ConsumerWidget {
  final Set<int> selectedAreaIds;
  final Set<int> selectedResourceIds;
  final ValueChanged<Set<int>> onAreasChanged;
  final ValueChanged<Set<int>> onResourcesChanged;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;
  final Color cardColor;
  final Color borderColor;

  const _CompactAreasResources({
    required this.selectedAreaIds,
    required this.selectedResourceIds,
    required this.onAreasChanged,
    required this.onResourcesChanged,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(
          child: _AreasColumn(
            selectedIds: selectedAreaIds,
            onSelectionChanged: onAreasChanged,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            accentColor: accentColor,
            cardColor: cardColor,
            borderColor: borderColor,
          ),
        ),
        Divider(height: 1, color: borderColor),
        Expanded(
          child: _ResourcesColumn(
            selectedAreaIds: selectedAreaIds,
            selectedResourceIds: selectedResourceIds,
            onSelectionChanged: onResourcesChanged,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            accentColor: accentColor,
            cardColor: cardColor,
            borderColor: borderColor,
          ),
        ),
      ],
    );
  }
}

// ─── Mobile Knowledge View ───────────────────────────

class _MobileKnowledgeView extends ConsumerStatefulWidget {
  final Set<int> selectedAreaIds;
  final Set<int> selectedResourceIds;
  final Note? selectedNote;
  final ValueChanged<Set<int>> onAreasChanged;
  final ValueChanged<Set<int>> onResourcesChanged;
  final ValueChanged<Note?> onNoteSelected;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;
  final Color cardColor;
  final Color borderColor;

  const _MobileKnowledgeView({
    required this.selectedAreaIds,
    required this.selectedResourceIds,
    required this.selectedNote,
    required this.onAreasChanged,
    required this.onResourcesChanged,
    required this.onNoteSelected,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  ConsumerState<_MobileKnowledgeView> createState() => _MobileKnowledgeViewState();
}

class _MobileKnowledgeViewState extends ConsumerState<_MobileKnowledgeView> {
  int _expandedSection = 2; // 0=areas, 1=resources, 2=notes

  @override
  Widget build(BuildContext context) {
    if (widget.selectedNote != null) {
      return _NoteDetailView(
        note: widget.selectedNote!,
        onClose: () => widget.onNoteSelected(null),
        textPrimary: widget.textPrimary,
        textSecondary: widget.textSecondary,
        accentColor: widget.accentColor,
        cardColor: widget.cardColor,
        borderColor: widget.borderColor,
      );
    }

    return Column(
      children: [
        // Areas section
        _MobileSection(
          title: 'Areas',
          icon: Icons.layers_outlined,
          isExpanded: _expandedSection == 0,
          onTap: () => setState(() => _expandedSection = _expandedSection == 0 ? -1 : 0),
          badge: widget.selectedAreaIds.isEmpty ? null : '${widget.selectedAreaIds.length}',
          textPrimary: widget.textPrimary,
          textSecondary: widget.textSecondary,
          accentColor: widget.accentColor,
          borderColor: widget.borderColor,
        ),
        if (_expandedSection == 0)
          Expanded(
            child: _AreasColumn(
              selectedIds: widget.selectedAreaIds,
              onSelectionChanged: widget.onAreasChanged,
              textPrimary: widget.textPrimary,
              textSecondary: widget.textSecondary,
              accentColor: widget.accentColor,
              cardColor: widget.cardColor,
              borderColor: widget.borderColor,
            ),
          ),

        // Resources section
        _MobileSection(
          title: 'Resources',
          icon: Icons.bookmark_outline_rounded,
          isExpanded: _expandedSection == 1,
          onTap: () => setState(() => _expandedSection = _expandedSection == 1 ? -1 : 1),
          badge: widget.selectedResourceIds.isEmpty ? null : '${widget.selectedResourceIds.length}',
          textPrimary: widget.textPrimary,
          textSecondary: widget.textSecondary,
          accentColor: widget.accentColor,
          borderColor: widget.borderColor,
        ),
        if (_expandedSection == 1)
          Expanded(
            child: _ResourcesColumn(
              selectedAreaIds: widget.selectedAreaIds,
              selectedResourceIds: widget.selectedResourceIds,
              onSelectionChanged: widget.onResourcesChanged,
              textPrimary: widget.textPrimary,
              textSecondary: widget.textSecondary,
              accentColor: widget.accentColor,
              cardColor: widget.cardColor,
              borderColor: widget.borderColor,
            ),
          ),

        // Notes section
        _MobileSection(
          title: 'Notes',
          icon: Icons.note_alt_outlined,
          isExpanded: _expandedSection == 2,
          onTap: () => setState(() => _expandedSection = _expandedSection == 2 ? -1 : 2),
          badge: null,
          textPrimary: widget.textPrimary,
          textSecondary: widget.textSecondary,
          accentColor: widget.accentColor,
          borderColor: widget.borderColor,
        ),
        if (_expandedSection == 2)
          Expanded(
            child: _NotesColumn(
              selectedResourceIds: widget.selectedResourceIds,
              selectedNote: widget.selectedNote,
              onNoteSelected: widget.onNoteSelected,
              textPrimary: widget.textPrimary,
              textSecondary: widget.textSecondary,
              accentColor: widget.accentColor,
              cardColor: widget.cardColor,
              borderColor: widget.borderColor,
            ),
          ),
      ],
    );
  }
}

class _MobileSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isExpanded;
  final VoidCallback onTap;
  final String? badge;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;
  final Color borderColor;

  const _MobileSection({
    required this.title,
    required this.icon,
    required this.isExpanded,
    required this.onTap,
    required this.badge,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
          color: isExpanded ? accentColor.withValues(alpha: 0.05) : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isExpanded ? accentColor : textSecondary),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isExpanded ? FontWeight.w600 : FontWeight.w500,
                color: isExpanded ? accentColor : textPrimary,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(badge!, style: TextStyle(fontSize: 11, color: accentColor, fontWeight: FontWeight.w600)),
              ),
            ],
            const Spacer(),
            Icon(
              isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              size: 20,
              color: textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared Widgets ──────────────────────────────────

class _AddButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color color;

  const _AddButton({required this.onPressed, required this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(Icons.add_rounded, size: 18, color: color),
      tooltip: 'Add',
      style: IconButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        padding: const EdgeInsets.all(6),
        minimumSize: const Size(28, 28),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color textSecondary;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 10),
          Text(message, style: TextStyle(fontSize: 12, color: textSecondary)),
        ],
      ),
    );
  }
}

// ─── Dialogs ─────────────────────────────────────────

Future<Map<String, String>?> _showCreateDialog({
  required BuildContext context,
  required String title,
  required IconData icon,
  required List<(String label, String hint, bool multiline)> fields,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bgColor = isDark ? const Color(0xFF16162A) : Colors.white;
  final textPri = isDark ? const Color(0xFFE2E2EC) : const Color(0xFF1A1A2E);
  final textSec = isDark ? const Color(0xFF7A7A90) : const Color(0xFF6B6B80);
  final border = isDark ? const Color(0xFF252540) : const Color(0xFFE2E2EC);
  final accent = Theme.of(context).colorScheme.primary;

  final controllers = {for (final f in fields) f.$1: TextEditingController()};

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(icon, size: 20, color: accent),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(color: textPri, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final f in fields) ...[
              _DialogTextField(
                controller: controllers[f.$1]!,
                label: f.$1,
                hint: f.$2,
                multiline: f.$3,
                textPri: textPri,
                textSec: textSec,
                border: border,
                accent: accent,
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: textSec))),
        FilledButton(onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: accent),
            child: const Text('Create')),
      ],
    ),
  );

  if (confirmed == true) {
    return {for (final e in controllers.entries) e.key: e.value.text.trim()};
  }
  return null;
}

Future<(String name, String description, List<int> areaIds)?> _showCreateResourceDialog({
  required BuildContext context,
  required List<Area> areas,
  required Set<int> selectedAreaIds,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bgColor = isDark ? const Color(0xFF16162A) : Colors.white;
  final textPri = isDark ? const Color(0xFFE2E2EC) : const Color(0xFF1A1A2E);
  final textSec = isDark ? const Color(0xFF7A7A90) : const Color(0xFF6B6B80);
  final border = isDark ? const Color(0xFF252540) : const Color(0xFFE2E2EC);
  final accent = Theme.of(context).colorScheme.primary;

  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  var selectedAreas = Set<int>.from(selectedAreaIds);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDS) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.bookmark_add_outlined, size: 20, color: accent),
            const SizedBox(width: 8),
            Text('New Resource', style: TextStyle(color: textPri, fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DialogTextField(controller: nameCtrl, label: 'Name', hint: 'Resource name',
                  multiline: false, textPri: textPri, textSec: textSec, border: border, accent: accent),
              const SizedBox(height: 12),
              _DialogTextField(controller: descCtrl, label: 'Description', hint: 'Optional description',
                  multiline: true, textPri: textPri, textSec: textSec, border: border, accent: accent),
              const SizedBox(height: 14),
              Text('Link to Areas', style: TextStyle(color: textSec, fontSize: 11, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              if (areas.isEmpty)
                Text('No areas created yet', style: TextStyle(color: textSec, fontSize: 12))
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: areas.map((area) {
                    final isSelected = selectedAreas.contains(area.id);
                    return GestureDetector(
                      onTap: () => setDS(() {
                        if (isSelected) {
                          selectedAreas.remove(area.id);
                        } else {
                          selectedAreas.add(area.id);
                        }
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? accent.withValues(alpha: 0.15) : border.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isSelected ? accent : border, width: isSelected ? 1 : 0.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(color: Color(area.color), borderRadius: BorderRadius.circular(2)),
                            ),
                            const SizedBox(width: 6),
                            Text(area.name, style: TextStyle(fontSize: 11, color: isSelected ? accent : textPri,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: TextStyle(color: textSec))),
          FilledButton(onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: accent),
              child: const Text('Create')),
        ],
      ),
    ),
  );

  if (confirmed == true && nameCtrl.text.trim().isNotEmpty) {
    return (nameCtrl.text.trim(), descCtrl.text.trim(), selectedAreas.toList());
  }
  return null;
}

Future<(String title, String content, String tags, List<int> resourceIds)?> _showCreateNoteDialog({
  required BuildContext context,
  required List<Resource> resources,
  required Set<int> selectedResourceIds,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bgColor = isDark ? const Color(0xFF16162A) : Colors.white;
  final textPri = isDark ? const Color(0xFFE2E2EC) : const Color(0xFF1A1A2E);
  final textSec = isDark ? const Color(0xFF7A7A90) : const Color(0xFF6B6B80);
  final border = isDark ? const Color(0xFF252540) : const Color(0xFFE2E2EC);
  final accent = Theme.of(context).colorScheme.primary;

  final titleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();
  final tagsCtrl = TextEditingController();
  var selectedResources = Set<int>.from(selectedResourceIds);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDS) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.note_add_rounded, size: 20, color: accent),
            const SizedBox(width: 8),
            Text('New Note', style: TextStyle(color: textPri, fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DialogTextField(controller: titleCtrl, label: 'Title', hint: 'Note title',
                    multiline: false, textPri: textPri, textSec: textSec, border: border, accent: accent),
                const SizedBox(height: 12),
                _DialogTextField(controller: contentCtrl, label: 'Content', hint: 'Write your note...',
                    multiline: true, textPri: textPri, textSec: textSec, border: border, accent: accent, maxLines: 6),
                const SizedBox(height: 12),
                _DialogTextField(controller: tagsCtrl, label: 'Tags', hint: 'comma, separated, tags',
                    multiline: false, textPri: textPri, textSec: textSec, border: border, accent: accent),
                const SizedBox(height: 14),
                Text('Link to Resources', style: TextStyle(color: textSec, fontSize: 11, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                if (resources.isEmpty)
                  Text('No resources created yet', style: TextStyle(color: textSec, fontSize: 12))
                else
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: resources.map((resource) {
                      final isSelected = selectedResources.contains(resource.id);
                      return GestureDetector(
                        onTap: () => setDS(() {
                          if (isSelected) {
                            selectedResources.remove(resource.id);
                          } else {
                            selectedResources.add(resource.id);
                          }
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? accent.withValues(alpha: 0.15) : border.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: isSelected ? accent : border, width: isSelected ? 1 : 0.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bookmark_rounded, size: 12, color: isSelected ? accent : textSec),
                              const SizedBox(width: 4),
                              Text(resource.name, style: TextStyle(fontSize: 11, color: isSelected ? accent : textPri,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: TextStyle(color: textSec))),
          FilledButton(onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: accent),
              child: const Text('Create')),
        ],
      ),
    ),
  );

  if (confirmed == true && titleCtrl.text.trim().isNotEmpty) {
    return (titleCtrl.text.trim(), contentCtrl.text, tagsCtrl.text.trim(), selectedResources.toList());
  }
  return null;
}

class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool multiline;
  final Color textPri;
  final Color textSec;
  final Color border;
  final Color accent;
  final int maxLines;

  const _DialogTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.multiline,
    required this.textPri,
    required this.textSec,
    required this.border,
    required this.accent,
    this.maxLines = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: textSec, fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: multiline ? maxLines : 1,
          style: TextStyle(color: textPri, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: textSec.withValues(alpha: 0.5), fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            filled: true,
            fillColor: border.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: border, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: border, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: accent, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
