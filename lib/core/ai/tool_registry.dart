/// Tool definitions for function calling with Gemini / OpenAI-compatible APIs.
///
/// Each tool has a [ToolSpec] for the LLM and a real executor that
/// reads/writes to the Drift database. 14 tools covering full CRUD
/// for tasks, notes, and finance.
library;

import 'dart:convert';
import 'dart:io' show Platform;
import 'package:langchain/langchain.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';

/// Registry of all available tools the AI can invoke.
class PrismToolRegistry {
  PrismToolRegistry._();

  /// All tool specifications for binding to the LLM.
  static List<ToolSpec> get specs => [
        // Tasks (CRUD)
        addTaskTool,
        editTaskTool,
        deleteTaskTool,
        toggleTaskTool,
        listTasksTool,
        // Finance
        logExpenseTool,
        deleteExpenseTool,
        summarizeFinancesTool,
        // Notes (CRUD)
        searchNotesTool,
        createNoteTool,
        editNoteTool,
        deleteNoteTool,
        // Utility
        getWeatherTool,
        readNotificationsTool,
      ];

  /// Convert all tool specs to OpenAI function-calling format.
  static List<Map<String, dynamic>> toOpenAITools() {
    return specs.map((t) => toolSpecToOpenAI(t)).toList();
  }

  /// Convert a single [ToolSpec] to OpenAI function-calling format.
  /// Strips empty 'required' arrays as Gemini rejects them.
  static Map<String, dynamic> toolSpecToOpenAI(ToolSpec tool) {
    final params = Map<String, dynamic>.from(tool.inputJsonSchema);
    // Gemini's OpenAI-compatible endpoint rejects empty required arrays
    final req = params['required'];
    if (req is List && req.isEmpty) {
      params.remove('required');
    }
    return {
      'type': 'function',
      'function': {
        'name': tool.name,
        'description': tool.description,
        'parameters': params,
      },
    };
  }

  /// Parse tool calls from an OpenAI-format response `tool_calls` array.
  static List<Map<String, dynamic>> parseToolCalls(List<dynamic> toolCalls) {
    return toolCalls.map((tc) {
      final call = tc as Map<String, dynamic>;
      final function_ = call['function'] as Map<String, dynamic>? ?? {};
      return {
        'id': call['id'] ?? '',
        'name': function_['name'] ?? '',
        'arguments': function_['arguments'] is String
            ? jsonDecode(function_['arguments'] as String)
            : function_['arguments'] ?? {},
      };
    }).toList();
  }

  // ═══════════════════════════════════════════════════
  // ─── TOOL SPECS ────────────────────────────────────
  // ═══════════════════════════════════════════════════

  // ── Tasks ───────────────────────────────────────────

  static const addTaskTool = ToolSpec(
    name: 'add_task',
    description: 'Create a new task or to-do item for the user.',
    inputJsonSchema: {
      'type': 'object',
      'properties': {
        'title': {
          'type': 'string',
          'description': 'The title of the task',
        },
        'priority': {
          'type': 'string',
          'enum': ['low', 'medium', 'high'],
          'description': 'Priority level (default: medium)',
        },
        'due_date': {
          'type': 'string',
          'description': 'Due date in ISO 8601 format (optional)',
        },
      },
      'required': ['title'],
    },
  );

  static const editTaskTool = ToolSpec(
    name: 'edit_task',
    description:
        'Edit an existing task. Finds by title (fuzzy match). Can update title, priority, or due date.',
    inputJsonSchema: {
      'type': 'object',
      'properties': {
        'title': {
          'type': 'string',
          'description':
              'Current title of the task to find (partial match works)',
        },
        'new_title': {
          'type': 'string',
          'description': 'New title for the task (optional)',
        },
        'priority': {
          'type': 'string',
          'enum': ['low', 'medium', 'high'],
          'description': 'New priority level (optional)',
        },
        'due_date': {
          'type': 'string',
          'description': 'New due date in ISO 8601 format (optional)',
        },
      },
      'required': ['title'],
    },
  );

  static const deleteTaskTool = ToolSpec(
    name: 'delete_task',
    description:
        'Delete a task by title (fuzzy match). Removes it permanently.',
    inputJsonSchema: {
      'type': 'object',
      'properties': {
        'title': {
          'type': 'string',
          'description':
              'Title of the task to delete (partial match works)',
        },
      },
      'required': ['title'],
    },
  );

  static const toggleTaskTool = ToolSpec(
    name: 'toggle_task',
    description:
        'Mark a task as completed or un-complete it. Finds by title (fuzzy match).',
    inputJsonSchema: {
      'type': 'object',
      'properties': {
        'title': {
          'type': 'string',
          'description':
              'Title of the task to toggle (partial match works)',
        },
      },
      'required': ['title'],
    },
  );

  static const listTasksTool = ToolSpec(
    name: 'list_tasks',
    description:
        'List all tasks, optionally filtered by status (pending/completed/all).',
    inputJsonSchema: {
      'type': 'object',
      'properties': {
        'status': {
          'type': 'string',
          'enum': ['pending', 'completed', 'all'],
          'description': 'Filter by status (default: all)',
        },
      },
    },
  );

  // ── Finance ─────────────────────────────────────────

  static const logExpenseTool = ToolSpec(
    name: 'log_expense',
    description: 'Log a financial transaction (expense or income).',
    inputJsonSchema: {
      'type': 'object',
      'properties': {
        'amount': {
          'type': 'number',
          'description': 'The transaction amount (positive number)',
        },
        'category': {
          'type': 'string',
          'description':
              'Category (e.g. groceries, transport, dining, salary, freelance)',
        },
        'description': {
          'type': 'string',
          'description': 'Brief description of the transaction',
        },
        'type': {
          'type': 'string',
          'enum': ['expense', 'income'],
          'description': 'Whether this is an expense or income',
        },
      },
      'required': ['amount', 'category', 'type'],
    },
  );

  static const deleteExpenseTool = ToolSpec(
    name: 'delete_expense',
    description:
        'Delete a financial transaction by matching description/category/amount.',
    inputJsonSchema: {
      'type': 'object',
      'properties': {
        'description': {
          'type': 'string',
          'description':
              'Description or category to search for (partial match)',
        },
        'amount': {
          'type': 'number',
          'description': 'Exact amount to match (optional, helps narrow down)',
        },
      },
      'required': ['description'],
    },
  );

  static const summarizeFinancesTool = ToolSpec(
    name: 'summarize_finances',
    description:
        'Get a summary of the current month\'s finances — total income, expenses, and breakdown by category.',
    inputJsonSchema: {
      'type': 'object',
      'properties': {
        'month': {
          'type': 'string',
          'description':
              'Month to summarize in YYYY-MM format (default: current month)',
        },
      },
    },
  );

  // ── Notes ───────────────────────────────────────────

  static const searchNotesTool = ToolSpec(
    name: 'search_notes',
    description:
        'Search the user\'s knowledge base / brain for relevant notes.',
    inputJsonSchema: {
      'type': 'object',
      'properties': {
        'query': {
          'type': 'string',
          'description': 'The search query',
        },
        'limit': {
          'type': 'integer',
          'description': 'Max results to return (default 5)',
        },
      },
      'required': ['query'],
    },
  );

  static const createNoteTool = ToolSpec(
    name: 'create_note',
    description: 'Create a note in the user\'s knowledge base / Second Brain.',
    inputJsonSchema: {
      'type': 'object',
      'properties': {
        'title': {
          'type': 'string',
          'description': 'The title of the note',
        },
        'content': {
          'type': 'string',
          'description': 'The note body / content',
        },
        'tags': {
          'type': 'string',
          'description': 'Comma-separated tags (e.g. "project,work")',
        },
      },
      'required': ['title', 'content'],
    },
  );

  static const editNoteTool = ToolSpec(
    name: 'edit_note',
    description:
        'Edit an existing note. Finds by title (fuzzy match). Can update title, content, or tags.',
    inputJsonSchema: {
      'type': 'object',
      'properties': {
        'title': {
          'type': 'string',
          'description':
              'Current title of the note to find (partial match works)',
        },
        'new_title': {
          'type': 'string',
          'description': 'New title (optional)',
        },
        'content': {
          'type': 'string',
          'description': 'New content (optional — replaces entire body)',
        },
        'tags': {
          'type': 'string',
          'description': 'New comma-separated tags (optional)',
        },
      },
      'required': ['title'],
    },
  );

  static const deleteNoteTool = ToolSpec(
    name: 'delete_note',
    description:
        'Delete a note from the knowledge base by title (fuzzy match).',
    inputJsonSchema: {
      'type': 'object',
      'properties': {
        'title': {
          'type': 'string',
          'description':
              'Title of the note to delete (partial match works)',
        },
      },
      'required': ['title'],
    },
  );

  // ── Utility ─────────────────────────────────────────

  static const getWeatherTool = ToolSpec(
    name: 'get_weather',
    description: 'Get the current weather for a location.',
    inputJsonSchema: {
      'type': 'object',
      'properties': {
        'location': {
          'type': 'string',
          'description': 'City and country, e.g. "San Francisco, US"',
        },
      },
      'required': ['location'],
    },
  );

  static const readNotificationsTool = ToolSpec(
    name: 'read_notifications',
    description:
        'Read recent device notifications (Android only). Can extract financial info from payment apps.',
    inputJsonSchema: {
      'type': 'object',
      'properties': {
        'limit': {
          'type': 'integer',
          'description': 'Max notifications to return (default 20)',
        },
        'filter_app': {
          'type': 'string',
          'description':
              'Filter by app package name (e.g. "com.google.android.apps.banking")',
        },
      },
    },
  );

  // ═══════════════════════════════════════════════════
  // ─── NOTIFICATION CACHE ────────────────────────────
  // ═══════════════════════════════════════════════════

  static final List<Map<String, dynamic>> _notificationHistory = [];

  static void onNotificationPosted(ServiceNotificationEvent event) {
    _notificationHistory.insert(0, {
      'id': event.id,
      'packageName': event.packageName,
      'title': event.title ?? '',
      'content': event.content ?? '',
      'timestamp': DateTime.now().toIso8601String(),
    });
    if (_notificationHistory.length > 100) {
      _notificationHistory.removeRange(100, _notificationHistory.length);
    }
  }

  static Future<void> initNotificationListener() async {
    if (!Platform.isAndroid) return;
    final hasPermission =
        await NotificationListenerService.isPermissionGranted();
    if (!hasPermission) return;
    NotificationListenerService.notificationsStream.listen((event) {
      onNotificationPosted(event);
    });
  }

  // ═══════════════════════════════════════════════════
  // ─── EXECUTORS ─────────────────────────────────────
  // ═══════════════════════════════════════════════════

  /// Execute a tool call and return the result as a JSON string.
  static Future<String> execute(
    String toolName,
    Map<String, dynamic> args, {
    PrismDatabase? db,
  }) async {
    switch (toolName) {
      // Tasks
      case 'add_task':
        return _executeAddTask(args, db);
      case 'edit_task':
        return _executeEditTask(args, db);
      case 'delete_task':
        return _executeDeleteTask(args, db);
      case 'toggle_task':
        return _executeToggleTask(args, db);
      case 'list_tasks':
        return _executeListTasks(args, db);
      // Finance
      case 'log_expense':
        return _executeLogExpense(args, db);
      case 'delete_expense':
        return _executeDeleteExpense(args, db);
      case 'summarize_finances':
        return _executeSummarizeFinances(args, db);
      // Notes
      case 'search_notes':
        return _executeSearchNotes(args, db);
      case 'create_note':
        return _executeCreateNote(args, db);
      case 'edit_note':
        return _executeEditNote(args, db);
      case 'delete_note':
        return _executeDeleteNote(args, db);
      // Utility
      case 'get_weather':
        return _executeGetWeather(args);
      case 'read_notifications':
        return _executeReadNotifications(args);
      default:
        return json.encode({'error': 'Unknown tool: $toolName'});
    }
  }

  // ── Fuzzy match helper ──────────────────────────────

  /// Find the best fuzzy match from a list of items.
  /// Returns the matched item or null.
  static T? _fuzzyMatch<T>(
    String query,
    List<T> items,
    String Function(T) getText,
  ) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return null;

    // 1. Exact match
    for (final item in items) {
      if (getText(item).toLowerCase() == q) return item;
    }

    // 2. Starts-with match
    for (final item in items) {
      if (getText(item).toLowerCase().startsWith(q)) return item;
    }

    // 3. Contains match
    for (final item in items) {
      if (getText(item).toLowerCase().contains(q)) return item;
    }

    // 4. Any word match
    final words = q.split(RegExp(r'\s+'));
    for (final item in items) {
      final text = getText(item).toLowerCase();
      if (words.every((w) => text.contains(w))) return item;
    }

    return null;
  }

  // ── Task executors ──────────────────────────────────

  static Future<String> _executeAddTask(
      Map<String, dynamic> args, PrismDatabase? db) async {
    final title = args['title'] as String? ?? 'Untitled task';
    final priority = args['priority'] as String? ?? 'medium';
    final dueDateStr = args['due_date'] as String?;
    final dueDate = dueDateStr != null ? DateTime.tryParse(dueDateStr) : null;

    if (db != null) {
      await db.createTask(
        uuid: const Uuid().v4(),
        title: title,
        priority: priority,
        dueDate: dueDate,
      );
    }

    return json.encode({
      'success': true,
      'task': {
        'title': title,
        'priority': priority,
        'due_date': dueDateStr,
        'created': DateTime.now().toIso8601String(),
      },
    });
  }

  static Future<String> _executeEditTask(
      Map<String, dynamic> args, PrismDatabase? db) async {
    final searchTitle = args['title'] as String? ?? '';
    if (db == null) {
      return json.encode({'error': 'No database available'});
    }

    final tasks = await db.watchAllTasks().first;
    final match = _fuzzyMatch(searchTitle, tasks, (t) => t.title);

    if (match == null) {
      return json.encode({
        'error': 'No task found matching "$searchTitle"',
        'available_tasks':
            tasks.take(10).map((t) => t.title).toList(),
      });
    }

    final newTitle = args['new_title'] as String?;
    final priority = args['priority'] as String?;
    final dueDateStr = args['due_date'] as String?;
    final dueDate = dueDateStr != null ? DateTime.tryParse(dueDateStr) : null;

    await db.updateTask(
      match.uuid,
      title: newTitle,
      priority: priority,
      dueDate: dueDate,
    );

    return json.encode({
      'success': true,
      'updated_task': {
        'original_title': match.title,
        'new_title': newTitle ?? match.title,
        'priority': priority ?? match.priority,
        'due_date': dueDateStr,
      },
    });
  }

  static Future<String> _executeDeleteTask(
      Map<String, dynamic> args, PrismDatabase? db) async {
    final searchTitle = args['title'] as String? ?? '';
    if (db == null) {
      return json.encode({'error': 'No database available'});
    }

    final tasks = await db.watchAllTasks().first;
    final match = _fuzzyMatch(searchTitle, tasks, (t) => t.title);

    if (match == null) {
      return json.encode({
        'error': 'No task found matching "$searchTitle"',
        'available_tasks':
            tasks.take(10).map((t) => t.title).toList(),
      });
    }

    await db.deleteTask(match.uuid);

    return json.encode({
      'success': true,
      'deleted_task': match.title,
    });
  }

  static Future<String> _executeToggleTask(
      Map<String, dynamic> args, PrismDatabase? db) async {
    final searchTitle = args['title'] as String? ?? '';
    if (db == null) {
      return json.encode({'error': 'No database available'});
    }

    final tasks = await db.watchAllTasks().first;
    final match = _fuzzyMatch(searchTitle, tasks, (t) => t.title);

    if (match == null) {
      return json.encode({
        'error': 'No task found matching "$searchTitle"',
        'available_tasks':
            tasks.take(10).map((t) => t.title).toList(),
      });
    }

    await db.toggleTask(match.uuid);

    return json.encode({
      'success': true,
      'task': match.title,
      'new_status': match.isCompleted ? 'pending' : 'completed',
    });
  }

  static Future<String> _executeListTasks(
      Map<String, dynamic> args, PrismDatabase? db) async {
    if (db == null) {
      return json.encode({'error': 'No database available'});
    }

    final statusFilter = args['status'] as String? ?? 'all';
    final allTasks = await db.watchAllTasks().first;

    final filtered = switch (statusFilter) {
      'pending' => allTasks.where((t) => !t.isCompleted).toList(),
      'completed' => allTasks.where((t) => t.isCompleted).toList(),
      _ => allTasks,
    };

    return json.encode({
      'count': filtered.length,
      'tasks': filtered
          .take(20)
          .map((t) => {
                'title': t.title,
                'priority': t.priority,
                'is_completed': t.isCompleted,
                'due_date': t.dueDate?.toIso8601String(),
                'created': t.createdAt.toIso8601String(),
              })
          .toList(),
    });
  }

  // ── Finance executors ───────────────────────────────

  static Future<String> _executeLogExpense(
      Map<String, dynamic> args, PrismDatabase? db) async {
    final amount = (args['amount'] as num?)?.toDouble() ?? 0;
    final category = args['category'] as String? ?? 'other';
    final type = args['type'] as String? ?? 'expense';
    final description = args['description'] as String? ?? '';

    if (db != null) {
      await db.logTransaction(
        uuid: const Uuid().v4(),
        amount: amount,
        category: category,
        type: type,
        description: description,
      );
    }

    return json.encode({
      'success': true,
      'transaction': {
        'amount': amount,
        'category': category,
        'description': description,
        'type': type,
        'logged_at': DateTime.now().toIso8601String(),
      },
    });
  }

  static Future<String> _executeDeleteExpense(
      Map<String, dynamic> args, PrismDatabase? db) async {
    final searchDesc = args['description'] as String? ?? '';
    final searchAmount = (args['amount'] as num?)?.toDouble();

    if (db == null) {
      return json.encode({'error': 'No database available'});
    }

    final txns = await db.watchCurrentMonthTransactions().first;

    // Filter by amount first if provided, then fuzzy match description
    var candidates = txns;
    if (searchAmount != null) {
      candidates = candidates
          .where((t) => (t.amount - searchAmount).abs() < 0.01)
          .toList();
    }

    final match = _fuzzyMatch(
      searchDesc,
      candidates,
      (t) => '${t.description} ${t.category}',
    );

    if (match == null) {
      return json.encode({
        'error': 'No transaction found matching "$searchDesc"'
            '${searchAmount != null ? " with amount $searchAmount" : ""}',
        'recent_transactions': txns
            .take(10)
            .map((t) => '${t.type}: ${t.amount} — ${t.description.isEmpty ? t.category : t.description}')
            .toList(),
      });
    }

    await db.deleteTransaction(match.uuid);

    return json.encode({
      'success': true,
      'deleted': {
        'amount': match.amount,
        'category': match.category,
        'description': match.description,
        'type': match.type,
      },
    });
  }

  static Future<String> _executeSummarizeFinances(
      Map<String, dynamic> args, PrismDatabase? db) async {
    if (db == null) {
      return json.encode({'error': 'No database available'});
    }

    final txns = await db.watchCurrentMonthTransactions().first;

    double totalIncome = 0;
    double totalExpense = 0;
    final categoryBreakdown = <String, double>{};

    for (final t in txns) {
      if (t.type == 'income') {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
        categoryBreakdown[t.category] =
            (categoryBreakdown[t.category] ?? 0) + t.amount;
      }
    }

    // Sort categories by amount (descending)
    final sortedCategories = categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return json.encode({
      'month': '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}',
      'total_income': totalIncome,
      'total_expenses': totalExpense,
      'net': totalIncome - totalExpense,
      'transaction_count': txns.length,
      'top_categories': sortedCategories
          .take(8)
          .map((e) => {'category': e.key, 'amount': e.value})
          .toList(),
    });
  }

  // ── Note executors ──────────────────────────────────

  static Future<String> _executeSearchNotes(
      Map<String, dynamic> args, PrismDatabase? db) async {
    final query = args['query'] as String? ?? '';
    final limit = args['limit'] as int? ?? 5;

    if (db != null && query.isNotEmpty) {
      // Try FTS5 search first
      try {
        final ftsResults = await db.searchNotes(query).get();
        if (ftsResults.isNotEmpty) {
          return json.encode({
            'results': ftsResults
                .take(limit)
                .map((r) => {
                      'title': r.n.title,
                      'excerpt': r.n.content.length > 200
                          ? '${r.n.content.substring(0, 200)}...'
                          : r.n.content,
                      'tags': r.n.tags,
                      'updated': r.n.updatedAt.toIso8601String(),
                    })
                .toList(),
          });
        }
      } catch (_) {}

      // Fallback: in-memory search
      final notes = await db.watchNotes().first;
      final matched = notes.where((n) {
        final q = query.toLowerCase();
        return n.title.toLowerCase().contains(q) ||
            n.content.toLowerCase().contains(q) ||
            n.tags.toLowerCase().contains(q);
      }).take(limit).toList();

      return json.encode({
        'results': matched
            .map((n) => {
                  'title': n.title,
                  'excerpt': n.content.length > 200
                      ? '${n.content.substring(0, 200)}...'
                      : n.content,
                  'tags': n.tags,
                  'updated': n.updatedAt.toIso8601String(),
                })
            .toList(),
      });
    }

    return json.encode({'results': [], 'message': 'No results found'});
  }

  static Future<String> _executeCreateNote(
      Map<String, dynamic> args, PrismDatabase? db) async {
    final title = args['title'] as String? ?? 'Untitled';
    final content = args['content'] as String? ?? '';
    final tags = args['tags'] as String? ?? '';

    if (db != null) {
      await db.createNote(
        uuid: const Uuid().v4(),
        title: title,
        content: content,
        tags: tags,
      );
    }

    return json.encode({
      'success': true,
      'note': {
        'title': title,
        'content_length': content.length,
        'tags': tags,
        'created': DateTime.now().toIso8601String(),
      },
    });
  }

  static Future<String> _executeEditNote(
      Map<String, dynamic> args, PrismDatabase? db) async {
    final searchTitle = args['title'] as String? ?? '';
    if (db == null) {
      return json.encode({'error': 'No database available'});
    }

    final notes = await db.watchNotes().first;
    final match = _fuzzyMatch(searchTitle, notes, (n) => n.title);

    if (match == null) {
      return json.encode({
        'error': 'No note found matching "$searchTitle"',
        'available_notes':
            notes.take(10).map((n) => n.title).toList(),
      });
    }

    final newTitle = args['new_title'] as String?;
    final content = args['content'] as String?;
    final tags = args['tags'] as String?;

    await db.updateNote(
      match.uuid,
      title: newTitle,
      content: content,
      tags: tags,
    );

    return json.encode({
      'success': true,
      'updated_note': {
        'original_title': match.title,
        'new_title': newTitle ?? match.title,
        'content_updated': content != null,
        'tags': tags ?? match.tags,
      },
    });
  }

  static Future<String> _executeDeleteNote(
      Map<String, dynamic> args, PrismDatabase? db) async {
    final searchTitle = args['title'] as String? ?? '';
    if (db == null) {
      return json.encode({'error': 'No database available'});
    }

    final notes = await db.watchNotes().first;
    final match = _fuzzyMatch(searchTitle, notes, (n) => n.title);

    if (match == null) {
      return json.encode({
        'error': 'No note found matching "$searchTitle"',
        'available_notes':
            notes.take(10).map((n) => n.title).toList(),
      });
    }

    await db.deleteNote(match.uuid);

    return json.encode({
      'success': true,
      'deleted_note': match.title,
    });
  }

  // ── Utility executors ───────────────────────────────

  static Future<String> _executeGetWeather(Map<String, dynamic> args) async {
    // Mock weather — replace with real API when available
    return json.encode({
      'location': args['location'],
      'temperature': 24,
      'unit': 'celsius',
      'condition': 'Sunny',
      'humidity': 45,
    });
  }

  static Future<String> _executeReadNotifications(
      Map<String, dynamic> args) async {
    final limit = args['limit'] as int? ?? 20;
    final filterApp = args['filter_app'] as String?;

    if (!Platform.isAndroid) {
      return json.encode({
        'error': 'Notification reading is only available on Android.',
        'platform': Platform.operatingSystem,
      });
    }

    final hasPermission =
        await NotificationListenerService.isPermissionGranted();
    if (!hasPermission) {
      return json.encode({
        'permission': 'denied',
        'message':
            'Notification access not granted. Enable in Settings > Apps > Special access > Notification access.',
        'notifications': [],
      });
    }

    var notifications = _notificationHistory;
    if (filterApp != null && filterApp.isNotEmpty) {
      notifications = notifications
          .where((n) =>
              (n['packageName'] as String?)
                  ?.toLowerCase()
                  .contains(filterApp.toLowerCase()) ??
              false)
          .toList();
    }
    notifications = notifications.take(limit).toList();

    return json.encode({
      'permission': 'granted',
      'count': notifications.length,
      'total_stored': _notificationHistory.length,
      'notifications': notifications,
    });
  }
}
