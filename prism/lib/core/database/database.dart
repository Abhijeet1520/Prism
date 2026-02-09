/// Prism database — Drift-powered SQLite with FTS5 search.
///
/// Run `dart run build_runner build` to generate the `.g.dart` file.
library;

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Conversations, Messages, TaskEntries, Transactions, Notes, AppSettings],
  include: {'queries.drift'},
)
class PrismDatabase extends _$PrismDatabase {
  PrismDatabase([QueryExecutor? executor])
      : super(
          executor ??
              driftDatabase(
                name: 'prism',
                native: DriftNativeOptions(
                  databaseDirectory: getApplicationSupportDirectory,
                ),
              ),
        );

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        // Create FTS5 virtual tables that Drift doesn't auto-generate
        await _createFts5Tables();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          // v1 → v2: Ensure FTS5 tables exist (they were missing in v1)
          await _createFts5Tables();
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
        // Safety: ensure FTS5 tables exist even if migration was skipped
        await _createFts5Tables();
      },
    );
  }

  /// Create FTS5 virtual tables if they don't already exist.
  /// Drift's code generator doesn't include FTS5 virtual tables in
  /// allSchemaEntities, so we must create them manually.
  Future<void> _createFts5Tables() async {
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS message_search USING fts5(
        content,
        content=messages,
        content_rowid=id
      )
    ''');
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS note_search USING fts5(
        title,
        content,
        content=notes,
        content_rowid=id
      )
    ''');
  }

  // ─── Conversation queries ────────────────────────

  /// Watch all non-archived conversations, newest first.
  Stream<List<Conversation>> watchConversations() {
    return (select(conversations)
          ..where((c) => c.isArchived.equals(false))
          ..orderBy([(c) => OrderingTerm.desc(c.updatedAt)]))
        .watch();
  }

  /// Get a conversation by UUID.
  Future<Conversation?> getConversation(String uuid) {
    return (select(conversations)..where((c) => c.uuid.equals(uuid)))
        .getSingleOrNull();
  }

  /// Create a new conversation, returns its DB id.
  Future<int> createConversation({
    required String uuid,
    String title = 'New Chat',
    String modelId = 'mock',
    String provider = 'mock',
    String systemPrompt = '',
  }) {
    return into(conversations).insert(ConversationsCompanion.insert(
      uuid: uuid,
      title: Value(title),
      modelId: Value(modelId),
      provider: Value(provider),
      systemPrompt: Value(systemPrompt),
    ));
  }

  /// Update conversation title.
  Future<void> updateConversationTitle(String uuid, String title) {
    return (update(conversations)..where((c) => c.uuid.equals(uuid)))
        .write(ConversationsCompanion(
      title: Value(title),
      updatedAt: Value(DateTime.now()),
    ));
  }

  // ─── Message queries ────────────────────────────

  /// Watch messages for a conversation.
  Stream<List<Message>> watchMessages(int conversationId) {
    return (select(messages)
          ..where((m) => m.conversationId.equals(conversationId))
          ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
        .watch();
  }

  /// Add a message to a conversation.
  Future<int> addMessage({
    required String uuid,
    required int conversationId,
    required String role,
    required String content,
    String? toolCalls,
    String? toolResult,
    int tokenCount = 0,
  }) {
    return into(messages).insert(MessagesCompanion.insert(
      uuid: uuid,
      conversationId: conversationId,
      role: role,
      content: content,
      toolCalls: Value(toolCalls),
      toolResult: Value(toolResult),
      tokenCount: Value(tokenCount),
    ));
  }

  /// Delete a message by uuid.
  Future<int> deleteMessage(String uuid) {
    return (delete(messages)..where((m) => m.uuid.equals(uuid))).go();
  }

  /// Update a message's content by uuid.
  Future<int> updateMessageContent(String uuid, String content) {
    return (update(messages)..where((m) => m.uuid.equals(uuid)))
        .write(MessagesCompanion(content: Value(content)));
  }

  /// Get the last N messages for a conversation.
  Future<List<Message>> getLastMessages(int conversationId, {int limit = 50}) {
    return (select(messages)
          ..where((m) => m.conversationId.equals(conversationId))
          ..orderBy([(m) => OrderingTerm.desc(m.createdAt)])
          ..limit(limit))
        .get();
  }

  // ─── Task queries ───────────────────────────────

  /// Watch all tasks (completed + pending).
  Stream<List<TaskEntry>> watchAllTasks() {
    return (select(taskEntries)
          ..orderBy([
            (t) => OrderingTerm.asc(t.isCompleted),
            (t) => OrderingTerm(
                  expression: t.priority.caseMatch(
                    when: {const Constant('high'): const Constant(0), const Constant('medium'): const Constant(1)},
                    orElse: const Constant(2),
                  ),
                ),
            (t) => OrderingTerm.asc(t.dueDate),
          ]))
        .watch();
  }

  /// Watch incomplete tasks.
  Stream<List<TaskEntry>> watchPendingTasks() {
    return (select(taskEntries)
          ..where((t) => t.isCompleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.priority.caseMatch(
                    when: {const Constant('high'): const Constant(0), const Constant('medium'): const Constant(1)},
                    orElse: const Constant(2),
                  ),
                ),
            (t) => OrderingTerm.asc(t.dueDate),
          ]))
        .watch();
  }

  /// Create a task.
  Future<int> createTask({
    required String uuid,
    required String title,
    String description = '',
    String priority = 'medium',
    String category = 'general',
    DateTime? dueDate,
  }) {
    return into(taskEntries).insert(TaskEntriesCompanion.insert(
      uuid: uuid,
      title: title,
      description: Value(description),
      priority: Value(priority),
      category: Value(category),
      dueDate: Value(dueDate),
    ));
  }

  /// Toggle task completion.
  Future<void> toggleTask(String uuid) async {
    final task = await (select(taskEntries)..where((t) => t.uuid.equals(uuid)))
        .getSingle();
    await (update(taskEntries)..where((t) => t.uuid.equals(uuid))).write(
      TaskEntriesCompanion(
        isCompleted: Value(!task.isCompleted),
        completedAt: Value(task.isCompleted ? null : DateTime.now()),
      ),
    );
  }

  /// Update a task's fields.
  Future<void> updateTask(
    String uuid, {
    String? title,
    String? description,
    String? priority,
    DateTime? dueDate,
    bool clearDueDate = false,
  }) {
    return (update(taskEntries)..where((t) => t.uuid.equals(uuid))).write(
      TaskEntriesCompanion(
        title: title != null ? Value(title) : const Value.absent(),
        description:
            description != null ? Value(description) : const Value.absent(),
        priority: priority != null ? Value(priority) : const Value.absent(),
        dueDate: clearDueDate
            ? const Value(null)
            : (dueDate != null ? Value(dueDate) : const Value.absent()),
      ),
    );
  }

  /// Delete a task by uuid.
  Future<int> deleteTask(String uuid) {
    return (delete(taskEntries)..where((t) => t.uuid.equals(uuid))).go();
  }

  // ─── Transaction queries ────────────────────────

  /// Watch all transactions for the current month.
  Stream<List<Transaction>> watchCurrentMonthTransactions() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month);
    final startOfNext = DateTime(now.year, now.month + 1);
    return (select(transactions)
          ..where((t) => t.date.isBiggerOrEqualValue(startOfMonth) & t.date.isSmallerThanValue(startOfNext))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  /// Log a transaction.
  Future<int> logTransaction({
    required String uuid,
    required double amount,
    required String category,
    required String type,
    String description = '',
    String source = 'manual',
    DateTime? date,
  }) {
    return into(transactions).insert(TransactionsCompanion.insert(
      uuid: uuid,
      amount: amount,
      category: category,
      type: type,
      description: Value(description),
      source: Value(source),
      date: Value(date ?? DateTime.now()),
    ));
  }

  /// Update a transaction's category.
  Future<int> updateTransactionCategory(String uuid, String newCategory) {
    return (update(transactions)..where((t) => t.uuid.equals(uuid)))
        .write(TransactionsCompanion(category: Value(newCategory)));
  }

  /// Delete a transaction by uuid.
  Future<int> deleteTransaction(String uuid) {
    return (delete(transactions)..where((t) => t.uuid.equals(uuid))).go();
  }

  /// Duplicate a transaction.
  Future<int> duplicateTransaction(Transaction txn) {
    return logTransaction(
      uuid: const Uuid().v4(),
      amount: txn.amount,
      category: txn.category,
      type: txn.type,
      description: txn.description,
      source: txn.source,
    );
  }

  // ─── Note queries ──────────────────────────────

  /// Watch all notes, newest first.
  Stream<List<Note>> watchNotes() {
    return (select(notes)..orderBy([(n) => OrderingTerm.desc(n.updatedAt)]))
        .watch();
  }

  /// Create a note.
  Future<int> createNote({
    required String uuid,
    required String title,
    required String content,
    String tags = '',
    String source = 'manual',
  }) {
    return into(notes).insert(NotesCompanion.insert(
      uuid: uuid,
      title: title,
      content: content,
      tags: Value(tags),
      source: Value(source),
    ));
  }

  /// Update a note's fields.
  Future<void> updateNote(
    String uuid, {
    String? title,
    String? content,
    String? tags,
  }) {
    return (update(notes)..where((n) => n.uuid.equals(uuid))).write(
      NotesCompanion(
        title: title != null ? Value(title) : const Value.absent(),
        content: content != null ? Value(content) : const Value.absent(),
        tags: tags != null ? Value(tags) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Delete a note by uuid.
  Future<int> deleteNote(String uuid) {
    return (delete(notes)..where((n) => n.uuid.equals(uuid))).go();
  }

  // ─── Settings queries ──────────────────────────

  /// Get a setting value.
  Future<String?> getSetting(String key) async {
    final row = await (select(appSettings)..where((s) => s.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  /// Set a setting value (upsert).
  Future<void> setSetting(String key, String value) {
    return into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: value),
    );
  }
}

// ─── Riverpod provider ──────────────────────────────

final databaseProvider = Provider<PrismDatabase>((ref) {
  final db = PrismDatabase();
  ref.onDispose(db.close);
  return db;
});
