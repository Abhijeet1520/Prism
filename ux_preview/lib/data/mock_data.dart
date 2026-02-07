class MockData {
  // ──── Conversations ────
  static final conversations = [
    Conversation(
      id: '1',
      title: 'Budget Analysis Q1',
      lastMessage: 'Here\'s the Q1 breakdown with revenue trends...',
      model: 'gemma-3b',
      provider: 'local',
      timeAgo: '2 hours ago',
      isPinned: true,
      tokenCount: 1284,
    ),
    Conversation(
      id: '2',
      title: 'Code Review Help',
      lastMessage: 'I found 3 potential issues in the authentication flow...',
      model: 'GPT-4o',
      provider: 'OpenAI',
      timeAgo: 'Yesterday',
      isPinned: false,
      tokenCount: 3421,
    ),
    Conversation(
      id: '3',
      title: 'Meeting Notes Summary',
      lastMessage: 'Key action items from the sprint planning meeting...',
      model: 'Claude 3.5',
      provider: 'Anthropic',
      timeAgo: '2 days ago',
      isPinned: false,
      tokenCount: 892,
    ),
    Conversation(
      id: '4',
      title: 'Flutter Architecture Ideas',
      lastMessage: 'For the provider pattern, I recommend using Riverpod...',
      model: 'mistral:7b',
      provider: 'Ollama',
      timeAgo: '3 days ago',
      isPinned: false,
      tokenCount: 2156,
    ),
    Conversation(
      id: '5',
      title: 'Recipe Suggestions',
      lastMessage: 'Here are 5 quick dinner ideas using the ingredients you listed...',
      model: 'Gemini 1.5 Pro',
      provider: 'Google',
      timeAgo: '1 week ago',
      isPinned: false,
      tokenCount: 645,
    ),
  ];

  // ──── Chat Messages ────
  static final chatMessages = [
    ChatMessage(
      id: '1',
      role: MessageRole.user,
      content: 'Can you analyze this budget spreadsheet?',
      attachment: 'budget_q1.csv',
      timestamp: '2:28 PM',
    ),
    ChatMessage(
      id: '2',
      role: MessageRole.assistant,
      content: '''I'll analyze the spreadsheet for you.

## Summary
- Total Revenue: **\$45,000**
- Total Expenses: **\$32,500**
- Net Profit: **\$12,500** (27.8% margin)

### Monthly Breakdown
| Month    | Revenue  | Expenses | Net      |
|----------|----------|----------|----------|
| January  | \$10,000 | \$7,500  | \$2,500  |
| February | \$12,000 | \$8,000  | \$4,000  |
| March    | \$15,000 | \$9,500  | \$5,500  |
| April    | \$8,000  | \$7,500  | \$500    |

```python
revenue = [10000, 12000, 15000, 8000]
expenses = [7500, 8000, 9500, 7500]
profit = [r - e for r, e in zip(revenue, expenses)]
print(f"Average monthly profit: \${sum(profit)/len(profit):,.0f}")
```

Would you like me to create a chart or dig deeper into any category?''',
      model: 'gemma-3b',
      toolUsed: 'File Read',
      timestamp: '2:28 PM',
    ),
    ChatMessage(
      id: '3',
      role: MessageRole.user,
      content: 'Yes, please create a chart showing the revenue vs expenses trend.',
      timestamp: '2:30 PM',
    ),
    ChatMessage(
      id: '4',
      role: MessageRole.assistant,
      content: '''I'll generate a visualization for you.

The trend shows revenue growing steadily from January to March, with a dip in April. Expenses remained relatively stable.

Key insights:
1. **March was the best month** — highest revenue and largest profit margin
2. **April revenue dropped 47%** — worth investigating the cause
3. **Expenses are well-controlled** — staying within \$7.5K-\$9.5K range

Would you like me to save this analysis as a document?''',
      model: 'gemma-3b',
      toolUsed: 'Code Execution (Python)',
      timestamp: '2:31 PM',
    ),
  ];

  // ──── Tools ────
  static final tools = [
    Tool(
      name: 'Python Runner',
      icon: '🐍',
      category: 'Code Execution',
      isEnabled: true,
      description: 'Execute Python code locally with sandboxing',
    ),
    Tool(
      name: 'JS/TS Runner',
      icon: '⚡',
      category: 'Code Execution',
      isEnabled: true,
      description: 'Execute JavaScript or TypeScript code',
    ),
    Tool(
      name: 'File Read',
      icon: '📖',
      category: 'File Operations',
      isEnabled: true,
      description: 'Read contents of user files (respects permissions)',
    ),
    Tool(
      name: 'File Write',
      icon: '✏️',
      category: 'File Operations',
      isEnabled: true,
      description: 'Create or modify user files (triggers diff)',
    ),
    Tool(
      name: 'File Search',
      icon: '🔍',
      category: 'File Operations',
      isEnabled: true,
      description: 'Search across user files by content or name',
    ),
    Tool(
      name: 'Web Search',
      icon: '🌐',
      category: 'Web & API',
      isEnabled: false,
      description: 'Search the web for information via API',
    ),
    Tool(
      name: 'URL Fetch',
      icon: '🔗',
      category: 'Web & API',
      isEnabled: true,
      description: 'Retrieve and summarize web page content',
    ),
    Tool(
      name: 'Calculator',
      icon: '🔢',
      category: 'Productivity',
      isEnabled: true,
      description: 'Perform mathematical calculations',
    ),
    Tool(
      name: 'Create Sheet',
      icon: '📊',
      category: 'Productivity',
      isEnabled: true,
      description: 'Generate a spreadsheet/CSV file',
    ),
    Tool(
      name: 'Create Document',
      icon: '📄',
      category: 'Productivity',
      isEnabled: true,
      description: 'Generate a Markdown document',
    ),
  ];

  // ──── Files ────
  static final files = [
    FileItem(name: 'Documents', isFolder: true, permission: 'gated', icon: '📁'),
    FileItem(name: 'Notes', isFolder: true, permission: 'gated', icon: '📁'),
    FileItem(name: 'Scripts', isFolder: true, permission: 'gated', icon: '📁'),
    FileItem(name: 'spec.md', isFolder: false, permission: 'gated', modified: 'Today', size: '12.4 KB', icon: '📄'),
    FileItem(name: 'data.csv', isFolder: false, permission: 'open', modified: '2d ago', size: '3.2 KB', icon: '📊'),
    FileItem(name: 'analyze.py', isFolder: false, permission: 'gated', modified: '1w ago', size: '1.1 KB', icon: '💻'),
    FileItem(name: 'diagram.png', isFolder: false, permission: 'open', modified: '3d ago', size: '245 KB', icon: '🖼'),
    FileItem(name: 'soul.md', isFolder: false, permission: 'locked', modified: 'Today', size: '2.8 KB', icon: '🧠'),
  ];

  // ──── Models ────
  static final localModels = [
    AIModel(
      name: 'gemma-3b-it',
      params: '3B',
      quant: 'Q4_0',
      size: '1.8 GB',
      status: 'ready',
      lastUsed: 'Today',
    ),
    AIModel(
      name: 'gemma-7b-it',
      params: '7B',
      quant: 'Q4_0',
      size: '3.9 GB',
      status: 'available',
    ),
    AIModel(
      name: 'gemma-2-27b-it',
      params: '27B',
      quant: 'Q4_0',
      size: '14.2 GB',
      status: 'gated',
    ),
  ];

  static final ollamaModels = [
    AIModel(
      name: 'llama3:8b',
      params: '8B',
      quant: 'Q4_K_M',
      size: '4.7 GB',
      status: 'ready',
      serverName: 'Desktop PC',
    ),
    AIModel(
      name: 'mistral:7b',
      params: '7B',
      quant: 'Q4_0',
      size: '4.1 GB',
      status: 'ready',
      serverName: 'Desktop PC',
    ),
    AIModel(
      name: 'codellama:13b',
      params: '13B',
      quant: 'Q4_K_M',
      size: '7.4 GB',
      status: 'ready',
      serverName: 'Desktop PC',
    ),
  ];

  static final cloudModels = [
    AIModel(name: 'GPT-4o', params: '—', quant: '—', size: '—', status: 'cloud', provider: 'OpenAI', context: '128K'),
    AIModel(name: 'Claude 3.5 Sonnet', params: '—', quant: '—', size: '—', status: 'cloud', provider: 'Anthropic', context: '200K'),
    AIModel(name: 'Gemini 1.5 Pro', params: '—', quant: '—', size: '—', status: 'cloud', provider: 'Google', context: '1M'),
    AIModel(name: 'Mistral Large', params: '—', quant: '—', size: '—', status: 'cloud', provider: 'Mistral', context: '128K'),
  ];

  // ──── Providers ────
  static final providers = [
    ProviderInfo(name: 'OpenAI', status: 'connected', keyMasked: 'sk-●●●●●●●●7x2'),
    ProviderInfo(name: 'Anthropic', status: 'connected', keyMasked: 'sk-ant-●●●●●●●d4f'),
    ProviderInfo(name: 'Google Gemini', status: 'connected', keyMasked: 'AI●●●●●●●●●k9'),
    ProviderInfo(name: 'HuggingFace', status: 'connected', keyMasked: 'hf_●●●●●●●●k3f'),
    ProviderInfo(name: 'OpenRouter', status: 'not configured'),
    ProviderInfo(name: 'Ollama', status: 'connected', keyMasked: 'No key needed', isKeyless: true),
    ProviderInfo(name: 'Mistral AI', status: 'not configured'),
  ];

  // ──── Persona ────
  static final personaFiles = [
    PersonaFile(name: 'Soul', icon: '🧠', summary: 'Helpful, honest, harmless'),
    PersonaFile(name: 'Personality', icon: '🎭', summary: 'Casual, concise'),
    PersonaFile(name: 'Memory', icon: '💭', summary: '12 entries'),
    PersonaFile(name: 'Rules', icon: '📏', summary: '8 rules'),
    PersonaFile(name: 'Knowledge', icon: '📚', summary: '3 entries'),
  ];
}

// ──── Data Classes ────

class Conversation {
  final String id, title, lastMessage, model, provider, timeAgo;
  final bool isPinned;
  final int tokenCount;

  const Conversation({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.model,
    required this.provider,
    required this.timeAgo,
    required this.isPinned,
    required this.tokenCount,
  });
}

enum MessageRole { user, assistant, system, tool }

class ChatMessage {
  final String id, content, timestamp;
  final MessageRole role;
  final String? attachment, model, toolUsed;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.attachment,
    this.model,
    this.toolUsed,
  });
}

class Tool {
  final String name, icon, category, description;
  final bool isEnabled;

  const Tool({
    required this.name,
    required this.icon,
    required this.category,
    required this.description,
    required this.isEnabled,
  });
}

class FileItem {
  final String name, permission, icon;
  final bool isFolder;
  final String? modified, size;

  const FileItem({
    required this.name,
    required this.isFolder,
    required this.permission,
    required this.icon,
    this.modified,
    this.size,
  });
}

class AIModel {
  final String name, params, quant, size, status;
  final String? provider, context, lastUsed, serverName;

  const AIModel({
    required this.name,
    required this.params,
    required this.quant,
    required this.size,
    required this.status,
    this.provider,
    this.context,
    this.lastUsed,
    this.serverName,
  });
}

class ProviderInfo {
  final String name, status;
  final String? keyMasked;
  final bool isKeyless;

  const ProviderInfo({
    required this.name,
    required this.status,
    this.keyMasked,
    this.isKeyless = false,
  });
}

class PersonaFile {
  final String name, icon, summary;

  const PersonaFile({
    required this.name,
    required this.icon,
    required this.summary,
  });
}
