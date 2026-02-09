/// Prism AI Host Server — expose AI inference to other apps via local HTTP API.
///
/// Implements an OpenAI-compatible API endpoint so other apps can use Prism's
/// local models by sending HTTP requests to localhost.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'ai_service.dart';

// ─── Host Server State ───────────────────────────────

class AIHostState {
  final bool isRunning;
  final int port;
  final int requestCount;
  final List<String> allowedApps;
  final String? error;

  const AIHostState({
    this.isRunning = false,
    this.port = 8090,
    this.requestCount = 0,
    this.allowedApps = const [],
    this.error,
  });

  AIHostState copyWith({
    bool? isRunning,
    int? port,
    int? requestCount,
    List<String>? allowedApps,
    String? error,
  }) =>
      AIHostState(
        isRunning: isRunning ?? this.isRunning,
        port: port ?? this.port,
        requestCount: requestCount ?? this.requestCount,
        allowedApps: allowedApps ?? this.allowedApps,
        error: error,
      );
}

// ─── Host Server Notifier ────────────────────────────

class AIHostNotifier extends Notifier<AIHostState> {
  HttpServer? _server;

  @override
  AIHostState build() {
    ref.onDispose(stop);
    return const AIHostState();
  }

  /// Start the local AI host server.
  Future<void> start({int port = 8090}) async {
    if (_server != null) return;

    try {
      final handler = const Pipeline()
          .addMiddleware(_corsMiddleware())
          .addMiddleware(_authMiddleware())
          .addHandler(_router);

      _server = await shelf_io.serve(handler, InternetAddress.loopbackIPv4, port);
      state = state.copyWith(isRunning: true, port: port, error: null);
    } catch (e) {
      state = state.copyWith(error: 'Failed to start server: $e');
    }
  }

  /// Stop the server.
  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    state = state.copyWith(isRunning: false);
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

    // Health check
    if (path == 'health' && method == 'GET') {
      return Response.ok(jsonEncode({'status': 'ok', 'service': 'prism'}),
          headers: {'content-type': 'application/json'});
    }

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

  // ─── Handlers ──────────────────────────────────────

  Response _handleListModels() {
    final aiState = ref.read(aiServiceProvider);
    final models = aiState.availableModels
        .map((m) => {
              'id': m.id,
              'object': 'model',
              'owned_by': 'prism',
              'provider': m.provider.name,
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
      final stream = body['stream'] == true;

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
        // For now, allow all local connections
        // Future: check Authorization header against allowed apps
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
