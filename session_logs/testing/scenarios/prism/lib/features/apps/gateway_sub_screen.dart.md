# prism/lib/features/apps/gateway_sub_screen.dart

## Unit Scenarios
- Server status text matches `AIHostState`.
- Endpoint labels render with method badges.
- Toggle calls start or stop on notifier.

## Widget Scenarios
- Running state shows endpoint and request count.
- Error message renders in error color.
- Toggle updates UI state.

## Integration Scenarios
- Start gateway -> health endpoint returns ok.
- Stop gateway -> requests fail gracefully.
- Repeated toggles do not leak resources.
