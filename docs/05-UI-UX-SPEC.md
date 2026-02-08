# Prism — UI/UX Specification (Moon Design)

> Built with **moon_design** (1.1.0) — Moon Design System for Flutter. Themable, extensible widgets with squircle borders and token-based styling. Uses `MaterialApp` with `MoonTheme` as a `ThemeExtension`.

## 1 Design System

### 1.1 Theme Configuration

```dart
final lightTokens = MoonTokens.light.copyWith(
  colors: MoonColors.light.copyWith(
    piccolo: const Color(0xFF6366F1),   // Primary brand — indigo
    textPrimary: Colors.grey.shade900,
  ),
  typography: MoonTypography.typography.copyWith(
    heading: MoonTypography.typography.heading.apply(
      fontFamily: "Inter",
      fontWeightDelta: -1,
    ),
  ),
);

final darkTokens = MoonTokens.dark.copyWith(
  colors: MoonColors.dark.copyWith(
    piccolo: const Color(0xFF818CF8),   // Primary brand — indigo lighter
  ),
);

final lightTheme = ThemeData.light().copyWith(
  extensions: <ThemeExtension<dynamic>>[MoonTheme(tokens: lightTokens)],
);

final darkTheme = ThemeData.dark().copyWith(
  extensions: <ThemeExtension<dynamic>>[MoonTheme(tokens: darkTokens)],
);

// In MaterialApp:
MaterialApp(
  title: 'Prism',
  theme: lightTheme,
  darkTheme: darkTheme,
  themeMode: ThemeMode.dark,      // Default dark
)
```

### 1.2 Color Palette (MoonColors)

| Token | Purpose | Light | Dark |
|---|---|---|---|
| `piccolo` | Primary/accent | Indigo 500 | Indigo 400 |
| `goten` | Surface/card | White | Grey 900 |
| `gohan` | Background | Grey 50 | Grey 950 |
| `bulma` | Text primary | Grey 900 | Grey 50 |
| `trunks` | Text secondary | Grey 500 | Grey 400 |
| `beerus` | Border/divider | Grey 200 | Grey 800 |
| `chichi` | Error/destructive | Red 500 | Red 400 |
| `roshi` | Success | Green 500 | Green 400 |
| `krillin` | Warning | Amber 500 | Amber 400 |
| `whis` | Info | Blue 500 | Blue 400 |

Access: `context.moonColors!.piccolo`, `context.moonTypography!.heading.text14`

### 1.3 Typography

- Headings: Inter (via `MoonTypography.typography.heading`)
- Body: System default (via `MoonTypography.typography.body`)
- Monospace: JetBrains Mono for code display
- Scale: `text12`, `text14`, `text16`, `text18`, `text20`, `text24`

### 1.4 Icon Set

- **Primary**: `MoonIcons` — from `moon_icons` package
- Naming: `MoonIcons.{category}_{name}_{size}_{weight}`
- Example: `MoonIcons.chat_chat_24_light`, `MoonIcons.generic_settings_24_regular`
- **Fallback**: Material Icons where MoonIcons lacks coverage

### 1.5 Shape Language

- Moon Design uses **squircle** borders (`MoonSquircleBorder`) by default
- Consistent rounded corners via `MoonSizes` tokens
- All containers/cards/buttons use squircle rounding

---

## 2 App Shell & Navigation

### 2.1 Navigation Philosophy

The app has a **3+1 navigation model**:
- **Chat** — Core AI assistant (primary)
- **Brain** — Second Brain / knowledge base
- **Apps** — Secondary features: Tasks, Finance, Files, Tools, Gateway
- **Settings** — Configuration (pinned to bottom)

This keeps the bottom bar to **4 items** on mobile and provides a clean sidebar on desktop.

### 2.2 Root Layout (Desktop / Tablet > 800px)

```
+-----------------------------------------------------------+
|  AppBar:  Prism logo  -----------  [Search]  [Cmd-K]      |
+----------+------------------------------------------------+
| Sidebar  |                                                |
|          |              Main Content                      |
| Chat     |     (Router outlet — current screen)           |
| Brain    |                                                |
|          |                                                |
| -- Apps -|                                                |
|  Tasks   |                                                |
|  Finance |                                                |
|  Files   |                                                |
|  Tools   |                                                |
|  Gateway |                                                |
|          |                                                |
| -------- |                                                |
| Settings |                                                |
+----------+------------------------------------------------+
| Status: sync | model: gemma-3 | gateway: idle            |
+-----------------------------------------------------------+
```

**Implementation:**
- `Scaffold` (Material) — outer structure
- Custom sidebar using `MoonMenuItem` list in a `Drawer`-style column
- Sidebar background: `context.moonColors!.gohan`
- Selected item highlight: `context.moonColors!.piccolo` tint

### 2.3 Root Layout (Mobile < 800px)

```
+----------------------------+
| AppBar: Prism  [Search]    |
+----------------------------+
|                            |
|     Main Content           |
|     (full width)           |
|                            |
+----------------------------+
| BottomNav (4 items only)   |
| Chat | Brain | Apps | Cfg  |
+----------------------------+
```

**Implementation:**
- Material `BottomNavigationBar` or `NavigationBar` (Moon Design does not include one)
- 4 items: Chat, Brain, Apps, Settings
- Apps tab opens a sub-navigation grid using `MoonMenuItem`

### 2.4 Apps Hub Screen

When "Apps" is selected, show a grid of available mini-apps:

```dart
GridView(
  children: [
    _AppTile(icon: MoonIcons.generic_check_alternative_24_light, label: 'Tasks'),
    _AppTile(icon: MoonIcons.shop_wallet_24_light, label: 'Finance'),
    _AppTile(icon: MoonIcons.files_folder_open_24_light, label: 'Files'),
    _AppTile(icon: MoonIcons.software_settings_24_light, label: 'Tools'),
    _AppTile(icon: MoonIcons.generic_lightning_24_light, label: 'Gateway'),
  ],
)
```

Each tile is a `MoonBaseControl` with icon + label, navigates to the sub-screen.

---

## 3 Screen: Chat (Primary)

### 3.1 Conversation List (Sidebar / Drawer)

**Components:**
- `ListView` with `MoonMenuItem` — each conversation
  - `leading`: `MoonAvatar` with persona initial
  - `label`: conversation title
  - `trailing`: `MoonTag` (unread count) or pin icon
- `MoonTextInput` — search/filter at top
- `MoonFilledButton` — "New Chat"
- `MoonPopover` — context menu (Rename, Pin, Archive, Delete)
- `MoonDropdown` — sort options

### 3.2 Chat View (Main Area)

**Components:**
- Custom `ChatBubble` widget — styled with `MoonSquircleBorder`
  - AI messages: background `context.moonColors!.gohan`, left-aligned
  - User messages: background `context.moonColors!.piccolo` tint, right-aligned
- `MoonAccordion` — expandable tool call results
  - Header: "Tool: web_search" with `MoonTag`
  - Body: JSON input/output
- `MoonLinearProgress` — token generation progress
- `MoonCircularLoader` — streaming indicator
- `MoonToast` — copy/error notifications
- `MoonAvatar` — user/AI avatars beside messages

### 3.3 Chat Input Bar

**Components:**
- `MoonTextArea` — multi-line message input
- `MoonFilledButton` — send
- `MoonButton.icon` — attach file, stop generation
- `MoonDropdown` — model/provider selector
- `MoonPopover` — persona quick-switch
- `MoonChip` — attached file indicators with close button

### 3.4 Branching UI

- `MoonSegmentedControl` or button row — branch navigation
- `MoonPopover` — branch preview on hover
- Context menu — "Fork from here" option

---

## 4 Screen: Second Brain (PARA)

### 4.1 PARA Dashboard

**Components:**
- `MoonTabBar` with `MoonTab` — top-level PARA tabs (Projects, Areas, Resources, Archives)
- Card container with squircle + `goten` bg — item cards in grid
  - Title, description, `MoonTag` (status), emoji icon
  - `MoonLinearProgress` for project completion
- `MoonFilledButton` — "Add New"
- `MoonTextInput` — filter/search
- `MoonDropdown` — sort by

### 4.2 Note Editor

- `AppFlowy Editor` (embedded) — block-based note editing
- `MoonChip` — tags
- `MoonDropdown` — PARA category assignment
- `MoonPopover` — bi-directional link picker
- `MoonAlert` — AI suggestion

---

## 5 Screen: Tasks (App)

### 5.1 Task List View

**Components:**
- `MoonTable` — sortable task table
  - Columns: `MoonCheckbox`, Title, Priority (`MoonTag`), Status (`MoonTag`), Project, Due Date
  - `MoonTableRow` — selectable rows
- `MoonTabBar` — view switcher: List | Kanban | Calendar
- `MoonDropdown` — filter by status/priority/project
- `MoonFilledButton` — "Add Task"

### 5.2 Kanban View

- Column headers: `MoonTag` with count
- Task cards: Container with `goten` bg, `MoonSquircleBorder`
  - `MoonTag` for priority, emoji for project
- `MoonChip` — tags on cards

### 5.3 Task Detail

- `MoonModal` or `showMoonModalBottomSheet` — detail panel
- `MoonTextInput` — title
- `MoonTextArea` — description
- `MoonDropdown` — status, priority
- `MoonCheckbox` — subtasks
- `MoonAccordion` — AI suggestions section

---

## 6 Screen: Finance (App)

### 6.1 Finance Dashboard

**Components:**
- Summary cards (Container + squircle) — Income, Expenses, Balance, Savings Rate
- `MoonLinearProgress` — budget usage per category
- `MoonTabBar` — Transactions | Budget | Insights

### 6.2 Transaction List

- Custom `ListView` — transaction rows
  - `MoonTag` for category
  - Color-coded amounts (roshi for income, chichi for expense)
- `MoonDropdown` — filter by category/date
- `MoonFilledButton` — "Add Entry"
- `MoonAlert` — AI spending insight

### 6.3 Budget View

- Cards per category with `MoonLinearProgress`
- Percentage labels with roshi/chichi coloring

---

## 7 Screen: Files (App)

**Components:**
- `MoonMenuItem` list — file tree with indentation
  - Folder/file icons from `MoonIcons`
  - `MoonTag` for file type
- `MoonTextInput` — search
- File preview pane — rendered markdown/code
- `MoonLinearProgress` — storage usage indicator
- `MoonFilledButton` / `MoonOutlinedButton` — New File, Import

---

## 8 Screen: Tools & MCP (App)

### 8.1 MCP Tools Dashboard

**Components:**
- `MoonTable` — registered tools table (name, description, provider, call count)
- `MoonAccordion` — tool detail expand (parameters, recent calls)
- `MoonSwitch` — enable/disable individual tools
- `MoonTag` — provider labels (builtin, mcp-server, custom)

### 8.2 MCP Server Management

- `MoonMenuItem` list — connected servers with status
- `MoonAlert` — connection errors
- `MoonFilledButton` — "Add Server"
- `MoonModal` — server configuration form
  - `MoonTextInput` — name, command, args
  - `MoonSwitch` — auto-connect on startup

---

## 9 Screen: AI Gateway (App)

**Components:**
- `MoonSwitch` — Gateway on/off toggle
- `MoonTextInput` — port number, bind address
- Status cards: requests served, active connections, uptime
- `MoonTable` — API key table (key, created, last used, revoke button)
- `MoonLinearProgress` — rate limit usage
- `MoonAccordion` — recent request log

---

## 10 Screen: Settings

### 10.1 Settings Layout

- `MoonMenuItem` list — settings categories (sidebar or full list on mobile)
- Categories: General, AI Providers, Personas, Appearance, Security, About

### 10.2 General Settings

- `MoonSwitch` — startup behaviors
- `MoonDropdown` — default model, language
- `MoonTextInput` — custom paths

### 10.3 AI Provider Settings

- `MoonAccordion` per provider — expandable config
  - `MoonTextInput` — API key, base URL
  - `MoonDropdown` — default model selection
  - `MoonSwitch` — enabled/disabled
  - `MoonFilledButton` — "Test Connection"
- `MoonAlert` — connection status

### 10.4 Appearance Settings

- `MoonSegmentedControl` — Theme: Light | Dark | System
- `MoonDropdown` — accent color preset
- `MoonSwitch` — compact mode, animations

### 10.5 Security Settings

- `MoonTextInput` (password) — set app password
- `MoonSwitch` — biometric unlock
- `MoonFilledButton` — export/import encryption keys
- `MoonAlert` — security status

---

## 11 Responsive Breakpoints

| Breakpoint | Layout | Nav |
|---|---|---|
| < 600px | Single column | Bottom bar (4 items) |
| 600–1200px | Content + optional panel | Rail or small sidebar |
| > 1200px | Sidebar + resizable content | Full sidebar |

---

## 12 Accessibility

- All `MoonButton`, `MoonTextInput`, `MoonMenuItem` are keyboard-navigable
- `semanticLabel` on all `MoonAvatar`, `MoonSwitch`, `MoonCheckbox`
- Focus effects via `MoonFocusEffect` (built-in)
- `MoonTooltip` for icon-only buttons
- Min touch target: 48x48 on mobile

---

## 13 Animation & Micro-interactions

- `MoonAccordion` — smooth expand/collapse with configurable duration
- `MoonSwitch` — toggle animation
- `MoonTabBar` — indicator slide animation
- `MoonAlert` — enter/exit fade
- `MoonCircularLoader` — continuous rotation
- `MoonToast` — slide-in from top/bottom
- Page transitions: Material `SharedAxisTransition` or `FadeThrough`

---

## 14 Component Mapping Summary

| Concept | Moon Design Widget |
|---|---|
| Primary button | `MoonFilledButton` |
| Secondary button | `MoonOutlinedButton` |
| Text button | `MoonTextButton` |
| Icon button | `MoonButton.icon` |
| Text field | `MoonTextInput` / `MoonFormTextInput` |
| Text area | `MoonTextArea` |
| Checkbox | `MoonCheckbox` |
| Radio | `MoonRadio` |
| Switch/Toggle | `MoonSwitch` |
| Dropdown/Select | `MoonDropdown` |
| Tab bar | `MoonTabBar` + `MoonTab` |
| Pill tabs | `MoonTabBar` + `MoonPillTab` |
| Segments | `MoonSegmentedControl` |
| Alert/Banner | `MoonAlert` / `MoonAlert.filled` |
| Toast | `MoonToast` |
| Tooltip | `MoonTooltip` |
| Popover | `MoonPopover` |
| Modal | `MoonModal` / `showMoonModal` |
| Bottom sheet | `showMoonModalBottomSheet` |
| Drawer | `MoonDrawer` |
| Avatar | `MoonAvatar` |
| Tag/Badge | `MoonTag` |
| Chip | `MoonChip` |
| Menu item | `MoonMenuItem` |
| Table | `MoonTable` |
| Accordion | `MoonAccordion` |
| Progress bar | `MoonLinearProgress` |
| Spinner/Loader | `MoonCircularLoader` |
| Carousel | `MoonCarousel` |
| Breadcrumb | `MoonBreadcrumb` |
| Dot indicator | `MoonDotIndicator` |
