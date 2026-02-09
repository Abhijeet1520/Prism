/// Brain screen — personal knowledge base with notes and search.
///
/// Grid/list of notes with full-text search, tags, and CRUD.
/// Wired to [PrismDatabase] for live note data.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moon_design/moon_design.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/database.dart';

class BrainScreen extends ConsumerStatefulWidget {
  const BrainScreen({super.key});

  @override
  ConsumerState<BrainScreen> createState() => _BrainScreenState();
}

class _BrainScreenState extends ConsumerState<BrainScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  int? _selectedIndex;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _createNote() async {
    final db = ref.read(databaseProvider);
    final uuid = const Uuid().v4();
    await db.createNote(uuid: uuid, title: 'Untitled Note', content: '');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.moonColors!;
    final db = ref.watch(databaseProvider);

    return Scaffold(
      backgroundColor: colors.gohan,
      body: Column(
        children: [
          // ── Header ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.goten,
              border: Border(bottom: BorderSide(color: colors.beerus)),
            ),
            child: Row(
              children: [
                Text(
                  'Second Brain',
                  style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w700, fontSize: 18),
                ),
                const Spacer(),
                MoonButton.icon(
                  onTap: () {},
                  icon: Icon(Icons.search, size: 20, color: colors.trunks),
                  buttonSize: MoonButtonSize.sm,
                ),
                const SizedBox(width: 4),
                MoonFilledButton(
                  onTap: _createNote,
                  buttonSize: MoonButtonSize.sm,
                  label: const Text('Add Note'),
                  leading: const Icon(Icons.add, size: 16),
                ),
              ],
            ),
          ),

          // ── Search ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: MoonTextInput(
              controller: _searchCtrl,
              hintText: 'Search notes, tags...',
              textInputSize: MoonTextInputSize.sm,
              leading: Icon(Icons.search, size: 18, color: colors.trunks),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              trailing: _searchQuery.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: Icon(Icons.close, size: 16, color: colors.trunks),
                    )
                  : null,
            ),
          ),

          // ── Content ────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<Note>>(
              stream: db.watchNotes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: MoonCircularLoader(color: colors.piccolo));
                }

                final allNotes = snapshot.data ?? [];
                final notes = _searchQuery.isEmpty
                    ? allNotes
                    : allNotes.where((n) =>
                        n.title.toLowerCase().contains(_searchQuery) ||
                        n.content.toLowerCase().contains(_searchQuery) ||
                        n.tags.toLowerCase().contains(_searchQuery)).toList();

                if (notes.isEmpty) {
                  return _EmptyState(colors: colors, hasSearch: _searchQuery.isNotEmpty, onCreate: _createNote);
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 700 && _selectedIndex != null && _selectedIndex! < notes.length) {
                      return Row(
                        children: [
                          Expanded(child: _buildGrid(colors, notes)),
                          VerticalDivider(width: 1, color: colors.beerus),
                          SizedBox(width: 360, child: _NoteDetail(colors: colors, note: notes[_selectedIndex!])),
                        ],
                      );
                    }
                    return _buildGrid(colors, notes);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(MoonColors colors, List<Note> notes) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 340,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: notes.length,
      itemBuilder: (context, i) => _NoteCard(
        colors: colors,
        note: notes[i],
        selected: _selectedIndex == i,
        onTap: () => setState(() => _selectedIndex = i),
      ),
    );
  }
}

// ─── Note Card ────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  final MoonColors colors;
  final Note note;
  final bool selected;
  final VoidCallback onTap;

  const _NoteCard({
    required this.colors,
    required this.note,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tags = note.tags.isNotEmpty ? note.tags.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList() : <String>[];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.goten,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? colors.piccolo : colors.beerus,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_sourceIcon(note.source), size: 16, color: colors.trunks),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    note.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                note.content.isNotEmpty ? note.content : 'Empty note',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colors.trunks, fontSize: 12, height: 1.4),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (tags.isNotEmpty)
                  ...tags.take(2).map((tag) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: MoonTag(
                          tagSize: MoonTagSize.x2s,
                          backgroundColor: colors.piccolo.withValues(alpha: 0.1),
                          label: Text(tag, style: TextStyle(fontSize: 10, color: colors.piccolo)),
                        ),
                      )),
                const Spacer(),
                Text(
                  _formatDate(note.updatedAt),
                  style: TextStyle(color: colors.trunks, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _sourceIcon(String source) {
    return switch (source) {
      'ai' => Icons.auto_awesome,
      'import' => Icons.file_download_outlined,
      _ => Icons.note_outlined,
    };
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}

// ─── Note Detail Panel ────────────────────────────────

class _NoteDetail extends StatelessWidget {
  final MoonColors colors;
  final Note note;
  const _NoteDetail({required this.colors, required this.note});

  @override
  Widget build(BuildContext context) {
    final tags = note.tags.isNotEmpty ? note.tags.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList() : <String>[];

    return Container(
      color: colors.goten,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.beerus)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(note.title, style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Source: ${note.source}', style: TextStyle(color: colors.trunks, fontSize: 12)),
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: tags
                        .map((tag) => MoonTag(
                              tagSize: MoonTagSize.x2s,
                              backgroundColor: colors.piccolo.withValues(alpha: 0.1),
                              label: Text(tag, style: TextStyle(fontSize: 10, color: colors.piccolo)),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                note.content.isNotEmpty ? note.content : 'This note is empty.',
                style: TextStyle(color: colors.bulma, fontSize: 14, height: 1.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final MoonColors colors;
  final bool hasSearch;
  final VoidCallback onCreate;

  const _EmptyState({
    required this.colors,
    required this.hasSearch,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasSearch ? Icons.search_off_rounded : Icons.auto_awesome_outlined,
            size: 48,
            color: colors.piccolo.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            hasSearch ? 'No matching notes' : 'Your knowledge base is empty',
            style: TextStyle(color: colors.trunks, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            hasSearch ? 'Try a different search' : 'Add notes to build your second brain',
            style: TextStyle(color: colors.trunks, fontSize: 13),
          ),
          if (!hasSearch) ...[
            const SizedBox(height: 16),
            MoonFilledButton(
              onTap: onCreate,
              buttonSize: MoonButtonSize.sm,
              label: const Text('Create Note'),
              leading: const Icon(Icons.add, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}
