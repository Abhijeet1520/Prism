# Session Tasks Tracker

> Auto-maintained by development sessions. Each task links to its deliverables.

---

## Session: 2026-02-09

### Phase 1: Session Infrastructure & Mock Backend
| # | Task | Status | Notes |
|---|------|--------|-------|
| 1.1 | Create session_logs folder structure | ✅ Done | tasks.md, findings.md, approach.md, scratchpad |
| 1.2 | Create .gitignore for project | ✅ Done | Flutter + Dart + IDE + build artifacts |
| 1.3 | Redesign mock data with backend service layer | ✅ Done | MockDataService singleton, 3 new JSON files |
| 1.4 | Add daily summary mock data (todos, weather, events, financials) | ✅ Done | daily_summary.json, models.json, app_settings.json |

### Phase 2: UI Overhaul
| # | Task | Status | Notes |
|---|------|--------|-------|
| 2.1 | Splash/loading screen (Gallery-inspired) | ✅ Done | 4-shape animated logo, crossfade transition |
| 2.2 | Soul orb home screen (floating circle with daily digest) | ✅ Done | Organic orb + daily cards, voice input |
| 2.3 | Theme system with multiple options | ✅ Done | 7 presets, AMOLED, font scale, ThemeProvider |
| 2.4 | Settings screen redesign (sections, splitters) | ✅ Done | 7 sections, theme controls, voice, data |
| 2.5 | Navigation perfection | ✅ Done | 5-tab (Home/Chat/Brain/Apps/Settings) |
| 2.6 | main.dart rewrite with ThemeProvider | ✅ Done | Splash→AppShell flow, dynamic accent |

### Phase 3: Initial Version with Local Model
| # | Task | Status | Notes |
|---|------|--------|-------|
| 3.1 | Create initial_version folder | ✅ Done | README, features, local model, deploy guides |
| 3.2 | AI service abstraction | ✅ Done | AIService, MockAIController, AIModel |
| 3.3 | Tool registry + 6 composable tools | ✅ Done | Tasks, finance, notes, calendar, docs, weather |
| 3.4 | Feature registry + FeatureGate widget | ✅ Done | Status banners, planned feature placeholders |
| 3.5 | Local model setup guide | ✅ Done | llama_sdk, Ollama, cloud fallback |
| 3.6 | Local device testing guide | ✅ Done | USB debugging, flutter run, hot reload |
| 3.7 | Play Store deployment guide | ✅ Done | Signing, AAB, store listing, review |
| 3.3 | Tool system with composable tools | ⬜ Pending | |
| 3.4 | Feature availability tracker (MD file) | ⬜ Pending | |
| 3.5 | AI feature understanding system | ⬜ Pending | |

### Phase 4: Deployment
| # | Task | Status | Notes |
|---|------|--------|-------|
| 4.1 | Local device testing guide | ⬜ Pending | |
| 4.2 | Play Store deployment guide | ⬜ Pending | |

---

## File Size Policy
- No Dart file exceeds 600 lines
- If approaching limit → split into logical sub-files

---

## Session: Feature Batch (Tasks 2-11)

### Task 2: Fix Model Catalog UI
| # | Task | Status | Notes |
|---|------|--------|-------|
| 2.1 | Fix JSON key mismatch in loadModelCatalog | ✅ Done | `data['local_models']` → `data['models']` |
| 2.2 | Fix field name mappings | ✅ Done | snake_case → camelCase (`fileName`, `sizeBytes`, etc.) |
| 2.3 | Add supportsTools to ModelCatalogEntry | ✅ Done | Parsed from JSON, passed to ModelConfig |

### Task 3: AI Chat + Markdown + Token Info
| # | Task | Status | Notes |
|---|------|--------|-------|
| 3.1 | Add flutter_markdown to chat_screen | ✅ Done | MarkdownBody for assistant messages |
| 3.2 | Add token/timing tracking in _sendMessage | ✅ Done | Stopwatch + per-chunk token counting |
| 3.3 | Rewrite _MessageBubble with full styling | ✅ Done | Code blocks, tables, blockquotes, headings |
| 3.4 | Add model/token/time footer on messages | ✅ Done | Shows model name, ~tokens, response time |

### Task 4: Cloud Provider API Key Links
| # | Task | Status | Notes |
|---|------|--------|-------|
| 4.1 | Add url_launcher to cloud_provider_tile | ✅ Done | "Get API Key" + "API Docs" buttons |
| 4.2 | Show available models as chips | ✅ Done | Listed from provider config |
| 4.3 | Fix _providerTypeFromId | ✅ Done | Handle openrouter, anthropic, mistral |

### Task 5: Voice Input
| # | Task | Status | Notes |
|---|------|--------|-------|
| 5.1 | Wire up speech_to_text on home_screen | ✅ Done | _initSpeech, _toggleListening |

### Task 6: PARA Demo Data
| # | Task | Status | Notes |
|---|------|--------|-------|
| 6.1 | Expand notes 8→16 with categories | ✅ Done | 4 project, 4 area, 5 resource, 3 archive |
| 6.2 | Add dependsOn arrays | ✅ Done | Linked items for dependency relationships |
| 6.3 | Add file content fields | ✅ Done | Markdown, CSV, shell, Python, JSON content |

### Task 7: Finance Transaction Actions
| # | Task | Status | Notes |
|---|------|--------|-------|
| 7.1 | Add category-specific icons | ✅ Done | 10 categories with distinct icons |
| 7.2 | Add transaction tap → bottom sheet | ✅ Done | Header, category change chips, action buttons |

### Task 8: File Editor with Viewer
| # | Task | Status | Notes |
|---|------|--------|-------|
| 8.1 | Add content field to _FileNode | ✅ Done | Parsed from JSON |
| 8.2 | Add file viewer state/methods | ✅ Done | _viewingFile, _openFileViewer, _closeFileViewer |
| 8.3 | Build _buildFileViewer method | ✅ Done | Breadcrumb header, Markdown/.txt rendering, edit/save toggle |
| 8.4 | Add _editController disposal | ✅ Done | dispose() override added |

### Task 9: Fix Back Navigation
| # | Task | Status | Notes |
|---|------|--------|-------|
| 9.1 | Fix _indexOfLocation with startsWith | ✅ Done | Sub-routes now match correct tab |
| 9.2 | Fix _onBackPressed location check | ✅ Done | Handles empty string edge case |

### Task 10: Voice-First Home Input
| # | Task | Status | Notes |
|---|------|--------|-------|
| 10.1 | Redesign input section like ux_preview | ✅ Done | Centered mic, toggle text input |

### Task 11: Update Session Logs
| # | Task | Status | Notes |
|---|------|--------|-------|
| 11.1 | Update tasks.md | ✅ Done | All tasks documented |
| 11.2 | Update features.md | ✅ Done | Status upgrades |

---

## Session: Bug Fix Batch (15 issues)

### Bug Fixes
| # | Task | Status | Notes |
|---|------|--------|-------|
| B1 | Budget page null type cast crash | ✅ Done | `(b['limit'] as num?)?.toDouble() ?? 0.0` — safe null cast |
| B2 | Transactions: use dropdown instead of bottom sheet | ✅ Done | Inline expandable panel below tapped item with category chips, duplicate, delete |
| B3 | Transaction changes not visible | ✅ Done | Added `updateTransactionCategory`, `deleteTransaction`, `duplicateTransaction` to DB; wired up actual DB operations |
| B4 | Files showing old content on reopen | ✅ Done | Made `_FileNode.content` mutable; save button persists edit back to node in-memory |
| B5 | Model selector not scrollable | ✅ Done | Added `isScrollControlled: true`, `maxHeight` constraint, wrapped models in `Flexible > ListView` |
| B6 | Stop message not working | ✅ Done | Added `if (!mounted \|\| !_isStreaming) break` in `await for` loop; stop button now sets `_isStreaming = false` |
| B7 | OpenRouter API error | ✅ Done | Added `apiKey` to `toJson()`/`fromJson()` for persistence; kept full model ID for OpenRouter; added required `HTTP-Referer`/`X-Title` headers; fixed `messages.map` to use explicit `<String, dynamic>{}` |
| B8 | Tools switches too big & overlapping | ✅ Done | `Transform.scale(scale: 0.6)` on all switches; disabled unimplemented tools with opacity + "coming soon" tag; `Calculator` and `Finance Manager` marked as implemented |
| B9 | MCP servers same switch fix | ✅ Done | Same `Transform.scale(scale: 0.6)` + local state tracking for auto-connect toggles |
| B10 | Kanban items not draggable | ✅ Done | Added `LongPressDraggable<TaskEntry>` + `DragTarget<TaskEntry>`; drag between To Do/Done columns toggles completion |
| B11 | Settings tabs not discoverable | ✅ Done | Replaced horizontal chip tabs with `DropdownButton<int>` selector showing all 8 sections with icons |
| B12 | Home→Tasks goes to apps hub | ✅ Done | Added `initialTab` param to `AppsHubScreen`; router reads `?tab=N` query param; home screen passes `tab=0` for tasks, `tab=1` for finance |
| B13 | Back button closes app | ✅ Done | Added `PopScope` to `AppsHubScreen._buildSubScreen` so back goes to apps grid first; existing shell `PopScope` already handles home→exit flow |
| B14 | Update session logs | ✅ Done | This table |
| B15 | Validate with build | ✅ Done | All files pass `get_errors` lint — zero analysis errors |

---

## Session: Feature Batch (OpenRouter, Model Picker, Settings, Chat Actions)

### Research
| # | Task | Status | Notes |
|---|------|--------|-------|
| R1 | Research OpenRouter API docs | ✅ Done | Standard OpenAI-compatible API at `https://openrouter.ai/api/v1`, SSE streaming, `/api/v1/models` for listing |
| R2 | Study maid repo implementation | ✅ Done | Uses same `llama_sdk: ^0.0.5`, key param `greedy: true`, isolate-based streaming, tree-based chat with branching |
| R3 | Evaluate OpenRouter Flutter packages | ✅ Done | No separate package needed — Dio handles OpenAI-compatible API perfectly |

### OpenRouter & Cloud Provider Fixes
| # | Task | Status | Notes |
|---|------|--------|-------|
| F1 | Fix OpenRouter model ID stripping | ✅ Done | Strips `openrouter/` prefix properly; keeps full model ID like `google/gemma-2-9b-it` |
| F2 | Fix OpenRouter SSE parsing | ✅ Done | Skip `:` comment lines, empty data lines, handle `[DONE]` sentinel, inline error detection |
| F3 | Add non-200 error handling | ✅ Done | `validateStatus: (s) => s != null && s < 500`; read error body; parse JSON error messages; handle 402 insufficient credits |
| F4 | Add model fetching from provider API | ✅ Done | `fetchProviderModels()` hits `/api/v1/models`; parses pricing, detects free models, sorts free-first |
| F5 | Add user model selection & persistence | ✅ Done | `updateSelectedModels()`, `_loadSavedSelectedModels()`, `_saveSavedSelectedModels()` via SharedPreferences |
| F6 | OpenRouter model selection UI (Browse dialog) | ✅ Done | `_BrowseModelsButton` + `_ModelSelectionDialog` with search, free filter, select all/clear, pricing display |

### Model Picker Rewrite
| # | Task | Status | Notes |
|---|------|--------|-------|
| M1 | Group models by provider | ✅ Done | `_ModelPickerSheet` groups by `ProviderType` with icons/labels (Demo→Local→Ollama→Cloud→Gemini→Custom) |
| M2 | Add search bar to model picker | ✅ Done | Filters by name, id, or provider name |
| M3 | Add "AI Providers" settings link | ✅ Done | Button navigates to `/settings` via `context.go()` |

### Settings Page Rewrite
| # | Task | Status | Notes |
|---|------|--------|-------|
| S1 | Replace dropdown with accordion layout | ✅ Done | Collapsible cards with animated chevron rotation, accent border when expanded |
| S2 | Move AI Providers to top (index 0) | ✅ Done | Open by default; other sections closed |
| S3 | Wide layout side nav | ✅ Done | Checkmarks for expanded sections, supports multiple expanded simultaneously |

### Chat Message Actions
| # | Task | Status | Notes |
|---|------|--------|-------|
| C1 | Add uuid to _DisplayMessage | ✅ Done | Auto-generated `Uuid().v4()`, mutable `content` for editing |
| C2 | Add DB methods (delete, update, getLastMessages) | ✅ Done | `deleteMessage(uuid)`, `updateMessageContent(uuid, content)`, `getLastMessages(conversationId, limit)` |
| C3 | Rewrite _MessageBubble as StatefulWidget | ✅ Done | Tap to show/hide actions; Copy, Edit (user), Resend (assistant), Delete buttons |
| C4 | Add _ActionChip widget | ✅ Done | Subtle chip with icon + label, colored per action type |
| C5 | Add message action handlers | ✅ Done | `_editMessage()` fills input + removes msg chain; `_deleteMessage()` removes from list + DB; `_resendMessage()` re-generates via `_sendMessageWithoutUserAdd()` |

### Local Model Fix
| # | Task | Status | Notes |
|---|------|--------|-------|
| L1 | Add `greedy: true` to local model loading | ✅ Done | Matches maid repo's `LlamaController.fromMap()` params for reliable output |

### Validation
| # | Task | Status | Notes |
|---|------|--------|-------|
| V1 | Run dart analyze on all modified files | ✅ Done | All 6 files clean — zero errors. Pre-existing issues in tool_registry.dart and home_screen.dart unrelated |
