import 'dart:convert';
import 'package:flutter/services.dart';

/// Centralized mock data loading service.
/// Loads JSON assets once and caches them for the session.
/// Easy to replace with real backend later — same interface.
class MockDataService {
  MockDataService._();
  static final instance = MockDataService._();

  // ── Caches ──────────────────────────────────────────────────────
  Map<String, dynamic>? _dailySummary;
  List<dynamic>? _conversations;
  List<dynamic>? _messages;
  List<dynamic>? _brainItems;
  List<dynamic>? _notes;
  List<dynamic>? _tasks;
  List<dynamic>? _transactions;
  List<dynamic>? _budgets;
  List<dynamic>? _files;
  List<dynamic>? _tools;
  List<dynamic>? _mcpServers;
  List<dynamic>? _providers;
  List<dynamic>? _personas;
  Map<String, dynamic>? _models;
  Map<String, dynamic>? _appSettings;

  // ── Daily Summary ───────────────────────────────────────────────
  Future<Map<String, dynamic>> getDailySummary() async {
    _dailySummary ??= jsonDecode(
      await rootBundle.loadString('assets/mock_data/daily_summary.json'),
    ) as Map<String, dynamic>;
    return _dailySummary!;
  }

  // ── Conversations & Messages ────────────────────────────────────
  Future<List<dynamic>> getConversations() async {
    _conversations ??= jsonDecode(
      await rootBundle.loadString('assets/mock_data/conversations/conversations.json'),
    ) as List;
    return _conversations!;
  }

  Future<List<dynamic>> getMessages() async {
    _messages ??= jsonDecode(
      await rootBundle.loadString('assets/mock_data/conversations/messages.json'),
    ) as List;
    return _messages!;
  }

  // ── Brain ───────────────────────────────────────────────────────
  Future<List<dynamic>> getBrainItems() async {
    _brainItems ??= jsonDecode(
      await rootBundle.loadString('assets/mock_data/brain/brain_items.json'),
    ) as List;
    return _brainItems!;
  }

  Future<List<dynamic>> getNotes() async {
    _notes ??= jsonDecode(
      await rootBundle.loadString('assets/mock_data/brain/notes.json'),
    ) as List;
    return _notes!;
  }

  // ── Tasks ───────────────────────────────────────────────────────
  Future<List<dynamic>> getTasks() async {
    _tasks ??= jsonDecode(
      await rootBundle.loadString('assets/mock_data/tasks/tasks.json'),
    ) as List;
    return _tasks!;
  }

  // ── Finance ─────────────────────────────────────────────────────
  Future<List<dynamic>> getTransactions() async {
    _transactions ??= jsonDecode(
      await rootBundle.loadString('assets/mock_data/finance/transactions.json'),
    ) as List;
    return _transactions!;
  }

  Future<List<dynamic>> getBudgets() async {
    _budgets ??= jsonDecode(
      await rootBundle.loadString('assets/mock_data/finance/budgets.json'),
    ) as List;
    return _budgets!;
  }

  // ── Files ───────────────────────────────────────────────────────
  Future<List<dynamic>> getFiles() async {
    _files ??= jsonDecode(
      await rootBundle.loadString('assets/mock_data/files/files.json'),
    ) as List;
    return _files!;
  }

  // ── Tools ───────────────────────────────────────────────────────
  Future<List<dynamic>> getTools() async {
    _tools ??= jsonDecode(
      await rootBundle.loadString('assets/mock_data/tools/tools.json'),
    ) as List;
    return _tools!;
  }

  Future<List<dynamic>> getMcpServers() async {
    _mcpServers ??= jsonDecode(
      await rootBundle.loadString('assets/mock_data/tools/mcp_servers.json'),
    ) as List;
    return _mcpServers!;
  }

  // ── Settings ────────────────────────────────────────────────────
  Future<List<dynamic>> getProviders() async {
    _providers ??= jsonDecode(
      await rootBundle.loadString('assets/mock_data/settings/providers.json'),
    ) as List;
    return _providers!;
  }

  Future<List<dynamic>> getPersonas() async {
    _personas ??= jsonDecode(
      await rootBundle.loadString('assets/mock_data/settings/personas.json'),
    ) as List;
    return _personas!;
  }

  Future<Map<String, dynamic>> getModels() async {
    _models ??= jsonDecode(
      await rootBundle.loadString('assets/mock_data/models.json'),
    ) as Map<String, dynamic>;
    return _models!;
  }

  Future<Map<String, dynamic>> getAppSettings() async {
    _appSettings ??= jsonDecode(
      await rootBundle.loadString('assets/mock_data/settings/app_settings.json'),
    ) as Map<String, dynamic>;
    return _appSettings!;
  }

  /// Pre-load all data (call on splash screen)
  Future<void> preloadAll() async {
    await Future.wait([
      getDailySummary(),
      getConversations(),
      getMessages(),
      getBrainItems(),
      getTasks(),
      getTransactions(),
      getTools(),
      getProviders(),
      getPersonas(),
      getModels(),
      getAppSettings(),
    ]);
  }
}
