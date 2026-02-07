# 07 — Security Specification

> This document provides a comprehensive security design for Gemmie, covering encryption, credential management, code execution sandboxing, the permission model, data flow security, and threat mitigation strategies.

---

## Table of Contents

- [1. Security Principles](#1-security-principles)
- [2. Encryption at Rest](#2-encryption-at-rest)
- [3. Encryption in Transit](#3-encryption-in-transit)
- [4. Credential Management](#4-credential-management)
- [5. Code Execution Sandboxing](#5-code-execution-sandboxing)
- [6. Permission Model Specification](#6-permission-model-specification)
- [7. Data Flow Security](#7-data-flow-security)
- [8. Authentication & Authorization](#8-authentication--authorization)
- [9. Cloud Sync Security](#9-cloud-sync-security)
- [10. Threat Model](#10-threat-model)
- [11. Security Audit & Logging](#11-security-audit--logging)
- [12. Incident Response](#12-incident-response)
- [13. Security Checklist](#13-security-checklist)

---

## 1. Security Principles

| Principle | Implementation |
|-----------|---------------|
| **Defense in Depth** | Multiple layers: encryption, sandboxing, permissions, audit logging |
| **Least Privilege** | AI gets minimum access needed; default is Gated, not Open |
| **Zero Trust for AI** | Every AI access request is verified; no implicit trust |
| **Data Minimization** | Only necessary data sent to cloud APIs; no extra metadata |
| **Secure by Default** | All security features enabled by default; user opts out, not in |
| **Transparency** | All AI actions auditable; user can inspect every access |
| **Fail Secure** | On error, deny access rather than allow |

---

## 2. Encryption at Rest

### Overview

All user data stored on the device is encrypted using AES-256-GCM. The encryption key is managed by the platform's hardware-backed keystore.

### Key Hierarchy

```
┌──────────────────────────────────────────────────────┐
│                 Platform Keystore                     │
│        (Android Keystore / iOS Keychain)              │
│                                                      │
│  ┌──────────────────────────────────────────────────┐│
│  │         Master Key (KEK)                          ││
│  │   Generated on first launch                       ││
│  │   Hardware-backed (TEE/Secure Enclave)            ││
│  │   Never leaves the keystore                       ││
│  └───────────────────┬──────────────────────────────┘│
└──────────────────────┼───────────────────────────────┘
                       │ encrypts
                       ▼
          ┌───────────────────────────┐
          │    Data Encryption Key    │
          │         (DEK)             │
          │   AES-256 key             │
          │   Encrypted by KEK        │
          │   Stored in app storage   │
          └───────────┬───────────────┘
                      │ encrypts
                      ▼
     ┌────────────────────────────────────┐
     │          Isar Database             │
     │   Files, conversations, versions   │
     │   All fields encrypted with DEK    │
     └────────────────────────────────────┘
```

### Encryption Process

```
Write Path:
  plaintext → serialize to bytes → AES-256-GCM encrypt(DEK, nonce) → store ciphertext + nonce + tag

Read Path:
  load ciphertext + nonce + tag → AES-256-GCM decrypt(DEK, nonce, tag) → deserialize → plaintext
```

### AES-256-GCM Parameters

| Parameter | Value |
|-----------|-------|
| Algorithm | AES-256-GCM |
| Key size | 256 bits |
| Nonce size | 96 bits (12 bytes) |
| Tag size | 128 bits (16 bytes) |
| Nonce generation | Cryptographically secure random (per encryption) |

### What Is Encrypted

| Data | Encrypted | Key |
|------|-----------|-----|
| File content (Isar) | ✅ | DEK |
| File metadata (name, tags) | ✅ | DEK |
| Conversation messages | ✅ | DEK |
| Persona files | ✅ | DEK |
| Version history / diffs | ✅ | DEK |
| API keys / tokens | ✅ | Platform keystore directly |
| Audit logs | ✅ | DEK |
| App preferences (theme, etc.) | ❌ | Not sensitive |
| Model files (downloaded) | ❌ | Large binary, performance concern |
| Cache / temp files | ❌ | Ephemeral, auto-cleared |

### Key Lifecycle

| Event | Action |
|-------|--------|
| First launch | Generate KEK in platform keystore; generate DEK; encrypt DEK with KEK |
| App start | Load encrypted DEK; decrypt with KEK; hold DEK in memory |
| App background | Clear DEK from memory (configurable) |
| App foreground | Re-decrypt DEK from storage using KEK |
| Biometric unlock | Gate KEK access behind biometric authentication |
| Data wipe | Delete KEK (makes all encrypted data irrecoverable) |
| Key rotation | Generate new DEK; re-encrypt all data; replace encrypted DEK |

---

## 3. Encryption in Transit

| Requirement | Implementation |
|-------------|---------------|
| All API calls use HTTPS | TLS 1.3 minimum; TLS 1.2 with strong cipher suites as fallback |
| Certificate pinning | Pin CA certificates for primary providers (optional, configurable) |
| No plaintext HTTP | HTTP URLs are rejected at the network layer |
| WebSocket security | WSS only for streaming connections |
| Model downloads | HTTPS from HuggingFace; verify file integrity via SHA-256 checksum |

### Recommended TLS Cipher Suites

```
TLS_AES_256_GCM_SHA384
TLS_CHACHA20_POLY1305_SHA256
TLS_AES_128_GCM_SHA256
```

---

## 4. Credential Management

### Storage Strategy

| Credential | Storage Location | Access Method |
|-----------|-----------------|---------------|
| HuggingFace OAuth token | Platform keystore | `flutter_secure_storage` / `Keychain` / `Keystore` |
| OpenAI API key | Platform keystore | Secure storage plugin |
| Gemini API key | Platform keystore | Secure storage plugin |
| Claude API key | Platform keystore | Secure storage plugin |
| OpenRouter API key | Platform keystore | Secure storage plugin |
| Custom provider keys | Platform keystore | Secure storage plugin |
| DEK (data encryption key) | App storage (encrypted by KEK) | Decrypted at runtime |
| KEK (key encryption key) | Hardware keystore (TEE/SE) | Platform key management API |

### Credential Security Rules

| Rule | Description |
|------|-------------|
| Never log credentials | API keys, tokens never appear in log output at any level |
| Mask in UI | Keys displayed as `sk-●●●●●●●●●●7x2` (first 3 + last 3 chars) |
| Memory security | Clear credential strings from memory after use (where Dart allows) |
| Clipboard protection | If user copies a key, clear clipboard after 30 seconds |
| No hardcoding | Zero credentials in source code; not even for testing |
| Rotation support | UI for updating credentials; old key deleted immediately |
| Validation before save | Test credential validity via API call before storing |

### Platform-Specific Keystore

#### Android

```
AndroidKeyStore
├── StrongBox (if available) — hardware security module
├── TEE (Trusted Engine) — hardware-backed
└── Software — fallback (still encrypted)

Configuration:
  - setUserAuthenticationRequired(true)  — for biometric-gated keys
  - setKeySize(256)
  - setBlockModes(GCM)
  - setEncryptionPaddings(NoPadding)
```

#### iOS

```
Keychain Services
├── kSecAttrAccessibleWhenUnlockedThisDeviceOnly
├── kSecAttrAccessControl with biometricCurrentSet (for biometric)
└── kSecAttrSynchronizable(false) — no iCloud Keychain sync for secrets

Configuration:
  - Accessibility: afterFirstUnlockThisDeviceOnly
  - No iCloud backup of secrets
```

#### Web

```
Web Crypto API
├── SubtleCrypto for key generation
├── IndexedDB (encrypted) for key storage
└── Warning: less secure than native platforms

Mitigations:
  - Keys encrypted with user-derived key (PBKDF2)
  - Clear on browser session end (configurable)
  - Display security warning to user
```

---

## 5. Code Execution Sandboxing

### Sandbox Architecture

```
┌───── Host App (Gemmie) ─────────────────────────┐
│                                                  │
│  ┌──── Sandbox Boundary ──────────────────────┐  │
│  │                                            │  │
│  │  ┌── Isolated Process ──────────────────┐  │  │
│  │  │  Temp directory: /sandbox/{exec_id}/ │  │  │
│  │  │  No access to: app dir, user home,   │  │  │
│  │  │    system dirs, device APIs           │  │  │
│  │  │  Network: BLOCKED (default)           │  │  │
│  │  │  Filesystem: temp dir only            │  │  │
│  │  │  Memory: capped at limit              │  │  │
│  │  │  CPU time: capped at timeout          │  │  │
│  │  └──────────────────────────────────────┘  │  │
│  │                                            │  │
│  │  Communication: stdout/stderr pipe only    │  │
│  │  Cleanup: temp dir deleted after execution │  │
│  └────────────────────────────────────────────┘  │
│                                                  │
└──────────────────────────────────────────────────┘
```

### Sandbox Controls

| Control | Default | User-Configurable |
|---------|---------|-------------------|
| Filesystem access | Temp dir only | No — always sandboxed |
| Network access | Blocked | Yes — per-script toggle |
| System commands | Blocked | No — always blocked locally |
| Max execution time | 30 seconds | Yes — 1 to 300 seconds |
| Max memory | 256 MB | Yes — 64 to 1024 MB |
| Max output size | 1 MB stdout + 1 MB stderr | Yes |
| Child process creation | Blocked | No — always blocked locally |

### Platform-Specific Sandboxing

#### Android
```
- Use isolated process (android:isolatedProcess=true) for execution
- SELinux policy restricts filesystem access
- Memory limits via cgroups
- Network namespace isolation
```

#### iOS
```
- App Sandbox already provides isolation
- Use NSOperationQueue with separate queue
- WKWebView for JS execution (already sandboxed)
- Memory limits via os_proc_set_limit
```

#### Remote Execution
```
- Code runs in user's own infrastructure (Modal, Daytona, SSH)
- Gemmie's responsibility: encrypt code in transit, validate responses
- Sandbox security is the user's remote environment's responsibility
- Connection: HTTPS / WSS only
```

### Malicious Code Detection

| Threat | Detection | Mitigation |
|--------|-----------|------------|
| Infinite loop | Timeout monitoring | Kill after timeout |
| Memory bomb | Memory monitoring | Kill on limit exceeded |
| Fork bomb | Process creation blocked | Sandbox restriction |
| File system attack | Chroot-like isolation | No access outside temp |
| Network exfiltration | Network disabled by default | User must explicitly enable |
| Path traversal | Input sanitization + sandbox | Restricted filesystem view |

---

## 6. Permission Model Specification

### Formal Definition

```
Permission = (Subject, Object, Operation, Decision)

Subject:    "user" | "ai:{model-id}"
Object:     GemmieFile | GemmieFolder
Operation:  read | write | delete | execute
Decision:   allow | deny | askUser
```

### Evaluation Algorithm

```python
def evaluate(subject, object, operation):
    # Rule 1: User always has full access
    if subject == "user":
        return ALLOW

    # Rule 2: Get effective permission tier
    tier = get_effective_tier(object)

    # Rule 3: Locked = always deny for AI
    if tier == LOCKED:
        audit_log(subject, object, operation, DENIED)
        return DENY

    # Rule 4: Open = always allow for AI (but log)
    if tier == OPEN:
        audit_log(subject, object, operation, ALLOWED)
        return ALLOW

    # Rule 5: Gated = check grants
    if tier == GATED:
        grant = find_active_grant(subject, object, operation)
        if grant and not grant.expired:
            audit_log(subject, object, operation, ALLOWED)
            return ALLOW
        else:
            audit_log(subject, object, operation, ASK_USER)
            return ASK_USER

def get_effective_tier(object):
    # File-level override > folder-level > default
    if object.permissionTier is not None:
        return object.permissionTier
    return get_effective_tier(object.parent)
```

### Permission Inheritance

```
Root Folder (gated by default)
├── Documents/ (gated — inherits)
│   ├── spec.md (gated — inherits)
│   └── secret.md (LOCKED — override)
├── Agent/ (gated)
│   ├── soul.md (gated — inherits)
│   └── temp_notes.md (OPEN — override)
├── Scripts/ (gated)
│   └── analyzer.py (gated — inherits)
└── Trash/ (LOCKED — system)
    └── * (LOCKED — inherits, no AI access to trash)
```

### Grant Expiration

| Scope | Expiration |
|-------|------------|
| This time only | Immediately after the granted operation completes |
| This session | On conversation end OR app restart (whichever comes first) |
| Always | Never (until user explicitly revokes) |

### Emergency Lockdown

If the user suspects unauthorized AI access:

1. **Settings > Permissions > Emergency Lockdown** button
2. All grants immediately revoked
3. All files set to Gated (minimum)
4. All pending AI operations cancelled
5. Audit log snapshot exported
6. Confirmation shown to user

---

## 7. Data Flow Security

### Chat Data Flow

```
User types message
    │
    ▼
Message stored encrypted in local DB
    │
    ├── Local Model Path:
    │   Message → plaintext to LiteRT engine (on-device, no network)
    │   Response → stored encrypted in local DB
    │   ✅ Data never leaves device
    │
    └── Cloud API Path:
        Message → TLS-encrypted → Provider API
        Conversation history included in API request
        ⚠️  Data leaves device (user explicitly chose cloud provider)
        Response → stored encrypted in local DB
```

### File Access Data Flow

```
AI requests file access
    │
    ▼
Permission Engine evaluates (see §6)
    │
    ├── DENIED → AI informed, operation blocked, audit logged
    │
    ├── ASK_USER → Permission dialog shown
    │   └── User decides → grant or deny
    │
    └── ALLOWED →
        File content decrypted in memory
        Content provided to AI context
        Content cleared from memory after use
        Audit entry created
```

### Sensitive Data Boundaries

```
┌─── Never Leaves Device ────────────────────────────┐
│  • Encryption keys (KEK, DEK)                      │
│  • Platform keystore contents                       │
│  • API keys (never sent to other providers)         │
│  • Audit logs                                       │
│  • Permission grants                                │
│  • File version history                             │
│  • Local model weights                              │
└────────────────────────────────────────────────────┘

┌─── Leaves Device (Encrypted + User-Consented) ─────┐
│  • Chat messages → to selected cloud AI provider    │
│  • File content → only if AI tool reads it for API  │
│  • Sync data → to cloud sync provider (E2E enc.)    │
└────────────────────────────────────────────────────┘

┌─── Never Collected ────────────────────────────────┐
│  • Usage analytics (unless opted in)                │
│  • Device identifiers                               │
│  • Location data                                    │
│  • Contact lists                                    │
│  • Call logs                                        │
│  • Browsing history                                 │
└────────────────────────────────────────────────────┘
```

---

## 8. Authentication & Authorization

### Authentication Methods

| Method | Use Case | Implementation |
|--------|----------|---------------|
| HuggingFace OAuth | Model downloads (gated models) | AppAuth library, PKCE flow |
| API Key | Cloud AI providers | Stored in keystore, sent in headers |
| Biometric | App unlock, sensitive operations | Platform biometric API |
| Cloud Sync Account | Optional sync | TBD (Firebase Auth / Supabase Auth) |
| PIN / Password | Fallback for biometric | Hashed with PBKDF2, never stored plaintext |

### OAuth 2.0 (HuggingFace) Security

| Measure | Implementation |
|---------|---------------|
| PKCE | Required (code_challenge_method: S256) |
| State parameter | Random nonce, verified on callback |
| Token storage | Access token in keystore; refresh token in keystore |
| Token refresh | Automatic before expiry |
| Token revocation | On user logout from HuggingFace |
| Redirect URI validation | Exact match only (no wildcards) |

---

## 9. Cloud Sync Security

### End-to-End Encryption for Sync

```
User Data → Encrypt(DEK_sync, data) → Upload ciphertext to cloud

DEK_sync derived from:
  - User passphrase (entered once, not stored on server)
  - PBKDF2 with 600,000 iterations
  - Salt stored alongside encrypted data (not secret)

Server sees: ciphertext + salt + nonce + tag
Server CANNOT see: plaintext data (no access to passphrase or derived key)
```

### Key Derivation for Sync

```
passphrase → PBKDF2(passphrase, salt, iterations=600000, keyLength=256) → DEK_sync
```

| Parameter | Value |
|-----------|-------|
| KDF | PBKDF2-HMAC-SHA256 |
| Iterations | 600,000 (OWASP recommendation) |
| Salt | 128-bit cryptographically random (per-user) |
| Key length | 256 bits |

### Recovery Key

On sync setup, a 24-word recovery key is generated (BIP39 mnemonic):

```
1. User sets passphrase for sync
2. DEK_sync derived from passphrase
3. Recovery key generated (random 256-bit entropy → 24 words)
4. DEK_sync encrypted with recovery key → stored on server as backup
5. User MUST write down recovery key (shown once!)
6. If passphrase forgotten → recovery key → decrypt DEK_sync backup → re-derive
```

---

## 10. Threat Model

### STRIDE Analysis

| Threat | Category | Risk | Mitigation |
|--------|----------|------|------------|
| AI accesses locked files | Tampering | High | Permission engine enforced at data layer; no bypass possible from AI context |
| API key stolen from device | Info Disclosure | High | Hardware keystore; biometric gate; app-level encryption |
| Malicious code execution | Elevation of Privilege | High | Sandbox isolation; no filesystem/network access; timeout |
| Man-in-the-middle on API calls | Info Disclosure | Medium | TLS 1.3; optional certificate pinning |
| Local DB extracted from device | Info Disclosure | Medium | AES-256-GCM encryption; key in hardware keystore |
| AI manipulates persona to bypass rules | Tampering | Medium | Soul file immutable constraints; permission-gated changes; user review |
| Cloud sync data intercepted | Info Disclosure | Medium | E2E encryption; server never sees plaintext |
| Prompt injection via file content | Spoofing | Medium | Warn user when file content used as AI context; sanitize where possible |
| Denial of service (OOM from model) | Denial of Service | Low | Memory monitoring; graceful unload; user notification |
| User tricked into granting permissions | Social Engineering | Low | Clear permission dialogs; show exact file/operation; audit log |

### Attack Surface

| Surface | Exposure | Controls |
|---------|----------|----------|
| Cloud AI API endpoints | Internet | TLS, API key auth, rate limiting |
| HuggingFace download | Internet | TLS, OAuth, file hash verification |
| Local model inference | App process | Memory isolation, OOM handling |
| Code execution sandbox | App process | Process isolation, resource limits |
| File storage (Isar DB) | Device storage | AES-256-GCM encryption |
| Cloud sync storage | Cloud | E2E encryption (client-side) |
| User input (chat) | User interface | Input validation, prompt injection awareness |

---

## 11. Security Audit & Logging

### Audit Log Entries

Every security-relevant event is logged:

| Event Type | Logged Fields | Retention |
|-----------|---------------|-----------|
| Permission request | file, operation, requester, decision, timestamp | 90 days |
| Permission grant/revoke | file, operation, scope, timestamp | 90 days |
| API key access | provider, operation (create/update/delete), timestamp | 90 days |
| File read by AI | file, model, conversation, timestamp | 90 days |
| File write by AI | file, model, conversation, diff summary, timestamp | 90 days |
| Code execution | language, environment, success/fail, timestamp | 90 days |
| Login/auth events | provider, success/fail, timestamp | 90 days |
| Emergency lockdown | trigger, timestamp | Permanent |
| Data export | scope, timestamp | Permanent |
| Data deletion | scope, timestamp | Permanent |

### Audit Log Security

- Audit logs are encrypted at rest (same DEK as other data)
- Audit logs are append-only (modification / deletion by AI is impossible — Locked tier)
- Audit logs can be exported by user
- 90-day auto-cleanup to manage storage (configurable)

### Audit Dashboard (Settings > Permissions)

```
┌──────────────────────────────────────┐
│  📊 Security Audit                   │
├──────────────────────────────────────┤
│                                      │
│  Last 7 Days                         │
│  ├── AI file reads:        23        │
│  ├── AI file writes:        8        │
│  ├── Permission requests:  12        │
│  ├── Grants given:          9        │
│  ├── Requests denied:       3        │
│  └── Code executions:       5        │
│                                      │
│  [View Full Log →]                   │
│  [Export Audit Log 📤]               │
│  [🔴 Emergency Lockdown]            │
│                                      │
└──────────────────────────────────────┘
```

---

## 12. Incident Response

### User Reports Suspicious Activity

```
1. User taps "Emergency Lockdown" OR reports issue
2. Immediately:
   a. Revoke ALL active permission grants
   b. Set all files to Gated (minimum)
   c. Cancel all pending AI operations
   d. Suspend code executions
3. Export audit log snapshot
4. Show user summary:
   "Last 24h: 35 AI accesses, 12 file writes, 5 code executions"
5. User reviews and decides next action:
   a. Revoke specific API keys
   b. Delete specific conversations
   c. Change persona files
   d. Contact support
6. Lockdown persists until user manually unlocks
```

---

## 13. Security Checklist

### Pre-Release Security Checklist

- [ ] All stored data encrypted with AES-256-GCM — verified by DB inspection
- [ ] API keys stored in platform keystore — verified by static analysis
- [ ] No credentials in source code — verified by secret scanning (truffleHog, gitleaks)
- [ ] No credentials in log output — verified by log audit at DEBUG level
- [ ] TLS 1.3+ for all network calls — verified by network proxy inspection
- [ ] Code sandboxing prevents filesystem escape — verified by penetration test
- [ ] Code sandboxing prevents network access (when disabled) — verified by test
- [ ] Permission engine blocks AI access to Locked files — verified by automated test
- [ ] Permission engine requires approval for Gated files — verified by automated test
- [ ] Key rotation mechanism works correctly — verified by integration test
- [ ] Data wipe leaves zero recoverable data — verified by forensic analysis
- [ ] Biometric authentication gates keystore access — verified by manual test
- [ ] OAuth PKCE flow implemented correctly — verified by auth test
- [ ] Dependency audit: no known CVEs — verified by `dart pub audit`
- [ ] Dependency audit: no data-collecting libraries — verified by manual review
- [ ] Cloud sync E2E encryption verified — server-side contains only ciphertext
- [ ] Audit log captures all security events — verified by coverage test
