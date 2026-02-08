import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moon_design/moon_design.dart';

class BrainScreen extends StatefulWidget {
  const BrainScreen({super.key});

  @override
  State<BrainScreen> createState() => _BrainScreenState();
}

class _BrainScreenState extends State<BrainScreen> {
  List<dynamic> _items = [];
  List<dynamic> _notes = [];
  int _selectedTab = 0;
  int? _selectedItemIndex;

  static const _paraTabs = ['Projects', 'Areas', 'Resources', 'Archives'];
  static const _paraKeys = ['projects', 'areas', 'resources', 'archives'];

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  Future<void> _loadMockData() async {
    final itemsJson = await rootBundle.loadString('assets/mock_data/brain/brain_items.json');
    final notesJson = await rootBundle.loadString('assets/mock_data/brain/notes.json');
    setState(() {
      _items = jsonDecode(itemsJson) as List;
      _notes = jsonDecode(notesJson) as List;
    });
  }

  List<dynamic> get _filteredItems {
    return _items.where((item) => item['paraCategory'] == _paraKeys[_selectedTab]).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.moonColors!;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colors.goten,
            border: Border(bottom: BorderSide(color: colors.beerus)),
          ),
          child: Row(
            children: [
              Text('Second Brain', style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w700, fontSize: 18)),
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
                label: const Text('Add New'),
                leading: const Icon(Icons.add, size: 16),
              ),
            ],
          ),
        ),
        // PARA Tabs
        Container(
          color: colors.goten,
          child: MoonTabBar(
            tabBarSize: MoonTabBarSize.sm,
            tabs: List.generate(_paraTabs.length, (i) {
              return MoonTab(
                leading: _tabIcon(i, colors),
                label: Text(_paraTabs[i]),
              );
            }),
            onTabChanged: (i) => setState(() {
              _selectedTab = i;
              _selectedItemIndex = null;
            }),
          ),
        ),
        Divider(height: 1, color: colors.beerus),
        // Content
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 700 && _selectedItemIndex != null) {
                return Row(
                  children: [
                    Expanded(child: _buildItemGrid(colors)),
                    VerticalDivider(width: 1, color: colors.beerus),
                    SizedBox(width: 360, child: _buildNotePanel(colors)),
                  ],
                );
              }
              return _buildItemGrid(colors);
            },
          ),
        ),
      ],
    );
  }

  Widget _tabIcon(int i, MoonColors colors) {
    const icons = [Icons.rocket_launch_outlined, Icons.layers_outlined, Icons.bookmark_border, Icons.archive_outlined];
    return Icon(icons[i], size: 16, color: colors.trunks);
  }

  Widget _buildItemGrid(MoonColors colors) {
    final items = _filteredItems;

    if (items.isEmpty) {
      return _buildEmptyState(colors);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 340,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => _buildItemCard(colors, items[i] as Map<String, dynamic>, i),
    );
  }

  Widget _buildItemCard(MoonColors colors, Map<String, dynamic> item, int index) {
    final selected = _selectedItemIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedItemIndex = index),
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
                Text(item['icon'] as String, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item['title'] as String,
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
                item['description'] as String,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colors.trunks, fontSize: 12, height: 1.4),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (item['progress'] != null) ...[
                  Expanded(
                    child: MoonLinearProgress(
                      value: (item['progress'] as num).toDouble(),
                      color: colors.piccolo,
                      backgroundColor: colors.beerus,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${((item['progress'] as num) * 100).toInt()}%',
                    style: TextStyle(color: colors.trunks, fontSize: 11),
                  ),
                ] else ...[
                  Icon(Icons.note_outlined, size: 14, color: colors.trunks),
                  const SizedBox(width: 4),
                  Text('${item['noteCount']} notes', style: TextStyle(color: colors.trunks, fontSize: 11)),
                ],
                const Spacer(),
                if (item['status'] != null)
                  MoonTag(
                    tagSize: MoonTagSize.x2s,
                    backgroundColor: _statusColor(colors, item['status'] as String),
                    label: Text(
                      item['status'] as String,
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotePanel(MoonColors colors) {
    final items = _filteredItems;
    if (_selectedItemIndex == null || _selectedItemIndex! >= items.length) {
      return const SizedBox.shrink();
    }
    final item = items[_selectedItemIndex!] as Map<String, dynamic>;
    final itemNotes = _notes.where((n) => n['brainItemId'] == item['id']).toList();

    return Container(
      color: colors.goten,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(item['icon'] as String, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item['title'] as String,
                    style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.beerus),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Notes (${itemNotes.length})', style: TextStyle(color: colors.trunks, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: itemNotes.isEmpty
                ? Center(child: Text('No notes yet', style: TextStyle(color: colors.trunks)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: itemNotes.length,
                    itemBuilder: (context, i) {
                      final note = itemNotes[i] as Map<String, dynamic>;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.gohan,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colors.beerus, width: 0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    note['title'] as String,
                                    style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                ),
                                if (note['isPinned'] == true)
                                  Icon(Icons.push_pin, size: 12, color: colors.piccolo),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              note['content'] as String,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: colors.trunks, fontSize: 12, height: 1.4),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 4,
                              children: (note['tags'] as List)
                                  .take(3)
                                  .map<Widget>((t) => MoonTag(
                                        tagSize: MoonTagSize.x2s,
                                        backgroundColor: colors.piccolo.withValues(alpha: 0.1),
                                        label: Text(t as String, style: TextStyle(fontSize: 10, color: colors.piccolo)),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(MoonColors colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.layers_outlined, size: 48, color: colors.trunks.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text('No ${_paraTabs[_selectedTab].toLowerCase()} yet', style: TextStyle(color: colors.trunks, fontSize: 15)),
        ],
      ),
    );
  }

  Color _statusColor(MoonColors colors, String status) {
    return switch (status) {
      'active' => colors.roshi,
      'completed' => colors.piccolo,
      'on_hold' => colors.krillin,
      _ => colors.trunks,
    };
  }
}
