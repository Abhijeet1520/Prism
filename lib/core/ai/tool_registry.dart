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

/// Registry of all available tools the AI can invoke.
class PrismToolRegistry {
  PrismToolRegistry._();

  static List<ToolSpec>? _cachedJsonSpecs;

  /// All tool specifications for binding to the LLM.
  /// Includes both hardcoded tools and any loaded from skills.json.
  static List<ToolSpec> get specs => [
        addTaskTool,
        logExpenseTool,
        searchNotesTool,
        createNoteTool,
        getWeatherTool,
        readNotificationsTool,
        ...?_cachedJsonSpecs,
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

  /// Load additional tool specs from assets/config/skills.json.
  /// Call this once during app initialization.
  static Future<void> loadSkillsFromJson() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/config/skills.json');
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final tools = data['tools'] as List<dynamic>? ?? [];
      final builtinNames = {'add_task', 'log_expense', 'search_notes', 'create_note', 'get_weather', 'read_notifications'};

      _cachedJsonSpecs = tools
          .map((t) {
            final map = t as Map<String, dynamic>;
            final name = map['name'] as String;
            // Skip tools that are already hardcoded
            if (builtinNames.contains(name)) return null;
            return ToolSpec(
              name: name,
              description: map['description'] as String? ?? '',
              inputJsonSchema: map['input_schema'] as Map<String, dynamic>? ?? {},
            );
          })
          .where((s) => s != null)
          .cast<ToolSpec>()
          .toList();
    } catch (_) {
      _cachedJsonSpecs = [];
    }
  }

  // ── Task management tool ────────────────────────

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
          'description': 'Priority level',
        },
        'due_date': {
          'type': 'string',
          'description': 'Due date in ISO 8601 format (optional)',
        },
      },
      'required': ['title'],
    },
  );

  // ── Finance tool ─────────────────────────────────

  static const logExpenseTool = ToolSpec(
    name: 'log_expense',
    description: 'Log a financial transaction (expense or income).',
    inputJsonSchema: {
      'type': 'object',
      'properties': {
        'amount': {
          'type': 'number',
          'description': 'The transaction amount',
        },
        'category': {
          'type': 'string',
          'description': 'Expense category (e.g., groceries, transport, dining)',
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

  // ── Knowledge base search tool ───────────────────

  static const searchNotesTool = ToolSpec(
    name: 'search_notes',
    description: 'Search the user\'s knowledge base / brain for relevant notes and documents.',
    inputJsonSchema: {
      'type': 'object',
      'properties': {
        'query': {
          'type': 'string',
          'description': 'The search query',
        },
        'limit': {
          'type': 'integer',
          'description': 'Max number of results to return (default 5)',
        },
      },
      'required': ['query'],
    },
  );

  // ── Weather tool ─────────────────────────────────

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

  // ── Create note tool ─────────────────────────────

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

  // ── Notification reading tool ────────────────────

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
          'description': 'Filter by app package name (e.g., "com.google.android.apps.banking")',
        },
      },
      'required': [],
    },
  );

  // ── Notification history cache ───────────────────

  /// In-memory store for intercepted notifications.
  static final List<Map<String, dynamic>> _notificationHistory = [];

  /// Called by the notification listener service when a notification is posted.
  static void onNotificationPosted(ServiceNotificationEvent event) {
    _notificationHistory.insert(0, {
      'id': event.id,
      'packageName': event.packageName,
      'title': event.title ?? '',
      'content': event.content ?? '',
      'timestamp': DateTime.now().toIso8601String(),
    });
    // Keep only last 100 notifications
    if (_notificationHistory.length > 100) {
      _notificationHistory.removeRange(100, _notificationHistory.length);
    }
  }

  /// Initialize the notification listener service (call from main.dart).
  static Future<void> initNotificationListener() async {
    if (!Platform.isAndroid) return;

    final hasPermission =
        await NotificationListenerService.isPermissionGranted();
    if (!hasPermission) return;

    NotificationListenerService.notificationsStream.listen((event) {
      onNotificationPosted(event);
    });
  }

  /// Execute a tool call and return the result as a string.
  /// Pass a [PrismDatabase] to enable real persistence.
  static Future<String> execute(
    String toolName,
    Map<String, dynamic> args, {
    PrismDatabase? db,
  }) async {
    switch (toolName) {
      case 'add_task':
        return _executeAddTask(args, db);
      case 'log_expense':
        return _executeLogExpense(args, db);
      case 'search_notes':
        return _executeSearchNotes(args, db);
      case 'create_note':
        return _executeCreateNote(args, db);
      case 'get_weather':
        return _executeGetWeather(args);
      case 'read_notifications':
        return _executeReadNotifications(args);
      default:
        return json.encode({'error': 'Unknown tool: $toolName'});
    }
  }

  static Future<String> _executeAddTask(
      Map<String, dynamic> args, PrismDatabase? db) async {
    final title = args['title'] as String? ?? 'Untitled task';
    final priority = args['priority'] as String? ?? 'medium';
    final dueDateStr = args['due_date'] as String?;
    final dueDate =
        dueDateStr != null ? DateTime.tryParse(dueDateStr) : null;

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

  static Future<String> _executeSearchNotes(
      Map<String, dynamic> args, PrismDatabase? db) async {
    final query = args['query'] as String? ?? '';

    if (db != null && query.isNotEmpty) {
      // Try FTS5 search first for better results
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
      } catch (_) {
        // FTS5 table might not be ready; fall through to manual search
      }

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

    return json.encode({
      'results': [
        {
          'title': 'Sample note about $query',
          'excerpt': 'No database available for real search.',
          'relevance': 0.95,
        },
      ],
    });
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

    // Android only
    if (!Platform.isAndroid) {
      return json.encode({
        'error': 'Notification reading is only available on Android.',
        'platform': Platform.operatingSystem,
      });
    }

    // Check permission
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

    // Filter and return cached notifications
    var notifications = _notificationHistory;
    if (filterApp != null && filterApp.isNotEmpty) {
      notifications = notifications
          .where((n) => (n['packageName'] as String?)
              ?.toLowerCase()
              .contains(filterApp.toLowerCase()) ?? false)
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
