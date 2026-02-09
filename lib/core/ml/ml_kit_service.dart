/// On-device ML Kit intelligence services for Prism.
///
/// Provides OCR (text recognition), entity extraction (dates, amounts,
/// addresses from natural language), smart reply suggestions, and
/// language identification — all running locally on-device.
library;

import 'dart:ui' show Size;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';
import 'package:google_mlkit_smart_reply/google_mlkit_smart_reply.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';

// ─── OCR Service ─────────────────────────────────

/// Extracts text from images using on-device OCR.
class OcrService {
  TextRecognizer? _recognizer;

  TextRecognizer get recognizer =>
      _recognizer ??= TextRecognizer(script: TextRecognitionScript.latin);

  /// Recognize text from an image file path.
  Future<OcrResult> recognizeFromFile(String filePath) async {
    final inputImage = InputImage.fromFilePath(filePath);
    final recognized = await recognizer.processImage(inputImage);

    final lines = <String>[];
    final blocks = <OcrBlock>[];

    for (final block in recognized.blocks) {
      for (final line in block.lines) {
        lines.add(line.text);
      }
      blocks.add(OcrBlock(
        text: block.text,
        language: block.recognizedLanguages.firstOrNull ?? 'unknown',
        boundingBox: block.boundingBox,
      ));
    }

    return OcrResult(
      fullText: recognized.text,
      lines: lines,
      blocks: blocks,
    );
  }

  /// Recognize text from image bytes (e.g., camera capture).
  Future<OcrResult> recognizeFromBytes(
    List<int> bytes, {
    required int width,
    required int height,
    required InputImageRotation rotation,
    required InputImageFormat format,
    required int bytesPerRow,
  }) async {
    final metadata = InputImageMetadata(
      size: Size(width.toDouble(), height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: bytesPerRow,
    );
    final inputImage = InputImage.fromBytes(
      bytes: bytes as dynamic,
      metadata: metadata,
    );
    final recognized = await recognizer.processImage(inputImage);
    return OcrResult(
      fullText: recognized.text,
      lines: recognized.blocks.expand((b) => b.lines.map((l) => l.text)).toList(),
      blocks: recognized.blocks
          .map((b) => OcrBlock(
                text: b.text,
                language: b.recognizedLanguages.firstOrNull ?? 'unknown',
                boundingBox: b.boundingBox,
              ))
          .toList(),
    );
  }

  void dispose() {
    _recognizer?.close();
    _recognizer = null;
  }
}

class OcrResult {
  final String fullText;
  final List<String> lines;
  final List<OcrBlock> blocks;
  const OcrResult({required this.fullText, required this.lines, required this.blocks});
}

class OcrBlock {
  final String text;
  final String language;
  final dynamic boundingBox; // Rect from ML Kit
  const OcrBlock({required this.text, required this.language, this.boundingBox});
}

// ─── Entity Extraction ───────────────────────────

/// Extracts structured entities (dates, money, addresses, etc.) from text.
class EntityExtractionService {
  EntityExtractor? _extractor;
  EntityExtractorModelManager? _modelManager;

  Future<void> initialize({EntityExtractorLanguage language = EntityExtractorLanguage.english}) async {
    _modelManager = EntityExtractorModelManager();
    final isDownloaded = await _modelManager!.isModelDownloaded(language.name);
    if (!isDownloaded) {
      await _modelManager!.downloadModel(language.name);
    }
    _extractor = EntityExtractor(language: language);
  }

  /// Extract entities from natural language text.
  /// Returns structured data like amounts, dates, addresses, phone numbers.
  Future<List<ExtractedEntity>> extract(String text) async {
    if (_extractor == null) {
      await initialize();
    }

    final annotations = await _extractor!.annotateText(text);
    final entities = <ExtractedEntity>[];

    for (final annotation in annotations) {
      for (final entity in annotation.entities) {
        entities.add(ExtractedEntity(
          text: annotation.text,
          start: annotation.start,
          end: annotation.end,
          type: entity.type.name,
          rawValue: entity.rawValue,
        ));
      }
    }

    return entities;
  }

  void dispose() {
    _extractor?.close();
    _extractor = null;
  }
}

class ExtractedEntity {
  final String text;
  final int start;
  final int end;
  final String type; // 'money', 'dateTime', 'address', 'phone', 'email', etc.
  final dynamic rawValue;

  const ExtractedEntity({
    required this.text,
    required this.start,
    required this.end,
    required this.type,
    this.rawValue,
  });

  @override
  String toString() => 'Entity($type: "$text")';
}

// ─── Smart Reply ─────────────────────────────────

/// Generates smart reply suggestions based on conversation history.
class SmartReplyService {
  final SmartReply _smartReply = SmartReply();

  /// Add a message to the conversation history.
  void addMessage(String text, {required bool isLocalUser, DateTime? timestamp}) {
    final ts = timestamp ?? DateTime.now();
    if (isLocalUser) {
      _smartReply.addMessageToConversationFromLocalUser(text, ts.millisecondsSinceEpoch);
    } else {
      _smartReply.addMessageToConversationFromRemoteUser(text, ts.millisecondsSinceEpoch, 'ai');
    }
  }

  /// Get suggested replies based on conversation history.
  Future<List<String>> getSuggestions() async {
    final result = await _smartReply.suggestReplies();
    if (result.status == SmartReplySuggestionResultStatus.success) {
      return result.suggestions.toList();
    }
    return [];
  }

  /// Clear conversation history.
  void clearHistory() {
    // SmartReply doesn't have a clear method, so create a new instance
    dispose();
  }

  void dispose() {
    _smartReply.close();
  }
}

// ─── Language Identification ─────────────────────

/// Identifies the language of a given text.
class LanguageIdService {
  final LanguageIdentifier _identifier = LanguageIdentifier(confidenceThreshold: 0.5);

  /// Identify the primary language of the text.
  Future<String> identify(String text) async {
    return await _identifier.identifyLanguage(text);
  }

  /// Get all possible languages with confidence scores.
  Future<List<IdentifiedLanguage>> identifyPossibleLanguages(String text) async {
    return await _identifier.identifyPossibleLanguages(text);
  }

  void dispose() {
    _identifier.close();
  }
}

// ─── Unified ML Kit Provider ─────────────────────

class MlKitServices {
  final OcrService ocr = OcrService();
  final EntityExtractionService entityExtraction = EntityExtractionService();
  final SmartReplyService smartReply = SmartReplyService();
  final LanguageIdService languageId = LanguageIdService();

  void dispose() {
    ocr.dispose();
    entityExtraction.dispose();
    smartReply.dispose();
    languageId.dispose();
  }
}

final mlKitProvider = Provider<MlKitServices>((ref) {
  final services = MlKitServices();
  ref.onDispose(services.dispose);
  return services;
});

// ─── Convenience providers ───────────────────────

/// Parse a natural language finance input using entity extraction.
/// Input: "Spent $42 on groceries yesterday"
/// Returns: structured expense data.
Future<Map<String, dynamic>?> parseFinanceInput(
  EntityExtractionService extractor,
  String input,
) async {
  final entities = await extractor.extract(input);

  double? amount;
  String? category;
  DateTime? date;

  for (final entity in entities) {
    if (entity.type == 'money' && amount == null) {
      // Try to parse the amount from the text
      final match = RegExp(r'[\d,]+\.?\d*').firstMatch(entity.text);
      if (match != null) {
        amount = double.tryParse(match.group(0)!.replaceAll(',', ''));
      }
    }
    if (entity.type == 'dateTime' && date == null) {
      date = DateTime.tryParse(entity.rawValue?.toString() ?? '');
    }
  }

  // Extract category from remaining text (simple heuristic)
  final lowerInput = input.toLowerCase();
  final categories = ['groceries', 'dining', 'transport', 'health', 'entertainment', 'utilities', 'shopping'];
  for (final cat in categories) {
    if (lowerInput.contains(cat)) {
      category = cat;
      break;
    }
  }

  if (amount == null) return null;

  return {
    'amount': amount,
    'category': category ?? 'other',
    'date': date ?? DateTime.now(),
    'type': lowerInput.contains('earned') || lowerInput.contains('received') ? 'income' : 'expense',
    'description': input,
    'source': 'ai',
  };
}
