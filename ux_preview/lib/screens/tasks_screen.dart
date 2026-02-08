import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moon_design/moon_design.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<dynamic> _tasks = [];
  int _viewTab = 0;
  final _statusFilters = ['all', 'todo', 'in_progress', 'done'];
  String _activeFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  Future<void> _loadMockData() async {
    final json = await rootBundle.loadString('assets/mock_data/tasks/tasks.json');
    setState(() => _tasks = jsonDecode(json) as List);
  }

  List<dynamic> get _filteredTasks {
    if (_activeFilter == 'all') return _tasks;
    return _tasks.where((t) => t['status'] == _activeFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.moonColors!;

    return Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: colors.goten,
            border: Border(bottom: BorderSide(color: colors.beerus)),
          ),
          child: Row(
            children: [
              // View tabs
              MoonTabBar(
                tabBarSize: MoonTabBarSize.sm,
                isExpanded: false,
                tabs: const [
                  MoonTab(label: Text('List')),
                  MoonTab(label: Text('Kanban')),
                ],
                onTabChanged: (i) => setState(() => _viewTab = i),
              ),
              const Spacer(),
              // Filter chips
              ...List.generate(_statusFilters.length, (i) {
                final f = _statusFilters[i];
                final active = _activeFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: MoonChip(
                    chipSize: MoonChipSize.sm,
                    isActive: active,
                    backgroundColor: active ? colors.piccolo.withValues(alpha: 0.12) : Colors.transparent,
                    activeColor: colors.piccolo,
                    label: Text(
                      f == 'all' ? 'All' : f.replaceAll('_', ' '),
                      style: TextStyle(
                        fontSize: 12,
                        color: active ? colors.piccolo : colors.trunks,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    onTap: () => setState(() => _activeFilter = f),
                  ),
                );
              }),
              const SizedBox(width: 8),
              MoonFilledButton(
                onTap: () {},
                buttonSize: MoonButtonSize.sm,
                label: const Text('Add Task'),
                leading: const Icon(Icons.add, size: 16),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: _tasks.isEmpty
              ? Center(child: MoonCircularLoader(color: colors.piccolo))
              : _viewTab == 0
                  ? _buildListView(colors)
                  : _buildKanbanView(colors),
        ),
      ],
    );
  }

  Widget _buildListView(MoonColors colors) {
    final tasks = _filteredTasks;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, i) {
        final task = tasks[i] as Map<String, dynamic>;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.goten,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.beerus, width: 0.5),
          ),
          child: Row(
            children: [
              MoonCheckbox(
                value: task['status'] == 'done',
                onChanged: (_) {},
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task['title'] as String,
                      style: TextStyle(
                        color: colors.bulma,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        decoration: task['status'] == 'done' ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (task['dueDate'] != null)
                          Text(
                            (task['dueDate'] as String).substring(0, 10),
                            style: TextStyle(color: colors.trunks, fontSize: 11),
                          ),
                        if (task['estimatedHours'] != null) ...[
                          Text(' \u00b7 ', style: TextStyle(color: colors.trunks, fontSize: 11)),
                          Text(
                            '${task['estimatedHours']}h est.',
                            style: TextStyle(color: colors.trunks, fontSize: 11),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              MoonTag(
                tagSize: MoonTagSize.x2s,
                backgroundColor: _priorityColor(colors, task['priority'] as String),
                label: Text(
                  task['priority'] as String,
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              MoonTag(
                tagSize: MoonTagSize.x2s,
                backgroundColor: _statusTagColor(colors, task['status'] as String),
                label: Text(
                  (task['status'] as String).replaceAll('_', ' '),
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKanbanView(MoonColors colors) {
    final columns = ['todo', 'in_progress', 'done'];
    final labels = ['To Do', 'In Progress', 'Done'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(columns.length, (ci) {
          final colTasks = _tasks.where((t) => t['status'] == columns[ci]).toList();
          return Container(
            width: 280,
            margin: EdgeInsets.only(right: ci < columns.length - 1 ? 12 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Column header
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Text(
                        labels[ci],
                        style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(width: 6),
                      MoonTag(
                        tagSize: MoonTagSize.x2s,
                        backgroundColor: colors.beerus,
                        label: Text('${colTasks.length}', style: TextStyle(fontSize: 10, color: colors.bulma)),
                      ),
                    ],
                  ),
                ),
                // Cards
                Expanded(
                  child: ListView.builder(
                    itemCount: colTasks.length,
                    itemBuilder: (context, i) {
                      final task = colTasks[i] as Map<String, dynamic>;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.goten,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colors.beerus, width: 0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task['title'] as String,
                              style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w500, fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                MoonTag(
                                  tagSize: MoonTagSize.x2s,
                                  backgroundColor: _priorityColor(colors, task['priority'] as String),
                                  label: Text(task['priority'] as String, style: const TextStyle(fontSize: 9, color: Colors.white)),
                                ),
                                const Spacer(),
                                if (task['dueDate'] != null)
                                  Text(
                                    (task['dueDate'] as String).substring(5, 10),
                                    style: TextStyle(color: colors.trunks, fontSize: 10),
                                  ),
                              ],
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
        }),
      ),
    );
  }

  Color _priorityColor(MoonColors colors, String priority) {
    return switch (priority) {
      'critical' => colors.chichi,
      'high' => const Color(0xFFEF4444),
      'medium' => colors.krillin,
      'low' => colors.roshi,
      _ => colors.trunks,
    };
  }

  Color _statusTagColor(MoonColors colors, String status) {
    return switch (status) {
      'done' => colors.roshi,
      'in_progress' => colors.piccolo,
      'todo' => colors.trunks,
      _ => colors.beerus,
    };
  }
}
