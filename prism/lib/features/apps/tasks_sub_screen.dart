/// Tasks sub-screen — List & Kanban views with inline editing.
///
/// Tasks expand inline on tap to show full edit form (like transactions).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/database.dart';

class TasksSubScreen extends ConsumerStatefulWidget {
  final bool isDark;
  final Color cardColor, borderColor, textPrimary, textSecondary;

  const TasksSubScreen({
    super.key,
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  ConsumerState<TasksSubScreen> createState() => _TasksSubScreenState();
}

class _TasksSubScreenState extends ConsumerState<TasksSubScreen> {
  int _viewTab = 0;
  String _activeFilter = 'all';
  String? _expandedTaskUuid;

  static const _statusFilters = ['all', 'todo', 'done'];
  static const _priorities = ['low', 'medium', 'high', 'critical'];

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.cardColor,
            border: Border(
                bottom: BorderSide(color: widget.borderColor, width: 0.5)),
          ),
          child: Row(
            children: [
              _ViewToggle(
                label: 'List', icon: Icons.list_rounded,
                isActive: _viewTab == 0, accent: accentColor,
                secondary: widget.textSecondary,
                onTap: () => setState(() => _viewTab = 0),
              ),
              const SizedBox(width: 4),
              _ViewToggle(
                label: 'Kanban', icon: Icons.view_column_rounded,
                isActive: _viewTab == 1, accent: accentColor,
                secondary: widget.textSecondary,
                onTap: () => setState(() => _viewTab = 1),
              ),
              const Spacer(),
              ..._statusFilters.map((f) {
                final active = _activeFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _activeFilter = f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: active
                            ? accentColor.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: active
                                ? accentColor.withValues(alpha: 0.3)
                                : widget.borderColor,
                            width: 0.5),
                      ),
                      child: Text(
                        f == 'all' ? 'All' : f[0].toUpperCase() + f.substring(1),
                        style: TextStyle(
                          fontSize: 11,
                          color: active ? accentColor : widget.textSecondary,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        // Add Task Button
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: GestureDetector(
            onTap: () => _showAddTaskDialog(context, accentColor),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: accentColor.withValues(alpha: 0.2), width: 0.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.add_rounded, size: 18, color: accentColor),
                  const SizedBox(width: 8),
                  Text('Add New Task',
                      style: TextStyle(
                          color: accentColor, fontSize: 13,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ),

        // Content
        Expanded(
          child: StreamBuilder<List<TaskEntry>>(
            stream: ref.watch(databaseProvider).watchAllTasks(),
            builder: (context, snap) {
              final allTasks = snap.data ?? [];
              if (allTasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline, size: 48,
                          color: widget.textSecondary.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      Text('No tasks yet',
                          style: TextStyle(color: widget.textSecondary, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('Tap "Add New Task" to get started',
                          style: TextStyle(color: widget.textSecondary.withValues(alpha: 0.6), fontSize: 12)),
                    ],
                  ),
                );
              }
              final filtered = _activeFilter == 'all'
                  ? allTasks
                  : allTasks.where((t) {
                      if (_activeFilter == 'done') return t.isCompleted;
                      return !t.isCompleted;
                    }).toList();

              return _viewTab == 0
                  ? _buildListView(filtered, accentColor)
                  : _buildKanbanView(allTasks, accentColor);
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showAddTaskDialog(BuildContext ctx, Color accentColor) async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String priority = 'medium';
    DateTime? dueDate;
    final bgColor = widget.isDark ? const Color(0xFF16162A) : Colors.white;

    final result = await showDialog<bool>(
      context: ctx,
      builder: (dCtx) => StatefulBuilder(
        builder: (dCtx, setDS) => AlertDialog(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(children: [
            Icon(Icons.add_task_rounded, size: 20, color: accentColor),
            const SizedBox(width: 8),
            Text('New Task', style: TextStyle(
                color: widget.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          ]),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldWidget('Title', titleCtrl, 'What needs to be done?'),
                const SizedBox(height: 12),
                _fieldWidget('Description', descCtrl, 'Add details...', maxLines: 3),
                const SizedBox(height: 12),
                Text('Priority', style: TextStyle(
                    color: widget.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  children: _priorities.map((p) {
                    final sel = priority == p;
                    return GestureDetector(
                      onTap: () => setDS(() => priority = p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: sel ? _priorityColor(p).withValues(alpha: 0.15)
                              : widget.borderColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: sel ? _priorityColor(p) : widget.borderColor,
                              width: sel ? 1 : 0.5),
                        ),
                        child: Text(p[0].toUpperCase() + p.substring(1),
                            style: TextStyle(fontSize: 12,
                                color: sel ? _priorityColor(p) : widget.textSecondary,
                                fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Text('Due Date', style: TextStyle(
                    color: widget.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: dCtx,
                      initialDate: dueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                    );
                    if (picked != null) setDS(() => dueDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: widget.borderColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: widget.borderColor, width: 0.5),
                    ),
                    child: Row(children: [
                      Icon(Icons.calendar_today_rounded, size: 14, color: widget.textSecondary),
                      const SizedBox(width: 8),
                      Text(dueDate != null
                              ? DateFormat('EEE, MMM d, yyyy').format(dueDate!)
                              : 'No due date',
                          style: TextStyle(
                              color: dueDate != null ? widget.textPrimary : widget.textSecondary,
                              fontSize: 12)),
                      const Spacer(),
                      if (dueDate != null)
                        GestureDetector(
                          onTap: () => setDS(() => dueDate = null),
                          child: Icon(Icons.close_rounded, size: 14, color: widget.textSecondary),
                        ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dCtx, false),
                child: Text('Cancel', style: TextStyle(color: widget.textSecondary))),
            FilledButton(onPressed: () => Navigator.pop(dCtx, true),
                style: FilledButton.styleFrom(backgroundColor: accentColor),
                child: const Text('Create Task')),
          ],
        ),
      ),
    );

    if (result == true && titleCtrl.text.trim().isNotEmpty) {
      await ref.read(databaseProvider).createTask(
            uuid: const Uuid().v4(),
            title: titleCtrl.text.trim(),
            description: descCtrl.text.trim(),
            priority: priority,
            dueDate: dueDate,
          );
    }
  }

  Widget _fieldWidget(String label, TextEditingController ctrl, String hint,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(
            color: widget.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl, maxLines: maxLines,
          style: TextStyle(color: widget.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: widget.textSecondary.withValues(alpha: 0.5), fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            filled: true,
            fillColor: widget.borderColor.withValues(alpha: 0.3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: widget.borderColor, width: 0.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: widget.borderColor, width: 0.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1)),
          ),
        ),
      ],
    );
  }

  Widget _buildListView(List<TaskEntry> tasks, Color accent) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: tasks.length,
      itemBuilder: (context, i) {
        final task = tasks[i];
        final isExpanded = _expandedTaskUuid == task.uuid;
        return _TaskListItem(
          task: task, isExpanded: isExpanded,
          onTap: () => setState(() => _expandedTaskUuid = isExpanded ? null : task.uuid),
          onToggle: () => ref.read(databaseProvider).toggleTask(task.uuid),
          onUpdate: (title, desc, priority, dueDate, clearDue) async {
            await ref.read(databaseProvider).updateTask(task.uuid,
                title: title, description: desc, priority: priority,
                dueDate: dueDate, clearDueDate: clearDue);
            setState(() => _expandedTaskUuid = null);
          },
          onDelete: () async {
            await ref.read(databaseProvider).deleteTask(task.uuid);
            setState(() => _expandedTaskUuid = null);
          },
          isDark: widget.isDark, cardColor: widget.cardColor,
          borderColor: widget.borderColor, textPrimary: widget.textPrimary,
          textSecondary: widget.textSecondary, accentColor: accent,
        );
      },
    );
  }

  Widget _buildKanbanView(List<TaskEntry> allTasks, Color accent) {
    final todoCols = allTasks.where((t) => !t.isCompleted).toList();
    final doneCols = allTasks.where((t) => t.isCompleted).toList();
    final cols = [('To Do', todoCols, false), ('Done', doneCols, true)];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cols.map((col) {
          return DragTarget<TaskEntry>(
            onAcceptWithDetails: (d) => ref.read(databaseProvider).toggleTask(d.data.uuid),
            onWillAcceptWithDetails: (d) => d.data.isCompleted != col.$3,
            builder: (context, cand, _) {
              final hovering = cand.isNotEmpty;
              return Container(
                width: 260, margin: const EdgeInsets.only(right: 12),
                decoration: hovering
                    ? BoxDecoration(borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: accent.withValues(alpha: 0.4), width: 2))
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(children: [
                        Text(col.$1, style: TextStyle(color: widget.textPrimary,
                            fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: widget.borderColor,
                              borderRadius: BorderRadius.circular(4)),
                          child: Text('${col.$2.length}',
                              style: TextStyle(fontSize: 10, color: widget.textPrimary)),
                        ),
                      ]),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: col.$2.length,
                        itemBuilder: (context, i) {
                          final task = col.$2[i];
                          return LongPressDraggable<TaskEntry>(
                            data: task,
                            feedback: Material(
                              elevation: 6, borderRadius: BorderRadius.circular(10),
                              child: Container(width: 240, padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: widget.cardColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: accent, width: 1)),
                                child: Text(task.title, style: TextStyle(color: widget.textPrimary,
                                    fontWeight: FontWeight.w500, fontSize: 13))),
                            ),
                            childWhenDragging: Opacity(opacity: 0.3, child: _kanbanCard(task)),
                            child: _kanbanCard(task),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _kanbanCard(TaskEntry task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: widget.cardColor, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: widget.borderColor, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(task.title, style: TextStyle(color: widget.textPrimary,
            fontWeight: FontWeight.w500, fontSize: 13)),
        if (task.description.isNotEmpty)
          Padding(padding: const EdgeInsets.only(top: 4),
            child: Text(task.description, style: TextStyle(color: widget.textSecondary, fontSize: 11),
                maxLines: 2, overflow: TextOverflow.ellipsis)),
        const SizedBox(height: 6),
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: _priorityColor(task.priority),
                borderRadius: BorderRadius.circular(4)),
            child: Text(task.priority, style: const TextStyle(fontSize: 9, color: Colors.white))),
          const Spacer(),
          if (task.dueDate != null)
            Text(DateFormat('MMM d').format(task.dueDate!),
                style: TextStyle(color: widget.textSecondary, fontSize: 10)),
        ]),
      ]),
    );
  }

  Color _priorityColor(String p) => switch (p) {
    'critical' => const Color(0xFFDC2626), 'high' => const Color(0xFFEF4444),
    'medium' => const Color(0xFFF59E0B), 'low' => const Color(0xFF10B981),
    _ => const Color(0xFF6B7280),
  };
}

// ─── Task List Item (expandable inline edit) ────────

class _TaskListItem extends StatefulWidget {
  final TaskEntry task;
  final bool isExpanded;
  final VoidCallback onTap, onToggle, onDelete;
  final Future<void> Function(String?, String?, String?, DateTime?, bool) onUpdate;
  final bool isDark;
  final Color cardColor, borderColor, textPrimary, textSecondary, accentColor;

  const _TaskListItem({
    required this.task, required this.isExpanded, required this.onTap,
    required this.onToggle, required this.onUpdate, required this.onDelete,
    required this.isDark, required this.cardColor, required this.borderColor,
    required this.textPrimary, required this.textSecondary, required this.accentColor,
  });

  @override
  State<_TaskListItem> createState() => _TaskListItemState();
}

class _TaskListItemState extends State<_TaskListItem> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late String _priority;
  DateTime? _dueDate;
  static const _priorities = ['low', 'medium', 'high', 'critical'];

  @override
  void initState() { super.initState(); _init(); }

  @override
  void didUpdateWidget(covariant _TaskListItem old) {
    super.didUpdateWidget(old);
    if (widget.isExpanded && !old.isExpanded) _init();
  }

  void _init() {
    _titleCtrl = TextEditingController(text: widget.task.title);
    _descCtrl = TextEditingController(text: widget.task.description);
    _priority = widget.task.priority;
    _dueDate = widget.task.dueDate;
  }

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final pColor = _pColor(task.priority);
    final overdue = task.dueDate != null && task.dueDate!.isBefore(DateTime.now()) && !task.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: widget.cardColor, borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.isExpanded ? widget.accentColor.withValues(alpha: 0.3) : widget.borderColor,
          width: widget.isExpanded ? 1 : 0.5),
      ),
      child: Column(children: [
        GestureDetector(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              GestureDetector(
                onTap: widget.onToggle,
                child: Container(width: 22, height: 22,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    color: task.isCompleted ? const Color(0xFF10B981) : Colors.transparent,
                    border: Border.all(
                        color: task.isCompleted ? const Color(0xFF10B981) : widget.borderColor, width: 2)),
                  child: task.isCompleted ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(task.title, style: TextStyle(color: widget.textPrimary,
                    fontWeight: FontWeight.w500, fontSize: 14,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null)),
                if (task.description.isNotEmpty)
                  Padding(padding: const EdgeInsets.only(top: 2),
                    child: Text(task.description, style: TextStyle(color: widget.textSecondary, fontSize: 11),
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                if (task.dueDate != null)
                  Padding(padding: const EdgeInsets.only(top: 3), child: Row(children: [
                    Icon(Icons.calendar_today_rounded, size: 10,
                        color: overdue ? const Color(0xFFEF4444) : widget.textSecondary),
                    const SizedBox(width: 4),
                    Text(DateFormat('MMM d').format(task.dueDate!),
                        style: TextStyle(fontSize: 11,
                            color: overdue ? const Color(0xFFEF4444) : widget.textSecondary,
                            fontWeight: overdue ? FontWeight.w600 : FontWeight.w400)),
                  ])),
              ])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: pColor, borderRadius: BorderRadius.circular(4)),
                child: Text(task.priority, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500))),
              const SizedBox(width: 6),
              Icon(widget.isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  size: 18, color: widget.textSecondary),
            ]),
          ),
        ),
        if (widget.isExpanded)
          Container(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Divider(color: widget.borderColor, height: 1),
              const SizedBox(height: 12),
              _ef('Title', _titleCtrl), const SizedBox(height: 10),
              _ef('Description', _descCtrl, maxLines: 3), const SizedBox(height: 10),
              Text('Priority', style: TextStyle(color: widget.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Wrap(spacing: 6, children: _priorities.map((p) {
                final sel = _priority == p;
                return GestureDetector(
                  onTap: () => setState(() => _priority = p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: sel ? _pColor(p).withValues(alpha: 0.15) : widget.borderColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: sel ? _pColor(p) : widget.borderColor, width: sel ? 1 : 0.5)),
                    child: Text(p[0].toUpperCase() + p.substring(1),
                        style: TextStyle(fontSize: 11,
                            color: sel ? _pColor(p) : widget.textSecondary,
                            fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                  ),
                );
              }).toList()),
              const SizedBox(height: 10),
              Text('Due Date', style: TextStyle(color: widget.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(context: context,
                      initialDate: _dueDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 730)));
                  if (picked != null) setState(() => _dueDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(color: widget.borderColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: widget.borderColor, width: 0.5)),
                  child: Row(children: [
                    Icon(Icons.calendar_today_rounded, size: 14, color: widget.textSecondary),
                    const SizedBox(width: 8),
                    Text(_dueDate != null ? DateFormat('EEE, MMM d, yyyy').format(_dueDate!) : 'No due date',
                        style: TextStyle(color: _dueDate != null ? widget.textPrimary : widget.textSecondary, fontSize: 12)),
                    const Spacer(),
                    if (_dueDate != null)
                      GestureDetector(onTap: () => setState(() => _dueDate = null),
                          child: Icon(Icons.close_rounded, size: 14, color: widget.textSecondary)),
                  ]),
                ),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: FilledButton.icon(
                  onPressed: () => widget.onUpdate(
                      _titleCtrl.text.trim(), _descCtrl.text.trim(), _priority,
                      _dueDate, _dueDate == null && widget.task.dueDate != null),
                  icon: const Icon(Icons.save_rounded, size: 14),
                  label: const Text('Save', style: TextStyle(fontSize: 12)),
                  style: FilledButton.styleFrom(backgroundColor: widget.accentColor,
                      foregroundColor: Colors.white, minimumSize: const Size(0, 36)),
                )),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 14),
                  label: const Text('Delete', style: TextStyle(fontSize: 12)),
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white, minimumSize: const Size(0, 36)),
                ),
              ]),
            ]),
          ),
      ]),
    );
  }

  Widget _ef(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: widget.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      TextField(controller: ctrl, maxLines: maxLines,
          style: TextStyle(color: widget.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            filled: true, fillColor: widget.borderColor.withValues(alpha: 0.3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: widget.borderColor, width: 0.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: widget.borderColor, width: 0.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: widget.accentColor, width: 1)),
          )),
    ]);
  }

  Color _pColor(String p) => switch (p) {
    'critical' => const Color(0xFFDC2626), 'high' => const Color(0xFFEF4444),
    'medium' => const Color(0xFFF59E0B), 'low' => const Color(0xFF10B981),
    _ => const Color(0xFF6B7280),
  };
}

class _ViewToggle extends StatelessWidget {
  final String label; final IconData icon; final bool isActive;
  final Color accent, secondary; final VoidCallback onTap;
  const _ViewToggle({required this.label, required this.icon, required this.isActive,
      required this.accent, required this.secondary, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: isActive ? accent.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(6)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: isActive ? accent : secondary),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: isActive ? accent : secondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
        ]),
      ),
    );
  }
}
