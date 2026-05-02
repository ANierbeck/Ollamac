# Phase 4: Plugin Architecture Foundation - PLAN

## Overview
**Phase**: 4 of 4 (MCP Architecture Milestone)
**Name**: Plugin Architecture Foundation
**Duration**: 1-2 weeks
**Goal**: Establish plugin system for extensible backends
**Status**: Not Started

---

## Context

### Current State
- ChatBackend protocol defined and implemented (Phase 1)
- OllamaBackend and MCPBackend exist as concrete implementations
- Dependency Injection via SwiftUI Environment in place (Phase 2)
- Test infrastructure with mock backends complete (Phase 3)
- MCPClient protocol and HTTPMCPClient implementation exist

### Problem Statement
Current architecture has backends as static types. Need dynamic plugin system to:
- Allow users to add/remove backends at runtime
- Support MCPBackend as first plugin
- Enable future third-party plugins
- Provide configuration UI for plugin management

### Dependencies
- Phase 1 (ChatBackend Abstraction): COMPLETE
- Phase 2 (Dependency Injection): COMPLETE
- Phase 3 (Test Infrastructure): COMPLETE

---

## Requirements

| ID | Task | Effort | Priority | Dependencies | Status |
|----|------|--------|----------|--------------|--------|
| P-001 | Define Plugin Protocol | Small | P0 | Phase 1 | Not Started |
| P-002 | Create Plugin Registry | Medium | P0 | P-001 | Not Started |
| P-003 | Implement Plugin Discovery | Small | P0 | P-002 | Not Started |
| P-004 | Add Plugin Configuration UI | Medium | P0 | P-002 | Not Started |
| P-005 | Implement MCPBackend as plugin | Medium | P0 | P-001, Phase 1 | Not Started |

---

## Architecture Design

### Plugin Protocol Hierarchy
```
ChatBackend (existing)
    ^
ChatPlugin (new protocol)
    ^
OllamaPlugin (new)
MCPPlugin (new)
```

### Plugin Protocol Definition
```swift
protocol ChatPlugin: ChatBackend {
    // Plugin metadata
    static var pluginID: String { get }
    static var displayName: String { get }
    static var description: String { get }
    static var iconName: String { get }

    // Plugin lifecycle
    static func createInstance(config: PluginConfig) -> Self

    // Configuration
    var config: PluginConfig { get set }
}
```

### Plugin Configuration
```swift
struct PluginConfig: Codable, Sendable {
    var id: String
    var isEnabled: Bool
    var baseURL: URL
    var customName: String?
    var settings: [String: AnyCodable]
}
```

### Component Diagram
```
+----------------------------------------------------------+
|                        Ollamac App                         |
|  +------------------------------------------------------+ |
|  |                    Plugin System                       | |
|  |  +------------------+    +------------------+         | |
|  |  | PluginRegistry   |<---| PluginDiscovery  |         | |
|  |  |                 |    |                 |         | |
|  |  | - plugins: [Any] |    | - scan()        |         | |
|  |  | - register()     |    | - loadBundles() |         | |
|  |  | - unregister()   |    +----------------+         | |
|  |  | - getPlugin()    |             |                  | |
|  |  +----------------+             |                  | |
|  |           |                       |                  | |
|  |           v                       v                  | |
|  |  +--------------------------------------------+    | |
|  |  |                Loaded Plugins                 |    | |
|  |  |  +------------+  +------------+  +------------+  |    | |
|  |  |  | OllamaPlugin |  | MCPPlugin    |  | (Future)     |  |    | |
|  |  |  | (enabled)    |  | (enabled)    |  | Plugins      |  |    | |
|  |  |  +------------+  +------------+  +------------+  |    | |
|  |  +--------------------------------------------+    | |
|  +------------------------------------------------------+ |
|                          |                                     |
|                          v                                     |
|  +------------------------------------------------------+ |
|  |              ChatBackend Environment                   | |
|  |  (Provides current backend to ViewModels)               | |
|  +------------------------------------------------------+ |
+----------------------------------------------------------+
```

### Sequence: Backend Selection
```
User selects backend in Settings
    -> SettingsView updates PluginConfig
    -> PluginRegistry updates plugin state
    -> ChatBackendEnvironmentKey.defaultValue updated
    -> ViewModels receive new backend via @Environment
```

---

## Wave Breakdown

### Wave 1: Core Plugin Infrastructure
**wave: 1**
**Goal**: Define plugin protocol and create registry

| Task | ID | Effort | Owner | Dependencies | Status |
|------|-----|--------|-------|--------------|--------|
| Define ChatPlugin protocol extending ChatBackend | P-001 | 2h | - | Phase 1 | Not Started |
| Create PluginConfig struct for plugin settings | P-001 | 1h | - | P-001 | Not Started |
| Implement PluginRegistry singleton | P-002 | 4h | - | P-001 | Not Started |
| Add register/unregister/get plugin methods | P-002 | 2h | - | P-002 | Not Started |
| Create PluginError enum for error handling | P-002 | 1h | - | P-002 | Not Started |

**Deliverables**:
- `Ollamac/Plugins/ChatPlugin.swift`
- `Ollamac/Plugins/PluginConfig.swift`
- `Ollamac/Plugins/PluginRegistry.swift`
- `Ollamac/Plugins/PluginError.swift`

**Verification**:
- [ ] Unit tests for PluginRegistry (register, unregister, get)
- [ ] Plugin protocol compiles and works with mock

---

### Wave 2: Plugin Discovery & Loading
**wave: 2**
**Goal**: Discover and load plugins dynamically

| Task | ID | Effort | Owner | Dependencies | Status |
|------|-----|--------|-------|--------------|--------|
| Implement PluginDiscovery for bundle scanning | P-003 | 4h | - | P-002 | Not Started |
| Add plugin manifest parsing (Info.plist) | P-003 | 2h | - | P-003 | Not Started |
| Create plugin loading mechanism | P-003 | 3h | - | P-003 | Not Started |
| Add plugin initialization on app launch | P-003 | 2h | - | P-003 | Not Started |
| Create PluginManager for coordinated loading | P-003 | 2h | - | P-003 | Not Started |

**Deliverables**:
- `Ollamac/Plugins/PluginDiscovery.swift`
- `Ollamac/Plugins/PluginManager.swift`
- `Ollamac/Plugins/PluginManifest.swift`

**Verification**:
- [ ] Plugin discovery finds built-in plugins
- [ ] Plugins load successfully at app startup
- [ ] Invalid plugins handled gracefully

---

### Wave 3: MCPBackend as Plugin
**wave: 3**
**Goal**: Refactor MCPBackend to work as a plugin

| Task | ID | Effort | Owner | Dependencies | Status |
|------|-----|--------|-------|--------------|--------|
| Create MCPPlugin conforming to ChatPlugin | P-005 | 3h | - | P-001 | Not Started |
| Refactor MCPBackend to use PluginConfig | P-005 | 3h | - | P-005 | Not Started |
| Update HTTPMCPClient to accept plugin config | P-005 | 2h | - | P-005 | Not Started |
| Register MCPPlugin in PluginRegistry | P-005 | 1h | - | P-005, P-002 | Not Started |
| Add MCP plugin manifest | P-005 | 1h | - | P-005 | Not Started |

**Deliverables**:
- `Ollamac/Plugins/MCPPlugin.swift`
- Updated `Ollamac/ChatBackend/MCPBackend.swift`
- Updated `Ollamac/ChatBackend/Clients/HTTPMCPClient.swift`

**Verification**:
- [ ] MCPPlugin conforms to ChatPlugin
- [ ] MCPPlugin can be instantiated via PluginRegistry
- [ ] MCPBackend works with plugin configuration
- [ ] Existing MCPBackend tests pass

---

### Wave 4: Plugin Configuration UI
**wave: 4**
**Goal**: Allow users to manage plugins via UI

| Task | ID | Effort | Owner | Dependencies | Status |
|------|-----|--------|-------|--------------|--------|
| Create PluginSettingsView for plugin list | P-004 | 4h | - | P-002 | Not Started |
| Add enable/disable toggle for each plugin | P-004 | 2h | - | P-004 | Not Started |
| Implement plugin configuration editing | P-004 | 4h | - | P-004 | Not Started |
| Add plugin base URL configuration | P-004 | 2h | - | P-004 | Not Started |
| Integrate PluginSettingsView into SettingsView | P-004 | 2h | - | P-004 | Not Started |
| Add plugin state persistence | P-004 | 3h | - | P-004 | Not Started |

**Deliverables**:
- `Ollamac/Views/Settings/PluginSettingsView.swift`
- Updated `Ollamac/Views/Settings/SettingsView.swift`
- `Ollamac/Plugins/PluginConfigStore.swift` (UserDefaults persistence)

**Verification**:
- [ ] Users can see list of available plugins
- [ ] Users can enable/disable plugins
- [ ] Users can configure plugin base URLs
- [ ] Plugin state persists across app restarts
- [ ] UI responsive and accessible

---

## File Changes

### New Files
```
Ollamac/Plugins/
├── ChatPlugin.swift              # Plugin protocol definition
├── PluginConfig.swift            # Plugin configuration struct
├── PluginRegistry.swift          # Plugin registry singleton
├── PluginDiscovery.swift         # Plugin discovery mechanism
├── PluginManager.swift           # Plugin lifecycle management
├── PluginManifest.swift          # Plugin manifest parsing
├── PluginError.swift             # Error handling for plugins
├── PluginConfigStore.swift       # Persistence for plugin configs
├── MCPPlugin.swift               # MCP as a plugin
└── OllamaPlugin.swift            # Ollama as a plugin

Ollamac/Views/Settings/
└── PluginSettingsView.swift      # Plugin management UI

OllamacTests/Plugins/
├── MockPlugin.swift              # Mock for testing
├── PluginRegistryTests.swift     # Registry tests
├── PluginDiscoveryTests.swift    # Discovery tests
└── PluginConfigTests.swift        # Config tests

OllamacTests/Mocks/
└── MockChatPlugin.swift           # Mock ChatPlugin
```

### Modified Files
```
Ollamac/ChatBackend/MCPBackend.swift      # Refactor to use PluginConfig
Ollamac/ChatBackend/Clients/HTTPMCPClient.swift  # Accept plugin config
Ollamac/App/OllamacApp.swift               # Initialize PluginManager on launch
Ollamac/ChatBackend/ChatBackendEnvironment.swift  # Use PluginRegistry for backend
Ollamac/Views/Settings/SettingsView.swift  # Add PluginSettingsView
Ollamac.xcodeproj/project.pbxproj        # Add new files to project
```

---

## Success Measures

### Functional Requirements
- [ ] Plugin protocol defined and extendable
- [ ] PluginRegistry can register/unregister plugins
- [ ] Plugins discovered at application startup
- [ ] Users can enable/disable plugins in UI
- [ ] MCPBackend works as first plugin
- [ ] Plugin configuration persists

### Quality Requirements
- [ ] All new code has unit tests
- [ ] Plugin loading doesn't block main thread
- [ ] Invalid plugins fail gracefully
- [ ] No memory leaks in plugin lifecycle
- [ ] Thread-safe plugin access

### Performance Requirements
- [ ] Plugin discovery completes in < 500ms
- [ ] Plugin instantiation completes in < 100ms
- [ ] Backend switching is seamless

---

## Verification Criteria

### Unit Tests
| Test File | Coverage |
|-----------|----------|
| PluginRegistryTests | CRUD operations, error handling |
| PluginDiscoveryTests | Bundle scanning, manifest parsing |
| PluginConfigTests | Serialization, deserialization |
| MCPPluginTests | Plugin lifecycle, ChatBackend conformance |

### Integration Tests
| Test | Description |
|------|-------------|
| PluginLoadTest | All built-in plugins load at startup |
| BackendSwitchTest | Switching backends works correctly |
| ConfigPersistenceTest | Plugin configs persist across restarts |

### Manual Tests
| Test | Steps | Expected |
|------|-------|----------|
| Plugin List Display | Open Settings > Plugins | All plugins visible |
| Enable/Disable Plugin | Toggle plugin switch | Plugin state changes |
| Configure Plugin URL | Edit base URL field | New URL saved and used |
| Backend Switching | Switch from Ollama to MCP | Chat uses new backend |

---

## Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| Plugin loading blocks UI | High | Use async/await for all loading |
| Incompatible plugin versions | Medium | Add version checking to manifest |
| Memory leaks from plugins | Medium | Use weak references in registry |
| Security vulnerabilities | High | Sandbox plugins, validate manifests |
| Performance degradation | Low | Profile plugin loading, lazy load |

---

## Acceptance Criteria

- [ ] Plugin protocol defined and documented
- [ ] Plugin registry can register/unregister plugins
- [ ] Plugins discovered at application startup
- [ ] Users can enable/disable plugins in UI
- [ ] MCPBackend works as first plugin
- [ ] Plugin configuration persists across restarts
- [ ] All new code has corresponding unit tests
- [ ] Existing tests continue to pass
- [ ] Code review completed
- [ ] Documentation updated

---

## Estimates

| Component | Hours | Complexity |
|-----------|-------|------------|
| Plugin Protocol | 3 | Low |
| Plugin Registry | 8 | Medium |
| Plugin Discovery | 6 | Medium |
| MCPBackend Plugin | 8 | Medium |
| Plugin Configuration UI | 10 | Medium |
| Tests | 8 | Medium |
| **Total** | **43** | - |

---

## Notes

- Phase 4 is the final phase of the MCP Architecture Milestone
- Built-in backends (Ollama, MCP) will be registered as plugins
- Future third-party plugins can be added as .plugin bundles
- Plugin system should be extensible for non-backend plugins (future)

---
*Generated by Mistral Vibe*
*Co-Authored-By: Mistral Vibe <vibe@mistral.ai>*
*Phase: 4 - Plugin Architecture Foundation*
*Milestone: MCP Architecture Foundation*
