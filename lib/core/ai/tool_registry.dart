/// Tool definitions for function calling with LangChain.dart.
///
/// Each tool has a [ToolSpec] for the LLM and an executor that writes
/// to the Drift database. Additional tools can be loaded from skills.json.
library;

import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/services.dart' show rootBundle;
import 'package:langchain/langchain.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../ml/ml_kit_service.dart';

/// Registry of all available tools the AI can invoke.
class PrismToolRegistry {
  PrismToolRegistry._();

  /// All tool specifications for binding to the LLM.
  static List<ToolSpec> get specs => [
        addTaskTool,
        editTaskTool,
        deleteTaskTool,
        toggleTaskTool,
        listTasksTool,
        logExpenseTool,
        deleteExpenseTool,
        summarizeFinancesTool,
        searchNotesTool,
        createNoteTool,
        editNoteTool,
        deleteNoteTool,
        getWeatherTool,
        readNotificationsTool,
      ];

  /// Convert all tool specs to OpenAI function-calling format.
  /// Returns a list of `{"type": "function", "function": {...}}` objects
  /// suitable for the `tools` parameter in chat completions requests.
  static List<Map<String, dynamic>> toOpenAITools() {
    return specs.map((t) => toolSpecToOpenAI(t)).toList();
  }

  /// Convert a single [ToolSpec] to OpenAI function-calling format.
  static Map<String, dynamic> toolSpecToOpenAI(ToolSpec tool) {
    return {
      'type': 'function',
      'function': {
        'name': tool.name,
        'description': tool.description,
        'parameters': tool.inputJsonSchema,
      },
    };
  }

  /// Parse tool calls from an OpenAI-format response `tool_calls` array.
  /// Returns a list of `{id, name, arguments}` maps.
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

  // ══════════════════════════════════════════════════
  // TASK TOOLS
  // ══════════════════════════════════════════════════

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
        'description': {
          'type': 'string',
          'description': 'Optional description with more details',
        },
        'priority': {
          'type': 'string',
          'enum': ['low', 'medium', 'high'],
          'description': 'Priority level (default: medium)',
        },
        'due_date': {
          'type': 'string',
          'description': 'Due date in ISO 8601 format, e.g. 2026-02-15 (optional)',
        },
      },
      'required': ['title'],
    },
  );

  static const editTaskTool = ToolSpec(
    name: 'edit_task',
    description:
        'Edit an existing task. First use list_tasks to find the task, then provide the task title to identify it and the fields to update.',
    inputJsonSchema: {
      'type': 'object',
      'properties': {
        'search_title': {
          'type': 'string',
          'description':
              'The current title (or partial match) of the task to edit',
        },
        'new_title': {
          'type': 'string',
          'description': 'New title for the task (optional)',
        },
        'description': {
          'type': 'string',
          'description': 'New description (optional)',
        },
        'priority': {
          'type': 'string',
          'enum': ['low', 'medium', 'high'],
          'description': 'New priority level (optional)',
        },
        'due_date': {
          'type': 'string',
          'description':
              'New due date in ISO 8601 format, or "clear" to remove (optional)',
        },
      },
      'required': ['search_title'],
    },
  );

  static const deleteTaskTool = ToolSpec(
    name: 'delete_task',
    description:
        'Delete a task by its title. Use list_tasks first to find the exact task.',
    inputJsonSchema: {
      'type': 'object',
      'properties': {
        'search_title': {
          'type': 'string',
          'description': 'The title (or partial match) of the task to delete',
        },
      },
      'required': ['search_title'],
    },
  );

  static const toggleTaskTool = ToolSpec(
    name: 'toggle_task',
    description:
        'Mark a task as completed or uncompleted. Use list_tasks first to find the task.',
    inputJsonSchema: {
      'type': 'object',
      'properties': {
        'search_title': {
          'type': 'string',
          'description':
              'The title (or partial match) of the task to toggle completion',
        },
      },
      'required': ['search_title'],
    },
  );

  static const listTasksTool = ToolSpec(
    name: 'list_tasks',
    description:
        'List current tasks, optionally filtered by status or priority.',
    inputJsonSchema: {
      'type': 'object',
      'properties': {
        'status': {
          'type': 'string',
          'enum': ['pending', 'completed', 'all'],
          'description': 'Filter by status (default: all)',
        },
        'priority': {
          'type': 'string',
          'enum': ['low', 'medium', 'high'],
          'description': 'Filter by priority (optional)',
        },
      },
      'required': [],
    },
  );

  // ══════════════════════════════════════════════════
  // FINANCE TOOLS
  // ══════════════════════════════════════════════════

  static const logExpenseTool = ToolSpec(
    name: 'log_expense',
    description:
        'Log a financial transaction (expense or income) for the user.',
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
              'Category, e.g. groceries, transport, dining, salary, freelance, bills, entertainment, shopping, other',
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
        'Delete a financial transaction by matching its description or amount. Use summarize_finances first to find the transaction.',
    inputJsonSchema: {
      'type': 'object',
      'properties': {
        'search_description': {
          'type': 'string',
          'description':
              'Description text to match the transaction to delete',
        },
        'amount': {
          'type': 'number',
          'description':
              'Amount to match (optional, helps disambiguate)',
        },
      },
      'required': ['search_description'],
    },
  );

  static const summarizeFinancesTool = ToolSpec(
    name: 'summarize_finances',
    description:
        'Get a summary of the user\'s financial transactions for the current month, including totals and by-category breakdown.',
    inputJsonSchema: {
      'type': 'object',
      'properties': {},
      'required': [],
    },
  );

  // ══════════════════════════════════════════════════
  // NOTES / KNOWLEDGE BASE TOOLS
  // ══════════════════════════════════════════════════

  static const searchNotesTool = ToolSpec(
    name: 'search_notes',
    description:
        'Search the user\'s knowledge base / brain for relevant notes and documents.',
    inputJsonSchema: {
      'type': 'object',
      'properties': {
        'query': {
          'type': 'string',
          'description': 'The search query',
        },
      },
      'required': ['query'],
    },
  );

  static const createNoteTool = ToolSpec(
    name: 'create_note',
    description:
        'Create a note in the user\'s knowledge base / Second Brain.',
    inputJsonSchema: {
      'type': 'object',
      'properties': {
        'title': {
          'type': 'string',
          'description': 'The title of the note',
        },
        'content': {
          'type': 'string',
          'description': 'The note body / content (supports markdown)',
        },
        'tags': {
          'type': 'string',
          'description': 'Comma-separated tags, e.g. "project,work,ideas"',
        },
      },
      'required': ['title', 'content'],
    },
  );

  static const editNoteTool = ToolSpec(
    name: 'edit_note',
    description:
        'Edit an existing note. Use search_notes first to find the note, then provide the title to identify it.',
    inputJsonSchema: {
      'type': 'object',
      'properties': {
        'search_title': {
          'type': 'string',
          'description': 'Current title (or partial match) of the note to edit',
        },
        'new_title': {
          'type': 'string',
          'description': 'New title (optional)',
        },
        'content': {
          'type': 'string',
          'description': 'New content to replace existing content (optional)',
        },
        'tags': {
          'type': 'string',
          'description': 'New comma-separated tags (optional)',
        },
      },
      'required': ['search_title'],
    },
  );

  static const deleteNoteTool = ToolSpec(
    name: 'delete_note',
    description:
        'Delete a note by its title. Use search_notes first to find the note.',
    inputJsonSchema: {
      'type': 'object',
      'properties': {
        'search_title': {
          'type': 'string',
          'description': 'The title (or partial match) of the note to delete',
        },
      },
      'required': ['search_title'],
    },
  );

  // ══════════════════════════════════════════════════
  // UTILITY TOOLS
  // ══════════════════════════════════════════════════

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
          'description': 'Max number of notifications to return (default 20)',
        },
        'filter_app': {
          'type': 'string',
          'description':
              'Filter by app package name (e.g. "com.google.android.apps.banking")',
        },
      },
      'required': [],
    },
  );

  // ══════════════════════════════════════════════════
  // NOTIFICATION LISTENER
  // ══════════════════════════════════════════════════

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

  // ══════════════════════════════════════════════════
  // EXECUTE — dispatch tool calls to real logic
  // ══════════════════════════════════════════════════

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

  // ══════════════════════════════════════════════════
  // TASK EXECUTORS
  // ══════════════════════════════════════════════════

  static Future<String> _executeAddTask(
      Map<String, dynamic> args, PrismDatabase? db) async {
    final title = args['title'] as String? ?? 'Untitled task';
    final description = args['description'] as String? ?? '';
    final priority = args['priority'] as String? ?? 'medium';
    final dueDateStr = args['due_date'] as String?;
    final dueDate = dueDateStr != null ? DateTime.tryParse(dueDateStr) : null;

    if (db != null) {
      await db.createTask(
        uuid: const Uuid().v4(),
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
      );
    }

    return json.encode({
      'success': true,
      'task': {
        'title': title,
        'description': description,
        'priority': priority,
        'due_date': dueDateStr,
        'created': DateTime.now().toIso8601String(),
      },
    });
  }

  static Future<String> _executeEditTask(
      Map<String, dynamic> args, PrismDatabase? db) async {
    final searchTitle = args['search_title'] as String? ?? '';
    if (db == null || searchTitle.isEmpty) {
      return json.encode({'error': 'No database or search_title provided'});
    }

    final tasks = await db.watchAllTasks().first;
    final query = searchTitle.toLowerCase();
    final match = tasks.where((t) => t.title.toLowerCase().contains(query)).toList();

    if (match.isEmpty) {
      return json.encode({
        'error': 'No task found matching "$searchTitle"',
        'available_tasks': tasks.take(10).map((t) => t.title).toList(),
      });
    }

    final task = match.first;
    final newTitle = args['new_title'] as String?;
    final description = args['description'] as String?;
    final priority = args['priority'] as String?;
    final dueDateStr = args['due_date'] as String?;

    DateTime? dueDate;
    bool clearDueDate = false;
    if (dueDateStr == 'clear') {
      clearDueDate = true;
    } else if (dueDateStr != null) {
      dueDate = DateTime.tryParse(dueDateStr);
    }

    await db.updateTask(
      task.uuid,
      title: newTitle,
      description: description,
      priority: priority,
      dueDate: dueDate,
      clearDueDate: clearDueDate,
    );

    return json.encode({
      'success': true,
      'updated_task': {
        'old_title': task.title,
        'title': newTitle ?? task.title,
        'description': description ?? task.description,
        'priority': priority ?? task.priority,
        'due_date': dueDateStr,
      },
    });
  }

  static Future<String> _executeDeleteTask(
      Map<String, dynamic> args, PrismDatabase? db) async {
    final searchTitle = args['search_title'] as String? ?? '';
    if (db == null || searchTitle.isEmpty) {
      return json.encode({'error': 'No database or search_title provided'});
    }

    final tasks = await db.watchAllTasks().first;
    final query = searchTitle.toLowerCase();
    final match = tasks.where((t) => t.title.toLowerCase().contains(query)).toList();

    if (match.isEmpty) {
      return json.encode({
        'error': 'No task found matching "$searchTitle"',
        'available_tasks': tasks.take(10).map((t) => t.title).toList(),
      });
    }

    final task = match.first;
    await db.deleteTask(task.uuid);

    return json.encode({
      'success': true,
      'deleted_task': {'title': task.title, 'priority': task.priority},
    });
  }

  static Future<String> _executeToggleTask(
      Map<String, dynamic> args, PrismDatabase? db) async {
    final searchTitle = args['search_title'] as String? ?? '';
    if (db == null || searchTitle.isEmpty) {
      return json.encode({'error': 'No database or search_title provided'});
    }

    final tasks = await db.watchAllTasks().first;
    final query = searchTitle.toLowerCase();
    final match = tasks.where((t) => t.title.toLowerCase().contains(query)).toList();

    if (match.isEmpty) {
      return json.encode({
        'error': 'No task found matching "$searchTitle"',
        'available_tasks': tasks.take(10).map((t) => t.title).toList(),
      });
    }

    final task = match.first;
    await db.toggleTask(task.uuid);

    return json.encode({
      'success': true,
      'task': {
        'title': task.title,
        'was_completed': task.isCompleted,
        'is_now_completed': !task.isCompleted,
      },
    });
  }

  static Future<String> _executeListTasks(
      Map<String, dynamic> args, PrismDatabase? db) async {
    if (db == null) {
      return json.encode({'error': 'No database available'});
    }

    final status = args['status'] as String? ?? 'all';
    final priorityFilter = args['priority'] as String?;

    List<TaskEntry> tasks;
    if (status == 'pending') {
      tasks = await db.watchPendingTasks().first;
    } else {
      tasks = await db.watchAllTasks().first;
    }

    if (status == 'completed') {
      tasks = tasks.where((t) => t.isCompleted).toList();
    }

    if (priorityFilter != null) {
      tasks = tasks.where((t) => t.priority == priorityFilter).toList();
    }

    return json.encode({
      'count': tasks.length,
      'filter': {'status': status, 'priority': priorityFilter},
      'tasks': tasks.take(20).map((t) => {
            'title': t.title,
            'description': t.description,
            'priority': t.priority,
            'is_completed': t.isCompleted,
            'due_date': t.dueDate?.toIso8601String(),
            'created': t.createdAt.toIso8601String(),
          }).toList(),
    });
  }

  // ══════════════════════════════════════════════════
  // FINANCE EXECUTORS
  // ══════════════════════════════════════════════════

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
        source: 'ai',
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
    final searchDesc = args['search_description'] as String? ?? '';
    final searchAmount = (args['amount'] as num?)?.toDouble();
    if (db == null || searchDesc.isEmpty) {
      return json.encode({'error': 'No database or search_description provided'});
    }

    final transactions = await db.watchCurrentMonthTransactions().first;
    final query = searchDesc.toLowerCase();
    var matches = transactions
        .where((t) => t.description.toLowerCase().contains(query))
        .toList();

    if (searchAmount != null && matches.length > 1) {
      matches = matches.where((t) => t.amount == searchAmount).toList();
    }

    if (matches.isEmpty) {
      return json.encode({
        'error': 'No transaction found matching "$searchDesc"',
        'recent_transactions': transactions.take(5).map((t) => {
              'description': t.description,
              'amount': t.amount,
              'category': t.category,
            }).toList(),
      });
    }

    final txn = matches.first;
    await db.deleteTransaction(txn.uuid);

    return json.encode({
      'success': true,
      'deleted_transaction': {
        'description': txn.description,
        'amount': txn.amount,
        'category': txn.category,
        'type': txn.type,
      },
    });
  }

  static Future<String> _executeSummarizeFinances(
      Map<String, dynamic> args, PrismDatabase? db) async {
    if (db == null) {
      return json.encode({'error': 'No database available'});
    }

    final transactions = await db.watchCurrentMonthTransactions().first;

    double totalExpenses = 0;
    double totalIncome = 0;
    final byCategory = <String, double>{};

    for (final t in transactions) {
      if (t.type == 'income') {
        totalIncome += t.amount;
      } else {
        totalExpenses += t.amount;
        byCategory[t.category] = (byCategory[t.category] ?? 0) + t.amount;
      }
    }

    // Sort categories by amount descending
    final sortedCategories = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return json.encode({
      'period': 'current_month',
      'total_transactions': transactions.length,
      'total_expenses': totalExpenses,
      'total_income': totalIncome,
      'net': totalIncome - totalExpenses,
      'expenses_by_category': {
        for (final e in sortedCategories) e.key: e.value,
      },
      'recent_transactions': transactions.take(10).map((t) => {
            'description': t.description,
            'amount': t.amount,
            'category': t.category,
            'type': t.type,
            'date': t.date.toIso8601String(),
          }).toList(),
    });
  }

  // ══════════════════════════════════════════════════
  // NOTES EXECUTORS
  // ══════════════════════════════════════════════════

  static Future<String> _executeSearchNotes(
      Map<String, dynamic> args, PrismDatabase? db) async {
    final query = args['query'] as String? ?? '';

    if (db != null && query.isNotEmpty) {
      // Try FTS5 search first
      try {
        final ftsResults = await db.searchNotes(query).get();
        if (ftsResults.isNotEmpty) {
          return json.encode({
            'results': ftsResults
                .take(5)
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

      // Fallback: manual in-memory search
      final notes = await db.watchNotes().first;
      final matched = notes.where((n) {
        final q = query.toLowerCase();
        return n.title.toLowerCase().contains(q) ||
            n.content.toLowerCase().contains(q) ||
            n.tags.toLowerCase().contains(q);
      }).take(5).toList();

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

    return json.encode({'results': [], 'message': 'No matching notes found'});
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
        source: 'ai',
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
    final searchTitle = args['search_title'] as String? ?? '';
    if (db == null || searchTitle.isEmpty) {
      return json.encode({'error': 'No database or search_title provided'});
    }

    final notes = await db.watchNotes().first;
    final query = searchTitle.toLowerCase();
    final match = notes.where((n) => n.title.toLowerCase().contains(query)).toList();

    if (match.isEmpty) {
      return json.encode({
        'error': 'No note found matching "$searchTitle"',
        'available_notes': notes.take(10).map((n) => n.title).toList(),
      });
    }

    final note = match.first;
    final newTitle = args['new_title'] as String?;
    final content = args['content'] as String?;
    final tags = args['tags'] as String?;

    await db.updateNote(
      note.uuid,
      title: newTitle,
      content: content,
      tags: tags,
    );

    return json.encode({
      'success': true,
      'updated_note': {
        'old_title': note.title,
        'title': newTitle ?? note.title,
        'content_length': (content ?? note.content).length,
        'tags': tags ?? note.tags,
      },
    });
  }

  static Future<String> _executeDeleteNote(
      Map<String, dynamic> args, PrismDatabase? db) async {
    final searchTitle = args['search_title'] as String? ?? '';
    if (db == null || searchTitle.isEmpty) {
      return json.encode({'error': 'No database or search_title provided'});
    }

    final notes = await db.watchNotes().first;
    final query = searchTitle.toLowerCase();
    final match = notes.where((n) => n.title.toLowerCase().contains(query)).toList();

    if (match.isEmpty) {
      return json.encode({
        'error': 'No note found matching "$searchTitle"',
        'available_notes': notes.take(10).map((n) => n.title).toList(),
      });
    }

    final note = match.first;
    await db.deleteNote(note.uuid);

    return json.encode({
      'success': true,
      'deleted_note': {'title': note.title},
    });
  }

  // ══════════════════════════════════════════════════
  // UTILITY EXECUTORS
  // ══════════════════════════════════════════════════

  static Future<String> _executeGetWeather(Map<String, dynamic> args) async {
    // Mock weather response
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
            'Notification access not granted. Please enable in Settings > Apps > Special access > Notification access.',
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
