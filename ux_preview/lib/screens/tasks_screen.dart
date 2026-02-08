import 'package:shadcn_flutter/shadcn_flutter.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int _viewTab = 0;

  static const _tasks = [
    _Task(title: 'Set up Drift database schema', priority: 'High', status: 'In Progress', project: 'Prism', dueDate: 'Today'),
    _Task(title: 'Implement LangChain.dart adapter', priority: 'High', status: 'To Do', project: 'Prism', dueDate: 'Tomorrow'),
    _Task(title: 'Design chat UI with shadcn_flutter', priority: 'Medium', status: 'To Do', project: 'Prism', dueDate: 'Jan 20'),
    _Task(title: 'Add Ollama LAN discovery', priority: 'Medium', status: 'Backlog', project: 'Prism', dueDate: 'Jan 25'),
    _Task(title: 'Write unit tests for AI engine', priority: 'Low', status: 'Backlog', project: 'Prism', dueDate: 'Jan 30'),
    _Task(title: 'Update portfolio projects section', priority: 'Medium', status: 'To Do', project: 'Portfolio', dueDate: 'Jan 22'),
    _Task(title: 'Research on-device summarization', priority: 'Low', status: 'Done', project: 'Prism', dueDate: 'Completed'),
    _Task(title: 'Configure GitHub Actions CI', priority: 'High', status: 'Done', project: 'Prism', dueDate: 'Completed'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Tasks'),
          trailing: [
            Button.primary(
              leading: const Icon(RadixIcons.plus),
              onPressed: () {},
              child: const Text('Add Task'),
            ),
          ],
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // View toggle and filters
            Row(
              children: [
                TabList(
                  index: _viewTab,
                  onChanged: (i) => setState(() => _viewTab = i),
                  children: const [
                    TabItem(child: Text('List')),
                    TabItem(child: Text('Kanban')),
                    TabItem(child: Text('Calendar')),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: 200,
                  child: TextField(
                    placeholder: const Text('Filter tasks...'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _viewTab == 0 ? _buildListView() : (_viewTab == 1 ? _buildKanbanView() : _buildCalendarPlaceholder()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 40),
                Expanded(flex: 3, child: Text('Task', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.mutedForeground))),
                Expanded(child: Text('Priority', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.mutedForeground))),
                Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.mutedForeground))),
                Expanded(child: Text('Project', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.mutedForeground))),
                Expanded(child: Text('Due', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.mutedForeground))),
              ],
            ),
          ),
          const Divider(),
          for (final task in _tasks)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Checkbox(
                      state: task.status == 'Done' ? CheckboxState.checked : CheckboxState.unchecked,
                      onChanged: (_) {},
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.status == 'Done' ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  Expanded(child: _priorityBadge(task.priority)),
                  Expanded(child: _statusBadge(task.status)),
                  Expanded(child: Text(task.project, style: const TextStyle(fontSize: 13))),
                  Expanded(child: Text(task.dueDate, style: const TextStyle(fontSize: 13, color: Colors.gray))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKanbanView() {
    final columns = ['Backlog', 'To Do', 'In Progress', 'Done'];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final col in columns)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  SurfaceCard(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Text(col, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const Spacer(),
                          OutlineBadge(
                            child: Text('${_tasks.where((t) => t.status == col).length}'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (final task in _tasks.where((t) => t.status == col))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Card(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(task.title, style: const TextStyle(fontSize: 13)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        _priorityBadge(task.priority),
                                        const Spacer(),
                                        Text(task.dueDate, style: const TextStyle(fontSize: 11, color: Colors.gray)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCalendarPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(RadixIcons.calendar, size: 48),
          SizedBox(height: 16),
          Text('Calendar View', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text('Task timeline and calendar integration', style: TextStyle(color: Colors.gray)),
        ],
      ),
    );
  }

  Widget _priorityBadge(String priority) {
    return switch (priority) {
      'High' => DestructiveBadge(child: Text(priority)),
      'Medium' => PrimaryBadge(child: Text(priority)),
      _ => OutlineBadge(child: Text(priority)),
    };
  }

  Widget _statusBadge(String status) {
    return switch (status) {
      'Done' => PrimaryBadge(child: Text(status)),
      'In Progress' => SecondaryBadge(child: Text(status)),
      _ => OutlineBadge(child: Text(status)),
    };
  }
}

class _Task {
  final String title;
  final String priority;
  final String status;
  final String project;
  final String dueDate;

  const _Task({
    required this.title,
    required this.priority,
    required this.status,
    required this.project,
    required this.dueDate,
  });
}
