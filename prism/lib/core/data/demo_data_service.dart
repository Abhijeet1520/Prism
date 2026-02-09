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

    // ── Notes ─────────────────────────────────────────
    final notesData = [
      (
        title: 'Meeting Notes — Product Sync',
        content: '## Product Sync — Dec 12\n\n'
            '### Attendees\n- Alex, Priya, Jordan, Sam\n\n'
            '### Key Decisions\n'
            '- **Launch date moved to Jan 15** — needs QA sign-off\n'
            '- Mobile app beta starts next Monday\n'
            '- Budget approved for cloud hosting migration\n\n'
            '### Action Items\n'
            '- [ ] Alex: Finalize API docs by Friday\n'
            '- [ ] Priya: Set up staging environment\n'
            '- [ ] Jordan: User testing script ready by Wednesday\n',
        tags: 'work,meetings,product',
      ),
      (
        title: 'Recipe: Thai Green Curry',
        content: '## Thai Green Curry (Serves 4)\n\n'
            '### Ingredients\n'
            '- 400ml coconut milk\n'
            '- 2 tbsp green curry paste\n'
            '- 300g chicken breast, sliced\n'
            '- 1 cup Thai basil leaves\n'
            '- 2 tbsp fish sauce\n'
            '- 1 tbsp palm sugar\n'
            '- Bamboo shoots, baby corn, bell pepper\n\n'
            '### Steps\n'
            '1. Heat thick coconut cream, fry curry paste until fragrant\n'
            '2. Add chicken, cook 5 min\n'
            '3. Pour remaining coconut milk, add vegetables\n'
            '4. Season with fish sauce and sugar\n'
            '5. Simmer 10 min, add basil leaves\n'
            '6. Serve over jasmine rice\n',
        tags: 'recipes,cooking,thai',
      ),
      (
        title: 'Book Recommendations',
        content: '## To Read\n\n'
            '- **"Project Hail Mary"** by Andy Weir — Sci-fi, highly rated\n'
            '- **"Thinking, Fast and Slow"** by Kahneman — Psychology/Decision-making\n'
            '- **"The Pragmatic Programmer"** — Tech classic, 20th anniversary edition\n'
            '- **"Klara and the Sun"** by Ishiguro — AI perspective fiction\n\n'
            '## Recently Finished\n'
            '- ✅ "Atomic Habits" — ⭐⭐⭐⭐⭐ Life-changing\n'
            '- ✅ "Deep Work" — ⭐⭐⭐⭐ Good frameworks\n'
            '- ✅ "Sapiens" — ⭐⭐⭐⭐ Fascinating big-picture view\n',
        tags: 'books,reading,lists',
      ),
      (
        title: 'Workout Plan — Week 1',
        content: '## Weekly Workout Schedule\n\n'
            '| Day | Focus | Duration |\n'
            '|-----|-------|----------|\n'
            '| Mon | Upper body + core | 45 min |\n'
            '| Tue | Cardio (run/cycle) | 30 min |\n'
            '| Wed | Lower body + stretch | 50 min |\n'
            '| Thu | Rest or yoga | 20 min |\n'
            '| Fri | Full body HIIT | 35 min |\n'
            '| Sat | Long run or hike | 60 min |\n'
            '| Sun | Rest | — |\n\n'
            '**Goal:** Build consistency first, increase intensity in week 3.\n',
        tags: 'fitness,health,routine',
      ),
      (
        title: 'Travel Ideas — 2025',
        content: '## Places to Visit\n\n'
            '### International\n'
            '- 🇯🇵 Japan — Cherry blossom season (Mar-Apr)\n'
            '- 🇮🇸 Iceland — Northern lights (Oct-Mar)\n'
            '- 🇵🇹 Portugal — Lisbon + Porto food tour\n\n'
            '### Domestic\n'
            '- Mountain cabin weekend — February\n'
            '- National park road trip — Summer\n'
            '- Beach house with friends — August\n\n'
            '**Budget:** Set aside \$200/month starting January.\n',
        tags: 'travel,planning,goals',
      ),
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
