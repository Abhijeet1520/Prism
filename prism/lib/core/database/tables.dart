/// Drift database table definitions for Prism.
///
/// Tables: Conversations, Messages, Tasks, Transactions, Notes, AppSettings.
/// Uses FTS5 for full-text search on Messages and Notes.
library;

import 'dart:ui';
import 'package:drift/drift.dart';

// ─── Shared mixin ─────────────────────────────────

mixin AutoIncrementingPrimaryKey on Table {
  IntColumn get id => integer().autoIncrement()();
}

// ─── Conversations ────────────────────────────────

@DataClassName('Conversation')
class Conversations extends Table with AutoIncrementingPrimaryKey {
  TextColumn get uuid => text().unique()();
  TextColumn get title => text().withDefault(const Constant('New Chat'))();
  TextColumn get modelId => text().withDefault(const Constant('mock'))();
  TextColumn get provider => text().withDefault(const Constant('mock'))();
  TextColumn get systemPrompt => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}

// ─── Messages ─────────────────────────────────────

@DataClassName('Message')
class Messages extends Table with AutoIncrementingPrimaryKey {
  TextColumn get uuid => text().unique()();
  IntColumn get conversationId => integer().references(Conversations, #id)();
  TextColumn get role => text()(); // 'user' | 'assistant' | 'system' | 'tool'
  TextColumn get content => text()();
  TextColumn get toolCalls => text().nullable()(); // JSON-encoded tool calls
  TextColumn get toolResult => text().nullable()(); // JSON-encoded tool result
  IntColumn get tokenCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ─── Tasks ────────────────────────────────────────

@DataClassName('TaskEntry')
class TaskEntries extends Table with AutoIncrementingPrimaryKey {
  TextColumn get uuid => text().unique()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get priority => text().withDefault(const Constant('medium'))(); // 'low'|'medium'|'high'
  TextColumn get category => text().withDefault(const Constant('general'))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

// ─── Financial Transactions ───────────────────────

@DataClassName('Transaction')
class Transactions extends Table with AutoIncrementingPrimaryKey {
  TextColumn get uuid => text().unique()();
  RealColumn get amount => real()();
  TextColumn get category => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get type => text()(); // 'expense' | 'income'
  TextColumn get source => text().withDefault(const Constant('manual'))(); // 'manual' | 'ocr' | 'ai'
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ─── Notes (Brain / Knowledge Base) ───────────────

@DataClassName('Note')
class Notes extends Table with AutoIncrementingPrimaryKey {
  TextColumn get uuid => text().unique()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  TextColumn get tags => text().withDefault(const Constant(''))(); // comma-separated
  TextColumn get source => text().withDefault(const Constant('manual'))(); // 'manual' | 'import' | 'ai'
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// ─── App Settings ─────────────────────────────────

@DataClassName('AppSetting')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

// ─── Type converters ─────────────────────────────

class ColorConverter extends TypeConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromSql(int fromDb) => Color(fromDb);

  @override
  int toSql(Color value) => value.toARGB32();
}
