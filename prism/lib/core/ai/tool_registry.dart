/// Tool definitions for function calling with LangChain.dart.
///
/// Each tool has a [ToolSpec] for the LLM and an executor function.
library;

import 'dart:convert';
import 'package:langchain/langchain.dart';

/// Registry of all available tools the AI can invoke.
class PrismToolRegistry {
  PrismToolRegistry._();

  /// All tool specifications for binding to the LLM.
  static List<ToolSpec> get specs => [
        addTaskTool,
        logExpenseTool,
        searchNotesTool,
        getWeatherTool,
      ];

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

  /// Execute a tool call and return the result as a string.
  static Future<String> execute(String toolName, Map<String, dynamic> args) async {
    switch (toolName) {
      case 'add_task':
        return _executeAddTask(args);
      case 'log_expense':
        return _executeLogExpense(args);
      case 'search_notes':
        return _executeSearchNotes(args);
      case 'get_weather':
        return _executeGetWeather(args);
      default:
        return json.encode({'error': 'Unknown tool: $toolName'});
    }
  }

  static Future<String> _executeAddTask(Map<String, dynamic> args) async {
    // TODO: integrate with Drift database when ready
    return json.encode({
      'success': true,
      'task': {
        'title': args['title'],
        'priority': args['priority'] ?? 'medium',
        'due_date': args['due_date'],
        'created': DateTime.now().toIso8601String(),
      },
    });
  }

  static Future<String> _executeLogExpense(Map<String, dynamic> args) async {
    // TODO: integrate with Drift database
    return json.encode({
      'success': true,
      'transaction': {
        'amount': args['amount'],
        'category': args['category'],
        'description': args['description'] ?? '',
        'type': args['type'],
        'logged_at': DateTime.now().toIso8601String(),
      },
    });
  }

  static Future<String> _executeSearchNotes(Map<String, dynamic> args) async {
    // TODO: integrate with Drift FTS5 search
    return json.encode({
      'results': [
        {
          'title': 'Sample note about ${args['query']}',
          'excerpt': 'This is a mock search result. Real search will use FTS5.',
          'relevance': 0.95,
        },
      ],
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
}
