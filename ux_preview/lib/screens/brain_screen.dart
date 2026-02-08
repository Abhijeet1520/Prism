import 'package:shadcn_flutter/shadcn_flutter.dart';

class BrainScreen extends StatefulWidget {
  const BrainScreen({super.key});

  @override
  State<BrainScreen> createState() => _BrainScreenState();
}

class _BrainScreenState extends State<BrainScreen> {
  int _activeTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Second Brain'),
          trailing: [
            Button.primary(
              leading: const Icon(RadixIcons.plus),
              onPressed: () {},
              child: const Text('New'),
            ),
          ],
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // PARA Tabs
            TabList(
              index: _activeTab,
              onChanged: (i) => setState(() => _activeTab = i),
              children: const [
                TabItem(child: Text('Projects')),
                TabItem(child: Text('Areas')),
                TabItem(child: Text('Resources')),
                TabItem(child: Text('Archives')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: [
                _buildProjectsTab(),
                _buildAreasTab(),
                _buildResourcesTab(),
                _buildArchivesTab(),
              ][_activeTab],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsTab() {
    return _buildCardGrid([
      _ParaItem(
        title: 'Prism App Development',
        description: 'AI personal assistant app built with Flutter',
        icon: '🚀',
        status: 'Active',
        progress: 0.15,
        taskCount: 47,
        noteCount: 11,
      ),
      _ParaItem(
        title: 'Portfolio Website',
        description: 'Personal portfolio with project showcase',
        icon: '🌐',
        status: 'Active',
        progress: 0.65,
        taskCount: 12,
        noteCount: 5,
      ),
      _ParaItem(
        title: 'ML Research Paper',
        description: 'On-device inference optimization techniques',
        icon: '📄',
        status: 'On Hold',
        progress: 0.30,
        taskCount: 8,
        noteCount: 23,
      ),
    ]);
  }

  Widget _buildAreasTab() {
    return _buildCardGrid([
      _ParaItem(title: 'Health & Fitness', description: 'Exercise routines, nutrition tracking', icon: '💪', noteCount: 15),
      _ParaItem(title: 'Career Development', description: 'Skills, certifications, networking', icon: '📈', noteCount: 22),
      _ParaItem(title: 'Personal Finance', description: 'Investments, savings goals', icon: '💰', noteCount: 8),
      _ParaItem(title: 'Learning', description: 'Courses, books, tutorials', icon: '📚', noteCount: 31),
    ]);
  }

  Widget _buildResourcesTab() {
    return _buildCardGrid([
      _ParaItem(title: 'Flutter Patterns', description: 'Architecture patterns and best practices', icon: '🦋', noteCount: 18),
      _ParaItem(title: 'AI/ML References', description: 'Papers, tutorials, model cards', icon: '🤖', noteCount: 42),
      _ParaItem(title: 'Design Inspiration', description: 'UI/UX references and ideas', icon: '🎨', noteCount: 25),
    ]);
  }

  Widget _buildArchivesTab() {
    return _buildCardGrid([
      _ParaItem(title: 'Old Portfolio (2023)', description: 'Previous portfolio version', icon: '📦', status: 'Completed'),
      _ParaItem(title: 'Hackathon Project', description: 'Team collaboration tool', icon: '📦', status: 'Completed'),
    ]);
  }

  Widget _buildCardGrid(List<_ParaItem> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 500 ? 2 : 1);
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => _buildParaCard(items[index]),
        );
      },
    );
  }

  Widget _buildParaCard(_ParaItem item) {
    return Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(item.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (item.status != null)
                item.status == 'Active'
                  ? PrimaryBadge(child: Text(item.status!))
                  : OutlineBadge(child: Text(item.status!)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            style: const TextStyle(fontSize: 13, color: Colors.gray),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          if (item.progress != null) ...[
            Progress(progress: item.progress!),
            const SizedBox(height: 6),
          ],
          Row(
            children: [
              if (item.taskCount != null) ...[
                const Icon(RadixIcons.checkCircled, size: 12),
                const SizedBox(width: 4),
                Text('${item.taskCount} tasks', style: const TextStyle(fontSize: 12, color: Colors.gray)),
                const SizedBox(width: 12),
              ],
              if (item.noteCount != null) ...[
                const Icon(RadixIcons.file, size: 12),
                const SizedBox(width: 4),
                Text('${item.noteCount} notes', style: const TextStyle(fontSize: 12, color: Colors.gray)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ParaItem {
  final String title;
  final String description;
  final String icon;
  final String? status;
  final double? progress;
  final int? taskCount;
  final int? noteCount;

  const _ParaItem({
    required this.title,
    required this.description,
    required this.icon,
    this.status,
    this.progress,
    this.taskCount,
    this.noteCount,
  });
}
