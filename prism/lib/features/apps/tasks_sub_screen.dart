/// Tasks sub-screen — task creation, task list from DB, priority colors.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final _titleCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    await ref.read(databaseProvider).createTask(
          uuid: const Uuid().v4(),
          title: title,
        );
    _titleCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        // Add task bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: widget.cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: widget.borderColor, width: 0.5),
                  ),
                  child: TextField(
                    controller: _titleCtrl,
                    onSubmitted: (_) => _addTask(),
                    decoration: InputDecoration(
                      hintText: 'Add a new task...',
                      hintStyle: TextStyle(
                          color: widget.textSecondary, fontSize: 13),
                      prefixIcon: Icon(Icons.add_rounded,
                          size: 18, color: widget.textSecondary),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: TextStyle(
                        color: widget.textPrimary, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _addTask,
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(60, 42),
                ),
                child: const Text('Add', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: widget.borderColor),
        // Task list
        Expanded(
          child: StreamBuilder<List<TaskEntry>>(
            stream: ref.watch(databaseProvider).watchPendingTasks(),
            builder: (context, snap) {
              final tasks = snap.data ?? [];
              if (tasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 48,
                          color:
                              widget.textSecondary.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      Text('All tasks complete!',
                          style: TextStyle(
                              color: widget.textSecondary, fontSize: 14)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: tasks.length,
                itemBuilder: (context, i) {
                  final task = tasks[i];
                  final pColor = _priorityColor(task.priority);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: widget.borderColor, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => ref
                              .read(databaseProvider)
                              .toggleTask(task.uuid),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: pColor, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(task.title,
                                  style: TextStyle(
                                      color: widget.textPrimary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14)),
                              if (task.description.isNotEmpty)
                                Text(task.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: widget.textSecondary,
                                        fontSize: 12)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: pColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(task.priority,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: pColor,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Color _priorityColor(String p) => switch (p) {
        'high' => const Color(0xFFEF4444),
        'medium' => const Color(0xFFF59E0B),
        _ => const Color(0xFF10B981),
      };
}
