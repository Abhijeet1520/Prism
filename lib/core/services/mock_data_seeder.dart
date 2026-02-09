/// Mock Data Seeder — Populates database with demo data.
///
/// Use this service to seed the database with sample areas, resources,
/// notes, tasks, and conversations for testing and demo purposes.
library;

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';

class MockDataSeeder {
  final PrismDatabase db;
  final _uuid = const Uuid();

  MockDataSeeder(this.db);

  /// Seeds all mock data from assets/mock_data/app_data.json
  Future<void> seedAll() async {
    await seedAreas();
    await seedResources();
    await seedNotes();
    await seedTasks();
    await seedTransactions();
    await seedConversations();
  }

  /// Seeds demo areas into the database.
  Future<void> seedAreas() async {
    final existing = await db.watchAreas().first;
    if (existing.isNotEmpty) return; // Don't duplicate

    final raw = await rootBundle.loadString('assets/mock_data/app_data.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final areas = data['areas'] as List<dynamic>? ?? [];

    for (final a in areas) {
      await db.createArea(
        uuid: a['uuid'] as String,
        name: a['name'] as String,
        description: a['description'] as String? ?? '',
        icon: a['icon'] as String? ?? 'folder',
        color: a['color'] as int? ?? 0xFF6750A4,
      );
    }
  }

  /// Seeds demo resources and links them to areas.
  Future<void> seedResources() async {
    final existing = await db.watchResources().first;
    if (existing.isNotEmpty) return;

    final raw = await rootBundle.loadString('assets/mock_data/app_data.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final resources = data['resources'] as List<dynamic>? ?? [];

    for (final r in resources) {
      final resourceId = await db.createResource(
        uuid: r['uuid'] as String,
        name: r['name'] as String,
        description: r['description'] as String? ?? '',
        icon: r['icon'] as String? ?? 'description',
      );

      // Link to areas
      final areaUuids = (r['areas'] as List<dynamic>?)?.cast<String>() ?? [];
      for (final areaUuid in areaUuids) {
        final area = await db.getArea(areaUuid);
        if (area != null) {
          await db.linkResourceToArea(resourceId, area.id);
        }
      }
    }
  }

  /// Seeds demo notes and links them to resources.
  Future<void> seedNotes() async {
    final existing = await db.watchNotes().first;
    if (existing.isNotEmpty) return;

    final raw = await rootBundle.loadString('assets/mock_data/app_data.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final notes = data['notes'] as List<dynamic>? ?? [];

    // Map category to resource for linking
    final categoryToResource = <String, String>{
      'resource': 'res_flutter',
      'project': 'res_side_projects',
      'area': 'res_flutter', // Default
      'archive': 'res_flutter',
    };

    for (final n in notes) {
      final noteId = await db.createNote(
        uuid: _uuid.v4(),
        title: n['title'] as String,
        content: n['content'] as String,
        tags: n['tags'] as String? ?? '',
        source: n['source'] as String? ?? 'demo',
      );

      // Link to a resource based on category
      final category = n['category'] as String? ?? 'resource';
      final resourceUuid = categoryToResource[category] ?? 'res_flutter';
      final resource = await db.getResource(resourceUuid);
      if (resource != null) {
        await db.linkNoteToResource(noteId, resource.id);
      }
    }
  }

  /// Seeds demo tasks into the database.
  Future<void> seedTasks() async {
    final existing = await db.watchAllTasks().first;
    if (existing.isNotEmpty) return;

    final raw = await rootBundle.loadString('assets/mock_data/app_data.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final tasks = data['tasks'] as List<dynamic>? ?? [];

    for (final t in tasks) {
      DateTime? dueDate;
      if (t['dueDate'] != null) {
        dueDate = DateTime.tryParse(t['dueDate'] as String);
      }

      await db.createTask(
        uuid: _uuid.v4(),
        title: t['title'] as String,
        description: '',
        priority: t['priority'] as String? ?? 'medium',
        category: 'general',
        dueDate: dueDate,
      );
    }
  }

  /// Seeds demo transactions into the database.
  Future<void> seedTransactions() async {
    final existing = await db.watchCurrentMonthTransactions().first;
    if (existing.isNotEmpty) return;

    final raw = await rootBundle.loadString('assets/mock_data/app_data.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final transactions = data['transactions'] as List<dynamic>? ?? [];

    for (final tx in transactions) {
      final amount = (tx['amount'] as num).toDouble();
      await db.logTransaction(
        uuid: _uuid.v4(),
        amount: amount.abs(),
        category: tx['category'] as String,
        description: tx['description'] as String? ?? '',
        type: amount < 0 ? 'expense' : 'income',
        source: tx['source'] as String? ?? 'demo',
      );
    }
  }

  /// Seeds demo conversations into the database.
  Future<void> seedConversations() async {
    final existing = await db.watchConversations().first;
    if (existing.isNotEmpty) return;

    final raw = await rootBundle.loadString('assets/mock_data/app_data.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final conversations = data['conversations'] as List<dynamic>? ?? [];

    for (final c in conversations) {
      final convUuid = _uuid.v4();
      final convId = await db.createConversation(
        uuid: convUuid,
        title: c['title'] as String,
        modelId: 'mock',
        provider: 'mock',
      );

      final messages = c['messages'] as List<dynamic>? ?? [];
      for (final m in messages) {
        await db.addMessage(
          uuid: _uuid.v4(),
          conversationId: convId,
          role: m['role'] as String,
          content: m['content'] as String,
        );
      }
    }
  }

  /// Clears all data from the database (for testing).
  Future<void> clearAll() async {
    // This would need to be implemented with delete statements
    // Left as a stub for now
  }
}
