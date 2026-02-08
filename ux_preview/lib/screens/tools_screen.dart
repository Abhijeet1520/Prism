import 'package:shadcn_flutter/shadcn_flutter.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  int _tab = 0;

  static const _builtInTools = [
    _Tool(name: 'Web Search', description: 'Search the web via DuckDuckGo or Google', icon: RadixIcons.magnifyingGlass, enabled: true),
    _Tool(name: 'Calculator', description: 'Evaluate mathematical expressions', icon: RadixIcons.input, enabled: true),
    _Tool(name: 'File Reader', description: 'Read and parse local files', icon: RadixIcons.fileText, enabled: true),
    _Tool(name: 'URL Fetcher', description: 'Fetch and extract content from URLs', icon: RadixIcons.link2, enabled: true),
    _Tool(name: 'Code Executor', description: 'Execute code snippets in sandboxed environment', icon: RadixIcons.code, enabled: false),
    _Tool(name: 'Image Analyzer', description: 'Analyze images with vision models', icon: RadixIcons.image, enabled: false),
  ];

  static const _mcpServers = [
    _McpServer(name: 'filesystem', status: 'Connected', tools: 5, description: 'Read/write local files with security controls'),
    _McpServer(name: 'github', status: 'Connected', tools: 12, description: 'GitHub repository operations via REST API'),
    _McpServer(name: 'sqlite', status: 'Disconnected', tools: 4, description: 'Query SQLite databases directly'),
    _McpServer(name: 'puppeteer', status: 'Disconnected', tools: 8, description: 'Browser automation and web scraping'),
  ];

  static const _skillsets = [
    _Skillset(name: 'Code Review', tools: ['File Reader', 'Code Executor'], description: 'Automated code review with style checks'),
    _Skillset(name: 'Research', tools: ['Web Search', 'URL Fetcher', 'File Reader'], description: 'Deep web research with source aggregation'),
    _Skillset(name: 'Data Analysis', tools: ['Calculator', 'File Reader', 'Code Executor'], description: 'Analyze CSV/JSON data with visualizations'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Tools & MCP'),
          trailing: [
            Button.secondary(
              leading: const Icon(RadixIcons.plusCircled),
              onPressed: () {},
              child: const Text('Add MCP Server'),
            ),
          ],
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                TabList(
                  index: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                  children: const [
                    TabItem(child: Text('Built-in Tools')),
                    TabItem(child: Text('MCP Servers')),
                    TabItem(child: Text('Skillsets')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _tab == 0
                  ? _buildToolsGrid()
                  : _tab == 1
                      ? _buildMcpServers()
                      : _buildSkillsets(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolsGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 140,
      ),
      itemCount: _builtInTools.length,
      itemBuilder: (context, index) {
        final tool = _builtInTools[index];
        return Card(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.muted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(tool.icon, size: 18),
                  ),
                  const Spacer(),
                  Switch(
                    value: tool.enabled,
                    onChanged: (_) {},
                  ),
                ],
              ),
              const Spacer(),
              Text(tool.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(tool.description, style: const TextStyle(fontSize: 12, color: Colors.gray), maxLines: 2),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMcpServers() {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (final server in _mcpServers)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: server.status == 'Connected'
                            ? Colors.green.withValues(alpha: 0.1)
                            : Theme.of(context).colorScheme.muted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        RadixIcons.component1,
                        size: 18,
                        color: server.status == 'Connected' ? Colors.green : Colors.gray,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(server.name, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'monospace')),
                              const SizedBox(width: 8),
                              server.status == 'Connected'
                                ? PrimaryBadge(child: Text(server.status))
                                : OutlineBadge(child: Text(server.status)),
                              const SizedBox(width: 8),
                              SecondaryBadge(child: Text('${server.tools} tools')),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(server.description, style: const TextStyle(fontSize: 13, color: Colors.gray)),
                        ],
                      ),
                    ),
                    Button.secondary(
                      onPressed: () {},
                      child: Text(server.status == 'Connected' ? 'Configure' : 'Connect'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSkillsets() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Description
          Card(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(RadixIcons.infoCircled, size: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Skillsets are curated tool bundles that give the AI specialized capabilities for specific tasks.',
                    style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.mutedForeground),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final skillset in _skillsets)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(RadixIcons.stack, size: 16),
                        const SizedBox(width: 8),
                        Text(skillset.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        const Spacer(),
                        Button(
                          style: const ButtonStyle.secondary(density: ButtonDensity.compact),
                          onPressed: () {},
                          child: const Text('Edit'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(skillset.description, style: const TextStyle(fontSize: 13, color: Colors.gray)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final tool in skillset.tools)
                          SecondaryBadge(child: Text(tool)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Button.outline(
            leading: const Icon(RadixIcons.plus),
            onPressed: () {},
            child: const Text('Create Skillset'),
          ),
        ],
      ),
    );
  }
}

class _Tool {
  final String name;
  final String description;
  final IconData icon;
  final bool enabled;

  const _Tool({required this.name, required this.description, required this.icon, required this.enabled});
}

class _McpServer {
  final String name;
  final String status;
  final int tools;
  final String description;

  const _McpServer({required this.name, required this.status, required this.tools, required this.description});
}

class _Skillset {
  final String name;
  final List<String> tools;
  final String description;

  const _Skillset({required this.name, required this.tools, required this.description});
}
