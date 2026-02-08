import 'dart:convert';
import 'package:flutter/services.dart';

/// Result of a tool execution.
class ToolResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  const ToolResult({required this.success, required this.message, this.data});

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (data != null) 'data': data,
  };
}

/// Base class for composable AI tools.
abstract class AITool {
  String get id;
  String get name;
  String get description;
  Map<String, String> get parameters; // name -> description
  List<String> get requiredParams;

  /// Execute the tool with given arguments.
  Future<ToolResult> execute(Map<String, dynamic> args);

  Map<String, dynamic> toSchema() => {
    'id': id,
    'name': name,
    'description': description,
    'parameters': parameters,
    'required': requiredParams,
  };
}

/// Tool: Update a task's status.
class UpdateTaskTool extends AITool {
  @override String get id => 'update_task';
  @override String get name => 'Update Task';
  @override String get description => 'Mark a task as done, in-progress, or update its details';
  @override Map<String, String> get parameters => {
    'task_id': 'The ID of the task to update',
    'status': 'New status: todo, in_progress, done',
    'title': 'Optional new title for the task',
  };
  @override List<String> get requiredParams => ['task_id', 'status'];

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    final taskId = args['task_id'] as String;
    final status = args['status'] as String;
    // In real version: update local DB
    return ToolResult(
      success: true,
      message: 'Task $taskId updated to "$status"',
      data: {'task_id': taskId, 'status': status},
    );
  }
}

/// Tool: Add a financial transaction.
class AddTransactionTool extends AITool {
  @override String get id => 'add_transaction';
  @override String get name => 'Add Transaction';
  @override String get description => 'Log a new financial transaction (expense or income)';
  @override Map<String, String> get parameters => {
    'amount': 'Transaction amount (positive = income, negative = expense)',
    'category': 'Category: food, transport, utilities, entertainment, income, other',
    'description': 'Brief description of the transaction',
    'date': 'Optional date in YYYY-MM-DD format (defaults to today)',
  };
  @override List<String> get requiredParams => ['amount', 'category', 'description'];

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    final amount = args['amount'];
    final category = args['category'] as String;
    final desc = args['description'] as String;
    return ToolResult(
      success: true,
      message: 'Transaction added: $desc (\$$amount in $category)',
      data: {'amount': amount, 'category': category, 'description': desc},
    );
  }
}

/// Tool: Create a new brain document or note.
class CreateNoteTool extends AITool {
  @override String get id => 'create_note';
  @override String get name => 'Create Note';
  @override String get description => 'Create a new note or document in the Brain';
  @override Map<String, String> get parameters => {
    'title': 'Title of the note',
    'content': 'Content/body of the note',
    'category': 'Optional category: note, document, snippet',
    'tags': 'Optional comma-separated tags',
  };
  @override List<String> get requiredParams => ['title', 'content'];

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    final title = args['title'] as String;
    return ToolResult(
      success: true,
      message: 'Note "$title" created in Brain',
      data: {'title': title, 'id': 'note_${DateTime.now().millisecondsSinceEpoch}'},
    );
  }
}

/// Tool: Schedule an event.
class ScheduleEventTool extends AITool {
  @override String get id => 'schedule_event';
  @override String get name => 'Schedule Event';
  @override String get description => 'Add a new event to the calendar';
  @override Map<String, String> get parameters => {
    'title': 'Event title',
    'date': 'Date in YYYY-MM-DD format',
    'time': 'Time in HH:MM format',
    'duration_minutes': 'Duration in minutes',
    'location': 'Optional location',
  };
  @override List<String> get requiredParams => ['title', 'date', 'time'];

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    final title = args['title'] as String;
    final date = args['date'] as String;
    final time = args['time'] as String;
    return ToolResult(
      success: true,
      message: 'Event "$title" scheduled for $date at $time',
      data: {'title': title, 'date': date, 'time': time},
    );
  }
}

/// Tool: Edit a file/document.
class EditDocumentTool extends AITool {
  @override String get id => 'edit_document';
  @override String get name => 'Edit Document';
  @override String get description => 'Edit content in an existing Brain document';
  @override Map<String, String> get parameters => {
    'document_id': 'The ID of the document to edit',
    'action': 'Action: append, replace, delete_section',
    'content': 'The new content to add or replace with',
    'section': 'Optional section identifier for targeted edits',
  };
  @override List<String> get requiredParams => ['document_id', 'action', 'content'];

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    final docId = args['document_id'] as String;
    final action = args['action'] as String;
    return ToolResult(
      success: true,
      message: 'Document $docId updated (action: $action)',
      data: {'document_id': docId, 'action': action},
    );
  }
}

/// Tool: Get weather information.
class WeatherTool extends AITool {
  @override String get id => 'get_weather';
  @override String get name => 'Get Weather';
  @override String get description => 'Fetch current weather and forecast';
  @override Map<String, String> get parameters => {
    'location': 'Optional location (defaults to user\'s location)',
  };
  @override List<String> get requiredParams => [];

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    return ToolResult(
      success: true,
      message: 'Weather: 24°C, Sunny, Humidity 45%',
      data: {'temp': 24, 'condition': 'sunny', 'humidity': 45, 'forecast': 'Clear skies'},
    );
  }
}

/// Registry and executor for all tools.
class ToolRegistry {
  static final ToolRegistry _instance = ToolRegistry._();
  factory ToolRegistry() => _instance;
  ToolRegistry._() {
    // Register all built-in tools
    register(UpdateTaskTool());
    register(AddTransactionTool());
    register(CreateNoteTool());
    register(ScheduleEventTool());
    register(EditDocumentTool());
    register(WeatherTool());
  }

  final Map<String, AITool> _tools = {};

  List<AITool> get tools => _tools.values.toList();

  void register(AITool tool) => _tools[tool.id] = tool;

  AITool? getTool(String id) => _tools[id];

  /// Execute a tool by ID with given arguments.
  Future<ToolResult> execute(String toolId, Map<String, dynamic> args) async {
    final tool = _tools[toolId];
    if (tool == null) {
      return ToolResult(success: false, message: 'Unknown tool: $toolId');
    }

    // Validate required params
    for (final param in tool.requiredParams) {
      if (!args.containsKey(param) || args[param] == null) {
        return ToolResult(success: false, message: 'Missing required parameter: $param');
      }
    }

    return tool.execute(args);
  }

  /// Get schemas for all tools (used for AI function calling).
  List<Map<String, dynamic>> getSchemas() => tools.map((t) => t.toSchema()).toList();

  /// Parse a natural language request and try to match to a tool.
  /// In the real version, this would use the AI model's function calling.
  Future<ToolResult?> parseAndExecute(String naturalLanguage) async {
    final lower = naturalLanguage.toLowerCase();

    if (lower.contains('done') && (lower.contains('task') || lower.contains('todo'))) {
      return execute('update_task', {'task_id': 'task_1', 'status': 'done'});
    }
    if (lower.contains('spent') || lower.contains('paid') || lower.contains('bought')) {
      return execute('add_transaction', {
        'amount': -25.0,
        'category': 'other',
        'description': naturalLanguage,
      });
    }
    if (lower.contains('note') || lower.contains('remember')) {
      return execute('create_note', {
        'title': 'Quick Note',
        'content': naturalLanguage,
      });
    }
    if (lower.contains('schedule') || lower.contains('meeting') || lower.contains('event')) {
      return execute('schedule_event', {
        'title': 'New Event',
        'date': DateTime.now().toIso8601String().substring(0, 10),
        'time': '14:00',
      });
    }
    if (lower.contains('weather')) {
      return execute('get_weather', {});
    }

    return null; // No tool matched
  }
}

/// Loads tool definitions from mock data.
Future<List<Map<String, dynamic>>> loadToolDefinitions() async {
  try {
    final json = await rootBundle.loadString('assets/mock_data/tools/tools.json');
    final data = jsonDecode(json);
    if (data is Map && data.containsKey('tools')) {
      return (data['tools'] as List).cast<Map<String, dynamic>>();
    }
    if (data is List) return data.cast<Map<String, dynamic>>();
    return [];
  } catch (_) {
    return [];
  }
}
