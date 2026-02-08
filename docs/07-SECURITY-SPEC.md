# Prism — Security Specification

## 1 Threat Model

### 1.1 Assets

| Asset | Sensitivity | Storage |
|---|---|---|
| AI provider API keys | Critical | flutter_secure_storage (OS Keystore/Keychain) |
| Conversation data | High | Drift/SQLite (local), Supabase (optional sync) |
| Financial transaction data | Critical | Drift/SQLite (local), excluded from sync by default |
| PARA notes & files | High | Local file system + Drift metadata |
| Supabase credentials | Critical | flutter_secure_storage |
| GitHub token | Critical | flutter_secure_storage |
| AI Gateway tokens | High | Drift (hashed with SHA-256) |
| MCP server auth tokens | High | flutter_secure_storage |
| Notification content | High | Processed in-memory, parsed data stored in Drift |

### 1.2 Threat Vectors

| Threat | Mitigation |
|---|---|
| API key leakage | Encrypted storage, never logged, never synced to cloud |
| Data exfiltration via malicious MCP server | Tool execution sandboxing, user approval for sensitive ops |
| Man-in-the-middle on API calls | TLS 1.2+ enforced, certificate pinning for critical APIs |
| AI Gateway unauthorized access | Token auth, rate limiting, localhost-only by default |
| Malicious code execution | Sandboxed environments (QuickJS, Docker, remote) |
| Notification data privacy | Local processing only, opt-in per app, no cloud transmission |
| Database theft (physical device) | Optional SQLCipher encryption |
| Supply chain attack (dependencies) | Dependabot alerts, dependency audit, minimal dependency surface |

---

## 2 Credential Management

### 2.1 flutter_secure_storage

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CredentialStore {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  Future<void> storeApiKey(String provider, String key) async {
    await _storage.write(key: 'api_key_$provider', value: key);
  }

  Future<String?> getApiKey(String provider) async {
    return await _storage.read(key: 'api_key_$provider');
  }

  Future<void> deleteApiKey(String provider) async {
    await _storage.delete(key: 'api_key_$provider');
  }
}
```

### 2.2 Stored Credentials

| Credential | Storage Key | Platform Support |
|---|---|---|
| OpenAI API key | `api_key_openai` | All |
| Gemini API key | `api_key_gemini` | All |
| Anthropic API key | `api_key_anthropic` | All |
| Mistral API key | `api_key_mistral` | All |
| Custom provider keys | `api_key_custom_<id>` | All |
| Supabase URL | `supabase_url` | All |
| Supabase anon key | `supabase_anon_key` | All |
| GitHub token | `github_token` | All |
| Firecrawl API key | `firecrawl_api_key` | All |
| MCP server tokens | `mcp_token_<server_id>` | All |

---

## 3 Data Protection

### 3.1 Data at Rest

| Layer | Protection |
|---|---|
| Drift/SQLite database | Optional SQLCipher encryption (AES-256-CBC) |
| Local files | OS file system permissions (app-scoped on Android) |
| Secure credentials | OS Keystore (Android) / Keychain (iOS/macOS) |
| Downloaded models | App-scoped storage, no encryption (large files) |

### 3.2 Data in Transit

| Channel | Protection |
|---|---|
| Cloud AI API calls | TLS 1.2+ (HTTPS) |
| Supabase sync | TLS 1.2+ (HTTPS) |
| Ollama (local/LAN) | HTTP (trusted network) or HTTPS (user-configured) |
| AI Gateway (localhost) | HTTP (localhost only, no external access) |
| MCP (stdio) | Process-level isolation |
| MCP (SSE) | TLS recommended for remote servers |

### 3.3 Data Classification

| Category | Examples | Sync | Encryption |
|---|---|---|---|
| **Critical** | API keys, tokens | Never synced | OS Keystore |
| **Sensitive** | Financial data, notifications | Opt-in only | SQLCipher (optional) |
| **Personal** | Conversations, notes, tasks | Default sync | TLS in transit |
| **Public** | Model metadata, tool schemas | Always sync | None needed |

---

## 4 AI Gateway Security

### 4.1 Access Control

```dart
// Token-based auth with SHA-256 hashing
class GatewayAuth {
  /// Generate a new API token (shown once to user)
  Future<String> generateToken(String name, {
    int rateLimitPerMinute = 60,
    DateTime? expiresAt,
  }) async {
    final token = _generateSecureToken(32);
    final hash = sha256.convert(utf8.encode(token)).toString();

    await _db.gatewayTokenDao.insert(GatewayTokensCompanion(
      name: Value(name),
      tokenHash: Value(hash),
      rateLimitPerMinute: Value(rateLimitPerMinute),
      expiresAt: Value(expiresAt),
    ));

    return token;  // Return plaintext only once
  }

  /// Validate incoming request token
  Future<bool> validateToken(String token) async {
    final hash = sha256.convert(utf8.encode(token)).toString();
    final record = await _db.gatewayTokenDao.findByHash(hash);
    if (record == null) return false;
    if (!record.isActive) return false;
    if (record.expiresAt != null && record.expiresAt!.isBefore(DateTime.now())) return false;
    return true;
  }
}
```

### 4.2 Rate Limiting

```dart
class RateLimiter {
  final Map<String, List<DateTime>> _requestLog = {};

  bool isAllowed(String tokenHash, int maxPerMinute) {
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(minutes: 1));

    _requestLog[tokenHash] = (_requestLog[tokenHash] ?? [])
        .where((t) => t.isAfter(cutoff))
        .toList();

    if (_requestLog[tokenHash]!.length >= maxPerMinute) return false;

    _requestLog[tokenHash]!.add(now);
    return true;
  }
}
```

### 4.3 Network Binding

- Default: `localhost` only (127.0.0.1).
- User can optionally bind to `0.0.0.0` for LAN access (with warning dialog).
- No UPnP or port forwarding — explicit user action required.

---

## 5 Code Execution Sandboxing

### 5.1 Sandbox Levels

| Environment | Isolation | Capabilities |
|---|---|---|
| **QuickJS (mobile)** | No file system, no network, no process spawning | Pure computation only |
| **Docker (desktop)** | Container-level: filesystem, network, process isolation | Configurable per container |
| **Remote (cloud)** | Full server-side isolation | Stateless, time-limited |

### 5.2 Docker Configuration

```yaml
# Default sandbox container
security_opt:
  - no-new-privileges:true
read_only: true
tmpfs:
  - /tmp:size=100M
network_mode: none
mem_limit: 256M
cpus: 1.0
pids_limit: 100
```

### 5.3 Execution Limits

| Limit | Value |
|---|---|
| Execution timeout | 30 seconds (configurable) |
| Memory | 256 MB (Docker), sandboxed (QuickJS) |
| Network | Disabled by default |
| File system | /tmp only (Docker), none (QuickJS) |
| Output size | 1 MB max |

---

## 6 MCP Security

### 6.1 Server Trust Model

| Trust Level | Description | Permissions |
|---|---|---|
| **Trusted** | User-installed, local servers | All tools, auto-approve |
| **Semi-trusted** | Remote servers with auth | Tools approved per-use |
| **Untrusted** | New/unknown servers | Manual tool approval each time |

### 6.2 Tool Execution Approval

- First invocation of any MCP tool requires user approval.
- User can "always allow" specific tools from trusted servers.
- Sensitive operations (file write, network access) always prompt.
- Tool execution logged in `ToolExecutionLogs`.

---

## 7 Notification Privacy

### 7.1 Data Handling Policy

1. Notification content is processed **in-memory** by regex parsers.
2. Only structured transaction data (amount, merchant, type) is persisted.
3. Raw notification text stored only for verification purposes; auto-deleted after 30 days.
4. Notification listening is **opt-in** and requires explicit Android permission.
5. App allowlist controls which apps' notifications are processed.
6. Financial data is **excluded from Supabase sync by default**.

### 7.2 Permission Model

```dart
// Android Notification Listener permission
// Requires explicit user grant in Settings > Notification access
// Cannot be programmatically granted
// User can revoke at any time
```

---

## 8 Privacy Controls

### 8.1 User-Facing Privacy Settings

| Setting | Default | Description |
|---|---|---|
| Crash reporting | Off | Sentry opt-in |
| Analytics | Off | No analytics by default |
| Data retention | Forever | Auto-delete conversations after N days |
| Sync financial data | Off | Exclude from Supabase sync |
| Sync conversations | On | Include in Supabase sync |
| Notification capture | Off | Enable per-app notification listening |
| AI Gateway scope | Localhost | Bind to localhost only |

### 8.2 Data Export & Deletion

- **Export**: All user data as ZIP (Drift dump + files + settings JSON).
- **Selective delete**: Delete specific conversations, files, or date ranges.
- **Nuclear delete**: Wipe all data including Drift database, files, secure storage, and Supabase remote data.

---

## 9 Dependency Security

### 9.1 Audit Process

1. All dependencies reviewed for:
   - Maintainer reputation and activity.
   - Known vulnerabilities (pub.dev advisories).
   - Permission scope (especially native permissions).
2. Minimal dependency surface — prefer few, well-maintained packages.
3. Pin major versions in `pubspec.yaml`.
4. Automated vulnerability scanning via GitHub Dependabot.

### 9.2 Key Dependency Trust Assessment

| Package | Publisher | Trust Level | Notes |
|---|---|---|---|
| drift | Simon Binder | High | Flutter Favorite, 2300+ likes |
| moon_design | yolo.com | Medium | v1 maintained, v2 in progress |
| langchain_dart | David Miguel | Medium | Active, well-documented |
| llama_cpp_dart | netdur | Medium | Active, FFI bindings |
| mcp_dart | Community | Medium | Most mature Dart MCP SDK |
| shelf | Dart team | High | Official package |
| dart_openai | Mouaz M. Al-Shahmeh | Medium | 6.1.1, stable |
| flutter_secure_storage | Julian Steenbakker | High | Widely used, 2400+ likes |
| supabase_flutter | Supabase team | High | Official |
| notification_listener_service | Mostafa Morsy | Low | Small package, review source |

---

## 10 AGPL Compliance

### 10.1 License Obligations

- All source code publicly available.
- Modifications to Prism must be shared under AGPL.
- Network use (AI Gateway serving other apps) triggers AGPL copyleft.
- Third-party AGPL-compatible licenses accepted for dependencies.

### 10.2 Dependency License Compatibility

| License | Compatible | Packages |
|---|---|---|
| MIT | Yes | Most Flutter packages |
| BSD | Yes | Drift, shelf |
| Apache 2.0 | Yes | Flutter SDK |
| AGPL 3.0 | Yes | Prism itself |
| GPL 3.0 | Yes | Limited use |
| Proprietary | No | Must be avoided |
