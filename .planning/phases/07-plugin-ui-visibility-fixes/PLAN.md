# Phase 7: Plugin UI Visibility Fixes - PLAN

## Overview
**Phase**: 7 of 7 (MCP Architecture Milestone)
**Name**: Plugin UI Visibility Fixes
**Duration**: 1-2 days
**Goal**: Fix the issue where PluginSettingsView tab is not visible in Settings, and ensure plugins are properly registered and displayed.
**Status**: Not Started

---

## Context

### Current State
- Phase 6 (Swift 6 Concurrency Fixes) completed successfully
- App builds and runs without concurrency errors
- SettingsView has three tabs: General, Plugins, Experimental
- User reports only seeing General and Experimental tabs - Plugins tab is missing
- macOS Settings dialog uses `Settings { SettingsView() }` modifier (system settings)

### Problem Statement
After Phase 6 completion, users cannot see the Plugins tab in Settings. This prevents them from:
1. Viewing available plugins (Ollama, MCP)
2. Enabling/disabling plugins
3. Configuring plugin base URLs (e.g., MCP server URL)

### Root Cause Analysis

**Primary Issue: Race Condition in Plugin Registration**
```
Current Flow:
App Start → OllamacApp.init → AppView.body → .task { @MainActor in
    await PluginManager.shared.initialize()
    await registerBuiltInPlugins()  // Registers Ollama + MCP ASYNCHRONOUSLY
}

User Action: Open Settings → SettingsView → TabView → PluginSettingsView
                                → loadPlugins() → PluginManager.shared.getAllPlugins()
                                → Returns EMPTY ARRAY (plugins not registered yet)
```

**Secondary Issue: macOS Settings Dialog Behavior**
- `Settings { SettingsView() }` creates a system settings dialog
- TabView in macOS Settings may hide empty tabs or render differently
- PluginSettingsView shows ProgressView or empty list when no plugins loaded

**Third Issue: PluginManager Shared State**
- PluginManager.shared is `@MainActor public static let shared`
- Accessing from non-MainActor context requires proper isolation
- PluginRegistry.shared.getAllPlugins() may fail if called from wrong context

### Additional Findings

**1. App Startup Sequence (OllamacApp.swift)**
```swift
init() {
    // ... property initialization ...
    
    // Initialize plugins - must be done after all properties are initialized
    Task { @MainActor in
        await PluginManager.shared.initialize()
        await registerBuiltInPlugins()  // <-- ASYNC, happens AFTER init
        
        chatViewModel.create(model: Defaults[.defaultModel])
        if let activeChat = chatViewModel.selectedChats.first {
            chatViewModel.activeChat = activeChat
            messageViewModel.load(of: activeChat)
        }
    }
}

var body: some Scene {
    WindowGroup {
        AppView()
            .task { @MainActor in  // <-- DUPLICATE TASK!
                await PluginManager.shared.initialize()
                await registerBuiltInPlugins()
                chatViewModel.create(model: Defaults[.defaultModel])
                if let activeChat = chatViewModel.selectedChats.first {
                    chatViewModel.activeChat = activeChat
                    messageViewModel.load(of: activeChat)
                }
            }
    }
    Settings {
        SettingsView()  // <-- SettingsView loaded BEFORE plugins registered
    }
}
```

**Critical Finding**: There are TWO `.task` modifiers doing the same plugin registration!
- One in `init()` 
- One in `AppView().task`

**2. PluginSettingsView Loading Logic**
```swift
private func loadPlugins() {
    Task {
        await MainActor.run { isLoading = true }
        
        do {
            let allPlugins = pluginManager.getAllPlugins()  // Returns [] if called before registration
            let allConfigs = configStore.loadConfigs()
            
            await MainActor.run {
                plugins = allPlugins  // Empty!
                configs = allConfigs
                isLoading = false
            }
        } catch {
            // ...
        }
    }
}
```

If `getAllPlugins()` returns empty, the list is empty and TabView may not show the tab properly.

**3. SettingsView TabView Structure**
```swift
TabView {
    GeneralView()
        .tabItem { Label("General", systemImage: "gearshape") }
    
    PluginSettingsView()
        .tabItem { Label("Plugins", systemImage: "puzzlepiece") }
    
    ExperimentalView()
        .tabItem { Label("Experimental", systemImage: "testtube.2") }
}
```

In macOS Settings, TabView should show all tabs regardless of content.

### Dependencies
- Phase 6 (Swift 6 Concurrency Fixes): COMPLETE
- PluginManager: @MainActor isolation
- SettingsView: TabView-based navigation

---

## Requirements

| ID | Task | Effort | Priority | Dependencies | Status | Wave |
|----|------|--------|----------|--------------|--------|-------|
| P-001 | Remove duplicate plugin registration tasks from OllamacApp | 0.5h | P0 | None | Not Started | 1 |
| P-002 | Move plugin registration to synchronous app init (before Settings) | 1h | P0 | P-001 | Not Started | 1 |
| P-003 | Ensure PluginManager registers built-in plugins at initialization | 1h | P0 | P-002 | Not Started | 1 |
| P-004 | Fix PluginSettingsView empty state with clear "No plugins" message | 1h | P0 | P-002 | Not Started | 1 |
| P-005 | Add loading state to PluginSettingsView | 0.5h | P0 | P-004 | Not Started | 1 |
| P-006 | Verify Settings tab visibility in macOS Settings dialog | 0.5h | P0 | P-001 | Not Started | 1 |
| P-007 | Test plugin enable/disable functionality | 0.5h | P1 | P-003 | Not Started | 2 |
| P-008 | Test plugin URL configuration and persistence | 0.5h | P1 | P-003 | Not Started | 2 |
| P-009 | Verify all three tabs visible in Settings | 0.5h | P1 | P-006 | Not Started | 2 |

---

## Phase Goals
1. **P-001**: Remove duplicate `.task` modifiers causing redundant plugin registration
2. **P-002/P-003**: Register plugins synchronously before any views (including Settings) are loaded
3. **P-004/P-005**: Ensure PluginSettingsView handles empty/loading states with clear UI feedback
4. **P-006**: Verify Plugins tab appears correctly in macOS Settings dialog
5. **P-007-P-009**: Validate complete plugin configuration workflow

---

## Architecture Design

### Problem: Duplicate Plugin Registration
```swift
// CURRENT (WRONG) - Two identical tasks:
init() {
    // ...
    Task { @MainActor in
        await PluginManager.shared.initialize()
        await registerBuiltInPlugins()  // TASK 1
    }
}

var body: some Scene {
    WindowGroup {
        AppView()
            .task { @MainActor in
                await PluginManager.shared.initialize()
                await registerBuiltInPlugins()  // TASK 2 - DUPLICATE!
            }
    }
}
```

### Solution: Single Synchronous Registration
```swift
// FIXED - Register plugins in init BEFORE any views:
init() {
    // ... other initialization ...
    
    // Register built-in plugins SYNCHRONOUSLY
    let registry = PluginRegistry.shared
    let ollamaConfig = PluginConfig.ollama
    let ollamaPlugin = OllamaPlugin(config: ollamaConfig)
    registry.registerPlugin(ollamaPlugin, config: ollamaConfig)
    
    let mcpConfig = PluginConfig.mcp
    let mcpPlugin = MCPPlugin(config: mcpConfig)
    registry.registerPlugin(mcpPlugin, config: mcpConfig)
    
    // ... rest of init ...
}

var body: some Scene {
    WindowGroup {
        AppView()
            .task { @MainActor in
                // Only async operations that don't affect Settings
                chatViewModel.create(model: Defaults[.defaultModel])
                if let activeChat = chatViewModel.selectedChats.first {
                    chatViewModel.activeChat = activeChat
                    messageViewModel.load(of: activeChat)
                }
            }
    }
    Settings {
        SettingsView()  // Now SettingsView has access to registered plugins
    }
}
```

### PluginSettingsView Improvements

**Current Issues:**
- Shows ProgressView while loading
- Shows nothing if plugins array is empty
- No error handling for failed registration

**Improved Flow:**
```swift
private var pluginList: some View {
    Group {
        if isLoading {
            ProgressView("Loading plugins...")
                .padding()
        } else if plugins.isEmpty {
            VStack {
                Image(systemName: "puzzlepiece")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)
                    .padding()
                Text("No plugins available")
                    .foregroundColor(.secondary)
                Text("Plugins will appear here once registered")
                    .font(.caption)
                    .foregroundColor(.tertiary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            // Normal list of plugins
            List {
                ForEach(configs, id: \.id) { config in
                    // ...
                }
            }
        }
    }
}
```

---

## Wave-Based Task Breakdown

### Wave 1: Remove Duplicates & Synchronous Registration (P-001, P-002, P-003)
**wave: 1**
**Duration**: 2-3 hours
**Goal**: Fix plugin registration timing and remove duplicates

| Task | ID | File | Effort | Change |
|------|-----|------|--------|--------|
| Remove duplicate task in init | P-001.1 | `OllamacApp.swift:50-58` | 0.5h | Remove Task from init, keep only in body |
| Remove duplicate task in body | P-001.2 | `OllamacApp.swift:85-92` | 0.5h | Remove plugin registration from body task, keep only chat init |
| Register plugins synchronously | P-002.1 | `OllamacApp.swift:50-60` | 1h | Add synchronous plugin registration before SettingsView |
| Verify PluginManager state | P-003.1 | Manual test | 0.5h | Confirm plugins registered before any view loads |

**Acceptance**: 
- Only one plugin registration call exists
- Plugins are registered before SettingsView is created
- Build succeeds without errors

---

### Wave 2: PluginSettingsView UI Improvements (P-004, P-005)
**wave: 2**
**Duration**: 1-2 hours
**Goal**: Improve user experience for empty/loading states

| Task | ID | File | Effort | Change |
|------|-----|------|--------|--------|
| Add empty state view | P-004.1 | `PluginSettingsView.swift:66-90` | 0.5h | Replace empty list with informative message |
| Improve loading message | P-005.1 | `PluginSettingsView.swift:55-60` | 0.5h | Add "Loading plugins..." text to ProgressView |
| Add error state | P-005.2 | `PluginSettingsView.swift:70-75` | 0.5h | Show error message if plugin loading fails |
| Test in Settings dialog | P-006.1 | Manual test | 0.5h | Open Settings and verify Plugins tab visible |

**Acceptance**:
- PluginSettingsView shows loading, empty, or list state appropriately
- Plugins tab is always visible in Settings
- No blank or broken UI states

---

### Wave 3: Testing & Validation (P-007, P-008, P-009)
**wave: 3**
**Duration**: 1-2 hours
**Goal**: Validate complete plugin configuration workflow

| Task | ID | File | Effort | Change |
|------|-----|------|--------|--------|
| Test plugin list visibility | P-007.1 | Manual test | 0.5h | Verify Ollama and MCP plugins listed |
| Test enable/disable toggle | P-007.2 | Manual test | 0.5h | Toggle each plugin, verify state persists |
| Test URL configuration | P-008.1 | Manual test | 0.5h | Edit MCP URL, save, verify in registry |
| Test URL persistence | P-008.2 | Manual test | 0.5h | Restart app, verify URL saved |
| Verify all tabs visible | P-009.1 | Manual test | 0.5h | Confirm 3 tabs in Settings |

**Acceptance**:
- All plugins visible and configurable
- URL changes persist across app restarts
- All Settings tabs work correctly

---

## File Changes

### Modified Files
```
Ollamac/App/OllamacApp.swift
├── P-001.1: Remove duplicate Task in init
├── P-001.2: Remove duplicate plugin registration from body task
├── P-002.1: Add synchronous plugin registration in init
└── P-006.1: Keep only chat-related operations in body task

Ollamac/ChatBackend/Plugins/PluginManager.swift
└── P-003.1: Verify getAllPlugins() returns built-in plugins

Ollamac/Views/Settings/PluginSettingsView.swift
├── P-004.1: Add empty state view with icon and message
├── P-005.1: Improve loading state message
└── P-005.2: Add error state handling
```

---

## Success Measures

### Functional Requirements
- [ ] Plugins tab visible in Settings dialog
- [ ] Ollama and MCP plugins listed by default
- [ ] Plugin enable/disable toggle works correctly
- [ ] Plugin URL configuration UI is functional
- [ ] URL changes persist across app restarts
- [ ] No duplicate plugin registration

### Quality Requirements
- [ ] No race conditions in plugin registration
- [ ] Settings UI responsive and clear
- [ ] Error states handled gracefully
- [ ] No compiler warnings introduced
- [ ] Code remains maintainable

### Performance Requirements
- [ ] App startup time not significantly increased (< 1s impact)
- [ ] Settings opens instantly
- [ ] Plugin list loads in < 100ms

---

## Verification Criteria

| Test | Action | Expected Result |
|------|--------|-----------------|
| VT-01 | Open Settings dialog (⌘+,) | 3 tabs visible: General, Plugins, Experimental |
| VT-02 | Click Plugins tab | Ollama and MCP plugins listed with current URLs |
| VT-03 | Toggle MCP plugin off | MCP plugin disabled, UI reflects change |
| VT-04 | Toggle MCP plugin on | MCP plugin re-enabled |
| VT-05 | Click Edit on MCP plugin | URL field editable |
| VT-06 | Change URL to `http://localhost:3000`, Save | URL updated in list |
| VT-07 | Quit and restart app | MCP URL persists as `http://localhost:3000` |
| VT-08 | Check Xcode console | No warnings or errors |

---

## Research Summary

### macOS Settings Dialog Behavior
- `Settings { SettingsView() }` creates a system-level settings dialog
- Available via menu bar: App Name > Settings... (⌘+,)
- TabView works normally but empty tabs may appear differently
- No special handling needed for TabView in Settings context

### Plugin Registration Timeline
```
Time 0ms:  App starts
Time 10ms: OllamacApp.init begins
Time 20ms: Properties initialized
Time 30ms: Duplicate Task 1 starts (in init)
Time 40ms: init completes
Time 50ms: AppView body created
Time 60ms: Duplicate Task 2 starts (in body.task)
Time 70ms: User opens Settings
Time 80ms: SettingsView.created
Time 90ms: PluginSettingsView.loadPlugins() called
Time 100ms: getAllPlugins() returns [] (Task 1 not complete)
Time 150ms: Task 1 completes, plugins registered
Time 200ms: Task 2 completes, plugins re-registered (DUPLICATE!)
```

**Solution**: Remove both tasks, register synchronously in init at ~25ms.

### PluginManager Analysis
```swift
@MainActor public static let shared = PluginManager()

private init(registry: PluginRegistry, discovery: PluginDiscovery) {
    self.registry = registry
    self.discovery = discovery
}
```
- PluginManager is @MainActor isolated
- Must be accessed from MainActor context
- SettingsView is part of macOS Settings, which runs on MainActor
- No isolation issues expected

---

## Execution Flow

```
Phase 7 Start
    │
    ▼
┌─────────────────────────────────────┐
│ Wave 1: Registration Fixes          │
│ ┌─────────────────────────────────┐ │
│ │ P-001: Remove duplicate tasks   │ │
│ │ P-002: Sync plugin registration │ │
│ │ P-003: Verify PluginManager     │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────┐
│ Wave 2: UI Improvements            │
│ ┌─────────────────────────────────┐ │
│ │ P-004: Empty state view        │ │
│ │ P-005: Loading/error states     │ │
│ │ P-006: Tab visibility test     │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────┐
│ Wave 3: Testing & Validation        │
│ ┌─────────────────────────────────┐ │
│ │ P-007: Plugin list test        │ │
│ │ P-008: URL config test         │ │
│ │ P-009: Full Settings test      │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
    │
    ▼
Full Build & Manual Testing
    │
    ▼
Phase 7 Complete → Ready for user verification
```

---

## Acceptance Criteria

- [ ] Plugins tab appears in macOS Settings dialog (⌘+,)
- [ ] Both Ollama and MCP plugins are listed by default
- [ ] Plugin enable/disable toggle works correctly
- [ ] Plugin URL configuration UI is functional
- [ ] URL changes persist across app restarts
- [ ] All existing functionality remains intact
- [ ] No duplicate plugin registration
- [ ] No new compiler warnings or errors
- [ ] App builds successfully
- [ ] No race conditions detected

---

## Estimates

| Component | Hours | Complexity |
|-----------|-------|------------|
| Registration fixes | 2 | Low |
| UI improvements | 1.5 | Low |
| Testing and validation | 2 | Low |
| **Total** | **5.5** | - |

---

## Notes

- This phase addresses a critical UX blocker for MCP server configuration
- Root cause is duplicate async plugin registration creating race condition
- Fix is straightforward: synchronous registration in app init
- Secondary issue: PluginSettingsView needs better empty state handling
- Total estimated effort: ~5-6 hours
- Priority: HIGH (blocks MCP functionality)

---
*Generated by Mistral Vibe*
*Co-Authored-By: Mistral Vibe <vibe@mistral.ai>*
*Phase: 7 - Plugin UI Visibility Fixes*
*Milestone: MCP Architecture Foundation*
*Updated with additional findings from live execution*
