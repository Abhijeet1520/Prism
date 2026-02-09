# prism/lib/core/ai/ai_host_server.dart

## Unit Scenarios
- Starting server updates state and binds to configured port.
- `/health` returns JSON with status ok.
- `/v1/models` returns list of available models from `aiServiceProvider`.
- `/v1/chat/completions` returns non-streaming response payload shape.

## Widget Scenarios
- Gateway UI reflects server running state and toggles start/stop.
- Error state displays message on server start failure.
- Request count increments and shows in UI.

## Integration Scenarios
- Start gateway -> hit health endpoint -> 200.
- Streaming request returns SSE chunks ending with `[DONE]`.
- Unauthorized apps are rejected when auth middleware is enforced (future behavior).
