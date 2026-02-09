/// Prism AI Host Server — expose AI inference to other apps via local HTTP API.
///
/// Implements an OpenAI-compatible API endpoint so other apps can use Prism's
/// local models by sending HTTP requests to localhost.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:wakelock_plus/wakelock_plus.dart';

import 'ai_service.dart';
import 'api_playground_html.dart';

// ─── Host Server State ───────────────────────────────

class AIHostState {
  final bool isRunning;
  final int port;
  final int requestCount;
  final List<String> allowedApps;
  final String? error;
  final String accessCode;

  const AIHostState({
    this.isRunning = false,
    this.port = 8090,
    this.requestCount = 0,
    this.allowedApps = const [],
    this.error,
    this.accessCode = '',
  });

  AIHostState copyWith({
    bool? isRunning,
    int? port,
    int? requestCount,
    List<String>? allowedApps,
    String? error,
    String? accessCode,
  }) =>
      AIHostState(
        isRunning: isRunning ?? this.isRunning,
        port: port ?? this.port,
        requestCount: requestCount ?? this.requestCount,
        allowedApps: allowedApps ?? this.allowedApps,
        error: error,
        accessCode: accessCode ?? this.accessCode,
      );
}

// ─── Host Server Notifier ────────────────────────────

class AIHostNotifier extends Notifier<AIHostState> {
  HttpServer? _server;

  /// Pre-encoded HTML bytes + length — avoids re-encoding on every request.
  static final Uint8List _htmlBytes = Uint8List.fromList(utf8.encode(apiPlaygroundHtml));
  static final String _htmlLength = _htmlBytes.length.toString();

  @override
  AIHostState build() {
    ref.onDispose(stop);
    return const AIHostState();
  }

  /// Generate a random 6-digit alphanumeric access code.
  static String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no 0/O/1/I confusion
    final rng = Random.secure();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  /// Start the local AI host server.
  Future<void> start({int port = 8090}) async {
    if (_server != null) return;

    try {
      final code = _generateCode();
      final handler = const Pipeline()
          .addMiddleware(_corsMiddleware())
          .addMiddleware(_authMiddleware())
          .addHandler(_router);

      _server = await shelf_io.serve(
        handler,
        InternetAddress.anyIPv6, // accept both IPv4 and IPv6
        port,
      );
      _server!.autoCompress = false;

      // Keep the device awake so the server can respond even when
      // the user switches to a browser to open the API Playground.
      WakelockPlus.enable();

      state = state.copyWith(
        isRunning: true,
        port: port,
        error: null,
        accessCode: code,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to start server: $e');
    }
  }

  /// Stop the server.
  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    WakelockPlus.disable();
    state = state.copyWith(isRunning: false, accessCode: '');
  }

  /// Regenerate the access code (invalidates all existing sessions).
  void regenerateCode() {
    if (!state.isRunning) return;
    state = state.copyWith(accessCode: _generateCode());
  }

  /// Add an app to the allowed list.
  void allowApp(String appId) {
    if (!state.allowedApps.contains(appId)) {
      state = state.copyWith(allowedApps: [...state.allowedApps, appId]);
    }
  }

  /// Remove an app from the allowed list.
  void revokeApp(String appId) {
    state = state.copyWith(
      allowedApps: state.allowedApps.where((a) => a != appId).toList(),
    );
  }

  // ─── Request Router ────────────────────────────────

  FutureOr<Response> _router(Request request) async {
    final path = request.url.path;
    final method = request.method;

    // ── Public routes (no auth) ──

    // Root — serve API Playground HTML (pre-encoded bytes for speed)
    if ((path.isEmpty || path == '/') && method == 'GET') {
      return Response.ok(
        _htmlBytes,
        headers: {
          'content-type': 'text/html; charset=utf-8',
          'content-length': _htmlLength,
          'cache-control': 'public, max-age=3600',
        },
      );
    }

    // Health check
    if (path == 'health' && method == 'GET') {
      return Response.ok(jsonEncode({'status': 'ok', 'service': 'prism'}),
          headers: {'content-type': 'application/json'});
    }

    // Auth — validate access code
    if (path == 'api/auth' && method == 'POST') {
      return _handleAuth(request);
    }

    // ── Protected routes (require valid access code) ──

    final authError = _checkAuth(request);
    if (authError != null) return authError;

    // List models
    if (path == 'v1/models' && method == 'GET') {
      return _handleListModels();
    }

    // Chat completions (OpenAI-compatible)
    if (path == 'v1/chat/completions' && method == 'POST') {
      return await _handleChatCompletions(request);
    }

    return Response.notFound(jsonEncode({'error': 'Not found'}));
  }

  /// Check the Authorization: Bearer <code> header.
  Response? _checkAuth(Request request) {
    final authHeader = request.headers['authorization'] ?? '';
    if (authHeader.startsWith('Bearer ')) {
      final token = authHeader.substring(7).trim();
      if (token == state.accessCode) return null; // valid
    }
    return Response.unauthorized(
      jsonEncode({'error': 'Invalid or missing access code.'}),
      headers: {'content-type': 'application/json'},
    );
  }

  /// Handle POST /api/auth — validate the user-entered code.
  Future<Response> _handleAuth(Request request) async {
    try {
      final body = jsonDecode(await request.readAsString());
      final code = (body['code'] as String?)?.trim() ?? '';
      if (code == state.accessCode && code.isNotEmpty) {
        return Response.ok(
          jsonEncode({'success': true, 'message': 'Authenticated'}),
          headers: {'content-type': 'application/json'},
        );
      }
      return Response.ok(
        jsonEncode({'success': false, 'message': 'Invalid access code.'}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({'success': false, 'message': 'Bad request.'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // ─── Handlers ──────────────────────────────────────

  Response _handleListModels() {
    final aiState = ref.read(aiServiceProvider);
    final models = aiState.availableModels
        .map((m) => {
              'id': m.id,
              'object': 'model',
              'owned_by': 'prism',
              'provider': m.provider.name,
              'active': m.id == aiState.activeModel?.id,
            })
        .toList();

    return Response.ok(
      jsonEncode({'object': 'list', 'data': models}),
      headers: {'content-type': 'application/json'},
    );
  }

  Future<Response> _handleChatCompletions(Request request) async {
    try {
      final body = jsonDecode(await request.readAsString());
      final messages = (body['messages'] as List)
          .map((m) => PrismMessage(
                role: m['role'] as String,
                content: m['content'] as String,
              ))
          .toList();

      final aiNotifier = ref.read(aiServiceProvider.notifier);
      final aiState = ref.read(aiServiceProvider);
      final stream = body['stream'] == true;

      // ── Resolve which model to use ──
      // The gateway should prefer the model the caller asked for.
      // If "auto" or omitted, use whatever is already active — but prefer
      // a local model over a cloud model to avoid routing to Google/OpenAI.
      final requestedModelId = (body['model'] as String?) ?? 'auto';

      if (requestedModelId != 'auto') {
        // Caller asked for a specific model — switch if needed
        final target = aiState.availableModels
            .where((m) => m.id == requestedModelId)
            .firstOrNull;
        if (target != null && target.id != aiState.activeModel?.id) {
          await aiNotifier.selectModel(target);
        }
      } else if (aiState.activeModel == null ||
          (aiState.activeModel!.provider == ProviderType.gemini ||
           aiState.activeModel!.provider == ProviderType.openai ||
           aiState.activeModel!.provider == ProviderType.custom)) {
        // "auto" but current model is a cloud provider — try to find a local one
        final localModel = aiState.availableModels
            .where((m) => m.provider == ProviderType.local)
            .firstOrNull;
        if (localModel != null) {
          await aiNotifier.selectModel(localModel);
        }
      }

      // Verify a model is loaded
      final currentModel = ref.read(aiServiceProvider).activeModel;
      if (currentModel == null) {
        return Response.internalServerError(
          body: jsonEncode({
            'error': {
              'message': 'No model available. Load a model in the Prism app first.',
              'type': 'server_error',
            }
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      state = state.copyWith(requestCount: state.requestCount + 1);

      if (stream) {
        // SSE streaming response
        final controller = StreamController<List<int>>();

        () async {
          await for (final token in aiNotifier.generateStream(messages)) {
            final chunk = {
              'id': 'chatcmpl-${DateTime.now().millisecondsSinceEpoch}',
              'object': 'chat.completion.chunk',
              'choices': [
                {
                  'delta': {'content': token},
                  'index': 0,
                }
              ],
            };
            controller.add(utf8.encode('data: ${jsonEncode(chunk)}\n\n'));
          }
          controller.add(utf8.encode('data: [DONE]\n\n'));
          await controller.close();
        }();

        return Response.ok(
          controller.stream,
          headers: {
            'content-type': 'text/event-stream',
            'cache-control': 'no-cache',
            'connection': 'keep-alive',
          },
        );
      } else {
        // Non-streaming response
        final response = await aiNotifier.generate(messages);
        return Response.ok(
          jsonEncode({
            'id': 'chatcmpl-${DateTime.now().millisecondsSinceEpoch}',
            'object': 'chat.completion',
            'choices': [
              {
                'message': {'role': 'assistant', 'content': response},
                'index': 0,
                'finish_reason': 'stop',
              }
            ],
            'usage': {
              'prompt_tokens': 0,
              'completion_tokens': 0,
              'total_tokens': 0,
            },
          }),
          headers: {'content-type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': {'message': e.toString()}}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // ─── Middleware ─────────────────────────────────────

  Middleware _corsMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        if (request.method == 'OPTIONS') {
          return Response.ok('', headers: _corsHeaders);
        }
        final response = await innerHandler(request);
        return response.change(headers: _corsHeaders);
      };
    };
  }

  Middleware _authMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        // Auth is handled per-route in _router; middleware just passes through.
        return innerHandler(request);
      };
    };
  }

  static const _corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  };
}

// ─── Riverpod Provider ───────────────────────────────

final aiHostProvider = NotifierProvider<AIHostNotifier, AIHostState>(
  AIHostNotifier.new,
);
