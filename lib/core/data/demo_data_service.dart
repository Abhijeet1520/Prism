/// Prism Demo Data Service — Load and remove sample data for testing.
///
/// All demo data is tagged with 'demo' source/category for safe cleanup.
/// Conversations are tracked via AppSettings to enable selective deletion.
library;

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';

const _uuid = Uuid();

class DemoDataService {
  static const _demoConversationIdsKey = 'demo_conversation_uuids';
  static const demoSource = 'demo';

  // ─── Load Demo Data ────────────────────────────────

  /// Populate the database with sample data across all tables.
  /// Returns the count of items created.
  static Future<Map<String, int>> loadDemoData(PrismDatabase db) async {
    final counts = <String, int>{
      'conversations': 0,
      'messages': 0,
      'tasks': 0,
      'transactions': 0,
      'notes': 0,
      'errors': 0,
    };

    // ── Tasks ─────────────────────────────────────────
    final tasks = [
      (
        title: 'Review quarterly budget report',
        description: 'Go through the Q4 report and flag any anomalies before the meeting.',
        priority: 'high',
        dueDate: DateTime.now().add(const Duration(days: 2)),
      ),
      (
        title: 'Schedule dentist appointment',
        description: 'Check availability for next week, preferably morning slot.',
        priority: 'medium',
        dueDate: DateTime.now().add(const Duration(days: 5)),
      ),
      (
        title: 'Buy groceries for the week',
        description: 'Milk, eggs, bread, vegetables, chicken, pasta, olive oil.',
        priority: 'medium',
        dueDate: DateTime.now().add(const Duration(days: 1)),
      ),
      (
        title: 'Finish reading "Atomic Habits"',
        description: 'Last 3 chapters remaining. Take notes on key takeaways.',
        priority: 'low',
        dueDate: DateTime.now().add(const Duration(days: 14)),
      ),
      (
        title: 'Update resume and LinkedIn',
        description: 'Add recent project experience and update skills section.',
        priority: 'high',
        dueDate: DateTime.now().add(const Duration(days: 3)),
      ),
      (
        title: 'Plan weekend hiking trip',
        description: 'Research trails near the city. Check weather forecast.',
        priority: 'low',
        dueDate: DateTime.now().add(const Duration(days: 7)),
      ),
      (
        title: 'Fix leaking kitchen faucet',
        description: 'Buy replacement washer from hardware store. Watch repair video first.',
        priority: 'medium',
        dueDate: DateTime.now().add(const Duration(days: 4)),
      ),
    ];

    for (final task in tasks) {
      try {
        await db.createTask(
          uuid: 'demo-task-${_uuid.v4()}',
          title: task.title,
          description: task.description,
          priority: task.priority,
          category: demoSource,
          dueDate: task.dueDate,
        );
        counts['tasks'] = counts['tasks']! + 1;
      } catch (e) {
        counts['errors'] = counts['errors']! + 1;
      }
    }

    // ── Notes (PARA-categorized) ─────────────────────

    // PROJECTS — active goals with deadlines
    final projectNotes = [
      (
        title: 'Mobile App Redesign',
        content: '## Mobile App Redesign — Q1 2025\n\n'
            '### Objective\nModernize the UI/UX for our flagship mobile app.\n\n'
            '### Milestones\n'
            '- [x] User research complete (Jan 8)\n'
            '- [x] Wireframes approved (Jan 20)\n'
            '- [ ] High-fidelity mockups (Feb 5)\n'
            '- [ ] Developer handoff (Feb 15)\n'
            '- [ ] Beta release (Mar 1)\n'
            '- [ ] Production release (Mar 15)\n\n'
            '### Stack\nFlutter 3.x, Riverpod, Material 3, custom design system\n\n'
            '### Team\n- Design: Sarah, Omar\n- Dev: Alex, Priya\n- QA: Jordan\n',
        tags: 'project,work,app,design',
      ),
      (
        title: 'Home Office Renovation',
        content: '## Home Office Setup\n\n'
            '### Budget: \$2,500\n\n'
            '### Shopping List\n'
            '- [ ] Standing desk (IKEA Bekant) — \$500\n'
            '- [ ] Ergonomic chair (Herman Miller Aeron) — \$1,200\n'
            '- [ ] Monitor arm (Ergotron LX) — \$130\n'
            '- [x] LED desk lamp — \$45\n'
            '- [ ] Cable management kit — \$25\n'
            '- [ ] Acoustic panels (4-pack) — \$80\n\n'
            '### Timeline\n'
            '- Order furniture by Feb 1\n'
            '- Assembly weekend: Feb 8-9\n'
            '- Cable management: Feb 10\n',
        tags: 'project,home,renovation,office',
      ),
      (
        title: 'Side Project — Recipe API',
        content: '## Recipe Collection API\n\n'
            '### Goal\nBuild a REST API to manage personal recipe collection.\n\n'
            '### Tech Stack\n- Backend: Dart Shelf + Drift (SQLite)\n'
            '- Auth: JWT tokens\n- Deploy: Docker + Railway\n\n'
            '### Endpoints\n'
            '```\nGET    /recipes         — List all\n'
            'POST   /recipes         — Create new\n'
            'GET    /recipes/:id     — Get single\n'
            'PUT    /recipes/:id     — Update\n'
            'DELETE /recipes/:id     — Delete\n'
            'GET    /recipes/search  — Full-text search\n```\n\n'
            '### Progress\n- [x] Database schema\n- [x] CRUD endpoints\n'
            '- [ ] Auth middleware\n- [ ] Search with FTS5\n- [ ] Docker setup\n',
        tags: 'project,coding,api,recipes',
      ),
    ];

    // AREAS — ongoing responsibilities
    final areaNotes = [
      (
        title: 'Health & Fitness Tracker',
        content: '## Health & Fitness — Ongoing\n\n'
            '### Weekly Goals\n'
            '- Workout 4x per week (Mon/Wed/Fri/Sat)\n'
            '- 10,000 steps daily\n'
            '- 2L water minimum\n'
            '- Sleep 7+ hours\n\n'
            '### Current Program\n'
            '| Day | Focus | Duration |\n'
            '|-----|-------|----------|\n'
            '| Mon | Upper body + core | 45 min |\n'
            '| Wed | Lower body + stretch | 50 min |\n'
            '| Fri | Full body HIIT | 35 min |\n'
            '| Sat | Long run or hike | 60 min |\n\n'
            '### Supplements\n- Vitamin D 2000 IU daily\n- Omega-3 fish oil\n- Magnesium before bed\n',
        tags: 'area,health,fitness,routine',
      ),
      (
        title: 'Personal Finance Dashboard',
        content: '## Monthly Finance Review\n\n'
            '### Budget Allocation\n'
            '| Category | Budget | % |\n'
            '|----------|--------|---|\n'
            '| Rent & Utilities | \$1,800 | 45% |\n'
            '| Groceries | \$400 | 10% |\n'
            '| Transport | \$200 | 5% |\n'
            '| Savings & Invest | \$800 | 20% |\n'
            '| Entertainment | \$200 | 5% |\n'
            '| Dining Out | \$200 | 5% |\n'
            '| Miscellaneous | \$400 | 10% |\n\n'
            '### Goals\n- Emergency fund: 6 months expenses (\$18K target)\n'
            '- Current: \$12,400 (69%)\n'
            '- Index fund: \$500/month auto-invest\n',
        tags: 'area,finance,budget,planning',
      ),
      (
        title: 'Career Development Plan',
        content: '## Career Growth — 2025\n\n'
            '### Focus Areas\n'
            '1. **Technical leadership** — lead architecture decisions\n'
            '2. **Public speaking** — 2 conference talks this year\n'
            '3. **Mentoring** — mentor 2 junior devs\n\n'
            '### Learning Plan\n'
            '- System Design: "Designing Data-Intensive Applications" (Q1)\n'
            '- ML/AI fundamentals course (Q2)\n'
            '- Cloud certifications: GCP Associate (Q3)\n\n'
            '### Network\n'
            '- Attend 1 meetup/month\n'
            '- Write 2 blog posts/month\n'
            '- Contribute to 1 open-source project\n',
        tags: 'area,career,growth,learning',
      ),
    ];

    // RESOURCES — reference material
    final resourceNotes = [
      (
        title: 'Recipe: Thai Green Curry',
        content: '## Thai Green Curry (Serves 4)\n\n'
            '### Ingredients\n'
            '- 400ml coconut milk\n- 2 tbsp green curry paste\n'
            '- 300g chicken breast, sliced\n- 1 cup Thai basil leaves\n'
            '- 2 tbsp fish sauce\n- 1 tbsp palm sugar\n'
            '- Bamboo shoots, baby corn, bell pepper\n\n'
            '### Steps\n'
            '1. Heat thick coconut cream, fry curry paste until fragrant\n'
            '2. Add chicken, cook 5 min\n'
            '3. Pour remaining coconut milk, add vegetables\n'
            '4. Season with fish sauce and sugar\n'
            '5. Simmer 10 min, add basil leaves\n'
            '6. Serve over jasmine rice\n\n'
            '⏱ Prep: 15 min | Cook: 25 min | Total: 40 min\n',
        tags: 'resource,recipes,cooking,thai',
      ),
      (
        title: 'Recipe: Overnight Oats (5 Variations)',
        content: '## Overnight Oats Base\n\n'
            '### Base (all variations)\n'
            '- ½ cup rolled oats\n- ½ cup milk (any kind)\n'
            '- ¼ cup yogurt\n- 1 tbsp chia seeds\n- 1 tsp honey\n\n'
            '### Variations\n'
            '**1. Berry Blast** — mixed berries + vanilla extract\n'
            '**2. Chocolate PB** — cocoa powder + peanut butter + banana\n'
            '**3. Tropical** — mango + coconut flakes + lime zest\n'
            '**4. Apple Pie** — diced apple + cinnamon + walnuts\n'
            '**5. Matcha** — matcha powder + honey + almonds\n\n'
            'Mix night before, refrigerate, eat cold or warm up.\n',
        tags: 'resource,recipes,breakfast,healthy',
      ),
      (
        title: 'Book Notes: Atomic Habits',
        content: '## Atomic Habits — James Clear\n⭐⭐⭐⭐⭐\n\n'
            '### Core Ideas\n'
            '1. **1% better every day** — compound gains\n'
            '2. **Systems > Goals** — focus on the process\n'
            '3. **Identity-based habits** — "I am a runner" vs "I want to run"\n'
            '4. **4 Laws of Behavior Change**:\n'
            '   - Make it obvious (cue)\n'
            '   - Make it attractive (craving)\n'
            '   - Make it easy (response)\n'
            '   - Make it satisfying (reward)\n\n'
            '### Key Takeaways\n'
            '- Habit stacking: "After [CURRENT HABIT], I will [NEW HABIT]"\n'
            '- Environment design matters more than motivation\n'
            '- Never miss twice — bad days are OK, quitting isn\'t\n'
            '- Track habits visually for dopamine\n\n'
            '### Rating: Must-read for anyone wanting to build better systems.\n',
        tags: 'resource,books,self-improvement,habits',
      ),
      (
        title: 'Book Notes: Designing Data-Intensive Applications',
        content: '## DDIA — Martin Kleppmann\n⭐⭐⭐⭐⭐\n\n'
            '### Part I: Foundations\n'
            '- **Reliability** — tolerating hardware/software faults\n'
            '- **Scalability** — describing load, measuring performance\n'
            '- **Maintainability** — operability, simplicity, evolvability\n\n'
            '### Part II: Distributed Data\n'
            '- Replication: leader-based, multi-leader, leaderless\n'
            '- Partitioning: key range vs hash partitioning\n'
            '- Transactions: ACID, isolation levels, serializability\n'
            '- Consistency & Consensus: linearizability, total order broadcast\n\n'
            '### Part III: Derived Data\n'
            '- Batch processing: MapReduce, Spark\n'
            '- Stream processing: event sourcing, CDC\n'
            '- Future of data systems: unbundling databases\n\n'
            '### Key Insight\n'
            '"The boundary between a simple feature request and a redesign of the '
            'entire system architecture can be surprisingly thin."\n',
        tags: 'resource,books,engineering,distributed-systems',
      ),
      (
        title: 'Article: State of Flutter 2025',
        content: '## State of Flutter in 2025\n*Source: flutter.dev blog*\n\n'
            '### Key Highlights\n'
            '- **Dart 3.x** — Records, patterns, sealed classes stable\n'
            '- **Impeller** — Default on iOS, Android in preview\n'
            '- **WebAssembly** — dart2wasm for web builds\n'
            '- **Firebase Vertex AI** — On-device + cloud AI integration\n'
            '- **DevTools** — Enhanced memory + performance profiling\n\n'
            '### Ecosystem Growth\n'
            '- 1M+ apps published\n- 30K+ pub.dev packages\n'
            '- Top industries: fintech, e-commerce, health, education\n\n'
            '### What to Learn\n'
            '- Riverpod 3.x (code generation approach)\n'
            '- Drift for local persistence\n'
            '- Custom render objects for advanced UI\n'
            '- Platform channels for native integration\n',
        tags: 'resource,articles,flutter,technology',
      ),
      (
        title: 'Research: On-Device LLM Inference',
        content: '## On-Device LLM Inference — 2024 Survey\n\n'
            '### Key Papers\n'
            '1. **"Efficient LLM Inference on Mobile"** (Google, 2024)\n'
            '   - 4-bit quantization maintains 95% quality\n'
            '   - GGUF format preferred for mobile deployment\n'
            '   - Memory requirements: 2B params ≈ 1.5 GB RAM\n\n'
            '2. **"TinyLlama: An Open-Source Small LLM"** (Zhang et al.)\n'
            '   - 1.1B parameters, trained on 3T tokens\n'
            '   - Competitive with 7B models on some benchmarks\n\n'
            '3. **"Gemma 2: Improving Open Models"** (Google DeepMind)\n'
            '   - 2B and 9B variants\n'
            '   - Knowledge distillation from larger models\n'
            '   - Best-in-class for size category\n\n'
            '### Practical Notes\n'
            '- Q4_K_M quantization: best quality/size tradeoff\n'
            '- Flash attention crucial for context > 2K tokens\n'
            '- KV cache optimization reduces memory 40%\n'
            '- Speculative decoding: 2x speedup with draft model\n',
        tags: 'resource,research,ai,llm,mobile',
      ),
      (
        title: 'Research: Privacy-Preserving AI',
        content: '## Privacy-Preserving Machine Learning\n\n'
            '### Techniques\n'
            '1. **Federated Learning**\n'
            '   - Train on user devices, only share gradients\n'
            '   - Used by: Gboard, Apple Siri, health apps\n'
            '   - Challenge: non-IID data distribution\n\n'
            '2. **Differential Privacy**\n'
            '   - Add calibrated noise to query results\n'
            '   - ε-differential privacy budget\n'
            '   - Apple: ε = 2-8 per day for usage analytics\n\n'
            '3. **On-Device Inference**\n'
            '   - Data never leaves the device\n'
            '   - Prism approach: local GGUF models\n'
            '   - Tradeoff: model size vs. capability\n\n'
            '### Tools\n'
            '- TFLite / CoreML for mobile models\n'
            '- llama.cpp for on-device LLMs\n'
            '- PySyft for federated learning research\n',
        tags: 'resource,research,ai,privacy,security',
      ),
    ];

    // ARCHIVES — completed or inactive
    final archiveNotes = [
      (
        title: '[Completed] Website Redesign 2024',
        content: '## Website Redesign — Completed Dec 2024\n\n'
            '### Summary\n'
            'Full redesign of company website from WordPress to Next.js.\n\n'
            '### Results\n'
            '- Page load time: 4.2s → 1.1s (74% improvement)\n'
            '- Lighthouse score: 52 → 97\n'
            '- Bounce rate: -23%\n'
            '- Mobile conversions: +18%\n\n'
            '### Lessons Learned\n'
            '- Server-side rendering critical for SEO\n'
            '- Image optimization (WebP + lazy load) biggest win\n'
            '- A/B test everything before full rollout\n'
            '- Design system saved 30% development time\n',
        tags: 'archive,project,web,completed',
      ),
      (
        title: '[Archive] Travel Ideas — 2024',
        content: '## Places Visited — 2024\n\n'
            '### Trips Completed\n'
            '- 🇯🇵 Japan (April) — Cherry blossom season, Tokyo + Kyoto\n'
            '  - Highlights: Fushimi Inari, Tsukiji Outer Market\n'
            '  - Total cost: \$3,200 for 10 days\n\n'
            '- ⛰️ National Park Road Trip (July)\n'
            '  - Yosemite → Sequoia → Death Valley\n'
            '  - 7 days, 1,200 miles driven\n\n'
            '- 🏖️ Beach Weekend (September)\n'
            '  - Group trip, 8 friends, rented beach house\n\n'
            '### For Next Year\n'
            'See "Travel Ideas — 2025" in Project notes\n',
        tags: 'archive,travel,completed,memories',
      ),
    ];

    // Combine all notes
    final notesData = [
      ...projectNotes,
      ...areaNotes,
      ...resourceNotes,
      ...archiveNotes,
    ];

    for (final note in notesData) {
      try {
        await db.createNote(
          uuid: 'demo-note-${_uuid.v4()}',
          title: note.title,
          content: note.content,
          tags: note.tags,
          source: demoSource,
        );
        counts['notes'] = counts['notes']! + 1;
      } catch (e) {
        counts['errors'] = counts['errors']! + 1;
      }
    }

    // ── Transactions ──────────────────────────────────
    final now = DateTime.now();
    final txns = [
      (amount: -42.50, category: 'Groceries', type: 'expense', desc: 'Weekly grocery run', daysAgo: 0),
      (amount: -12.99, category: 'Entertainment', type: 'expense', desc: 'Netflix subscription', daysAgo: 1),
      (amount: 3200.00, category: 'Salary', type: 'income', desc: 'Monthly paycheck', daysAgo: 2),
      (amount: -8.75, category: 'Transport', type: 'expense', desc: 'Uber ride home', daysAgo: 2),
      (amount: -65.00, category: 'Dining', type: 'expense', desc: 'Dinner at Pasta House', daysAgo: 3),
      (amount: -29.99, category: 'Shopping', type: 'expense', desc: 'Phone case and screen protector', daysAgo: 4),
      (amount: -150.00, category: 'Utilities', type: 'expense', desc: 'Electricity bill — December', daysAgo: 5),
      (amount: 50.00, category: 'Freelance', type: 'income', desc: 'Logo design for coffee shop', daysAgo: 6),
      (amount: -22.00, category: 'Health', type: 'expense', desc: 'Pharmacy — vitamins', daysAgo: 7),
      (amount: -35.00, category: 'Groceries', type: 'expense', desc: 'Farmer\'s market produce', daysAgo: 8),
    ];

    for (final tx in txns) {
      try {
        await db.logTransaction(
          uuid: 'demo-txn-${_uuid.v4()}',
          amount: tx.amount,
          category: tx.category,
          type: tx.type,
          description: tx.desc,
          source: demoSource,
          date: now.subtract(Duration(days: tx.daysAgo)),
        );
        counts['transactions'] = counts['transactions']! + 1;
      } catch (e) {
        counts['errors'] = counts['errors']! + 1;
      }
    }

    // ── Conversations ─────────────────────────────────
    final convUuids = <String>[];

    try {
      // Conversation 1: General Q&A
      final conv1Uuid = 'demo-conv-${_uuid.v4()}';
      convUuids.add(conv1Uuid);
      final conv1Id = await db.createConversation(
        uuid: conv1Uuid,
        title: 'What can you help me with?',
        systemPrompt: 'You are Prism, a helpful AI assistant.',
      );
      counts['conversations'] = counts['conversations']! + 1;

      final conv1Messages = [
        ('user', 'Hey! What kind of things can you help me with?'),
        ('assistant',
            'I can help with quite a lot! Here are some things I\'m good at:\n\n'
                '- **Task management** — Create, organize, and track your to-dos\n'
                '- **Note taking** — Save and search your thoughts and ideas\n'
                '- **Budget tracking** — Log expenses and income, see spending patterns\n'
                '- **General questions** — Research, brainstorming, writing help\n'
                '- **Document scanning** — Extract text from images using your camera\n\n'
                'Just ask naturally and I\'ll figure out what tool to use!'),
        ('user', 'That\'s cool! Can you add a task for me?'),
        ('assistant',
            'Of course! Just tell me what you need to do, when it\'s due, and how important it is. '
                'For example: "Remind me to call the insurance company by Friday, it\'s high priority."'),
      ];

      for (final msg in conv1Messages) {
        await db.addMessage(
          uuid: 'demo-msg-${_uuid.v4()}',
          conversationId: conv1Id,
          role: msg.$1,
          content: msg.$2,
        );
        counts['messages'] = counts['messages']! + 1;
      }

      // Conversation 2: Budget discussion
      final conv2Uuid = 'demo-conv-${_uuid.v4()}';
      convUuids.add(conv2Uuid);
      final conv2Id = await db.createConversation(
        uuid: conv2Uuid,
        title: 'Budget review this month',
      );
      counts['conversations'] = counts['conversations']! + 1;

      final conv2Messages = [
        ('user', 'How much have I spent on groceries this month?'),
        ('assistant',
            'Looking at your transactions, you\'ve spent **\$77.50** on groceries this month across 2 purchases:\n\n'
                '- \$42.50 — Weekly grocery run (today)\n'
                '- \$35.00 — Farmer\'s market produce (8 days ago)\n\n'
                'Would you like me to set a monthly grocery budget to track against?'),
        ('user', 'Yeah, set it to \$300 per month'),
        ('assistant',
            'Got it! I\'ll track your grocery spending against a \$300 monthly budget. '
                'You\'ve used about **26%** so far — you\'re on track. '
                'I\'ll let you know if you\'re getting close to the limit.'),
      ];

      for (final msg in conv2Messages) {
        await db.addMessage(
          uuid: 'demo-msg-${_uuid.v4()}',
          conversationId: conv2Id,
          role: msg.$1,
          content: msg.$2,
        );
        counts['messages'] = counts['messages']! + 1;
      }
    } catch (e) {
      counts['errors'] = counts['errors']! + 1;
    }

    // Store conversation UUIDs for later cleanup
    await db.setSetting(_demoConversationIdsKey, convUuids.join(','));

    return counts;
  }

  // ─── Remove Demo Data ──────────────────────────────

  /// Remove all demo data from the database without affecting user data.
  static Future<Map<String, int>> removeDemoData(PrismDatabase db) async {
    final counts = <String, int>{
      'tasks': 0,
      'notes': 0,
      'transactions': 0,
      'conversations': 0,
      'messages': 0,
    };

    // Delete demo tasks (category = 'demo')
    counts['tasks'] = await (db.delete(db.taskEntries)
          ..where((t) => t.category.equals(demoSource)))
        .go();

    // Delete demo notes (source = 'demo')
    counts['notes'] = await (db.delete(db.notes)
          ..where((n) => n.source.equals(demoSource)))
        .go();

    // Delete demo transactions (source = 'demo')
    counts['transactions'] = await (db.delete(db.transactions)
          ..where((t) => t.source.equals(demoSource)))
        .go();

    // Delete demo conversations and their messages
    final convIdsStr = await db.getSetting(_demoConversationIdsKey);
    if (convIdsStr != null && convIdsStr.isNotEmpty) {
      final convUuids = convIdsStr.split(',');
      for (final uuid in convUuids) {
        // Get conversation DB ID to delete messages
        final conv = await db.getConversation(uuid);
        if (conv != null) {
          final msgCount = await (db.delete(db.messages)
                ..where((m) => m.conversationId.equals(conv.id)))
              .go();
          counts['messages'] = counts['messages']! + msgCount;
        }
        // Delete the conversation itself
        final convCount = await (db.delete(db.conversations)
              ..where((c) => c.uuid.equals(uuid)))
            .go();
        counts['conversations'] = counts['conversations']! + convCount;
      }

      // Clean up the tracking key
      await (db.delete(db.appSettings)
            ..where((s) => s.key.equals(_demoConversationIdsKey)))
          .go();
    }

    // Also delete any items with UUIDs starting with 'demo-'
    // as a safety net for any edge cases
    counts['tasks'] = counts['tasks']! +
        await (db.delete(db.taskEntries)
              ..where((t) => t.uuid.like('demo-%')))
            .go();
    counts['notes'] = counts['notes']! +
        await (db.delete(db.notes)..where((n) => n.uuid.like('demo-%'))).go();
    counts['transactions'] = counts['transactions']! +
        await (db.delete(db.transactions)
              ..where((t) => t.uuid.like('demo-%')))
            .go();

    return counts;
  }

  // ─── Check Demo Data ───────────────────────────────

  /// Check whether demo data exists in the database.
  static Future<bool> hasDemoData(PrismDatabase db) async {
    // Check for demo conversation tracking key
    final convIds = await db.getSetting(_demoConversationIdsKey);
    if (convIds != null && convIds.isNotEmpty) return true;

    // Check for any demo-tagged items
    final demoTask = await (db.select(db.taskEntries)
          ..where((t) => t.category.equals(demoSource))
          ..limit(1))
        .getSingleOrNull();
    if (demoTask != null) return true;

    final demoNote = await (db.select(db.notes)
          ..where((n) => n.source.equals(demoSource))
          ..limit(1))
        .getSingleOrNull();
    if (demoNote != null) return true;

    final demoTxn = await (db.select(db.transactions)
          ..where((t) => t.source.equals(demoSource))
          ..limit(1))
        .getSingleOrNull();
    if (demoTxn != null) return true;

    return false;
  }

  /// Get a summary of what demo data currently exists.
  static Future<Map<String, int>> getDemoDataCounts(PrismDatabase db) async {
    final taskCount = await (db.select(db.taskEntries)
          ..where((t) =>
              t.category.equals(demoSource) | t.uuid.like('demo-%')))
        .get();
    final noteCount = await (db.select(db.notes)
          ..where(
              (n) => n.source.equals(demoSource) | n.uuid.like('demo-%')))
        .get();
    final txnCount = await (db.select(db.transactions)
          ..where(
              (t) => t.source.equals(demoSource) | t.uuid.like('demo-%')))
        .get();

    int convCount = 0;
    final convIds = await db.getSetting(_demoConversationIdsKey);
    if (convIds != null && convIds.isNotEmpty) {
      convCount = convIds.split(',').length;
    }

    return {
      'tasks': taskCount.length,
      'notes': noteCount.length,
      'transactions': txnCount.length,
      'conversations': convCount,
    };
  }
}
