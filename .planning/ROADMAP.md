# MCP Architecture Milestone - Roadmap

## Overview
**Milestone Name**: MCP Architecture Foundation  
**Objective**: Adapt architecture to support MCP, introduce tests, and establish plugin architecture fundamentals.  
**Duration**: ~6 weeks  
**Status**: Not started  

---

## Current State
- **Version**: 3.0.3
- **Status**: Functional Ollama client
- **Architecture**: Tightly coupled MVVM with SwiftUI
- **Test Coverage**: 0% (no test target, no tests)
- **Plugin Support**: None
- **MCP Support**: Not supported

---

## Phase Structure

### Phase 1: ChatBackend Abstraction
**Duration**: 1-2 weeks  
**Goal**: Create protocol abstraction for chat backends

| Task | ID | Effort | Priority | Dependencies | Status |
|------|-----|--------|----------|--------------|--------|
| Create ChatBackend protocol | A-001 | Medium | P0 | None | ⬜ |
| Implement OllamaBackend (refactor existing) | A-001 | Medium | P0 | A-001 | ⬜ |
| Create MCPBackend skeleton | A-005 | Medium | P0 | A-001 | ⬜ |

**Acceptance Criteria**:
- [ ] ChatBackend protocol defined with all required methods
- [ ] OllamaBackend implements ChatBackend
- [ ] MCPBackend skeleton implements ChatBackend
- [ ] Protocol documented with clear contract

**Outcome**: Foundation for multi-backend support established

---

### Phase 2: Dependency Injection
**Duration**: 1-2 weeks  
**Goal**: Inject dependencies instead of direct instantiation

| Task | ID | Effort | Priority | Dependencies | Status |
|------|-----|--------|----------|--------------|--------|
| Implement DI in ChatView | A-002 | Medium | P0 | Phase 1 | ⬜ |
| Implement DI in MessageViewModel | A-003 | Medium | P0 | Phase 1 | ⬜ |
| Extract business logic from views | A-004 | Medium | P0 | A-002, A-003 | ⬜ |
| Update ChatView to use injected backend | A-002 | Small | P0 | A-002 | ⬜ |
| Update MessageViewModel to use injected backend | A-003 | Small | P0 | A-003 | ⬜ |

**Acceptance Criteria**:
- [ ] ChatView accepts ChatBackend via environment/constructor
- [ ] MessageViewModel accepts ChatBackend via environment/constructor
- [ ] No direct OllamaKit instantiation in views
- [ ] Business logic separated from UI concerns

**Outcome**: Architecture is decoupled and ready for MCP integration

---

### Phase 3: Test Infrastructure
**Duration**: 1-2 weeks  
**Goal**: Establish foundation for automated testing

| Task | ID | Effort | Priority | Dependencies | Status |
|------|-----|--------|----------|--------------|--------|
| Add unit test target to Xcode project | T-001 | Small | P0 | None | ⬜ |
| Create Mock ChatBackend | T-002 | Medium | P0 | Phase 1 | ⬜ |
| Add ChatViewModel unit tests | T-004 | Medium | P0 | T-001, T-002 | ⬜ |
| Add MessageViewModel unit tests | T-005 | Medium | P0 | T-001, T-002 | ⬜ |
| Setup GitHub Actions CI pipeline | T-006 | Medium | P0 | T-001 | ⬜ |

**Acceptance Criteria**:
- [ ] Unit test target compiles and runs successfully
- [ ] Mock ChatBackend can simulate all operations
- [ ] ViewModel tests pass with mock backend
- [ ] CI pipeline runs tests on every push/PR

**Outcome**: Test foundation established, CI pipeline active

---

### Phase 4: Plugin Architecture Foundation
**Duration**: 1-2 weeks  
**Goal**: Establish plugin system for extensible backends

| Task | ID | Effort | Priority | Dependencies | Status |
|------|-----|--------|----------|--------------|--------|
| Define Plugin Protocol | P-001 | Small | P0 | Phase 1 | ⬜ |
| Create Plugin Registry | P-002 | Medium | P0 | P-001 | ⬜ |
| Implement Plugin Discovery | P-003 | Small | P0 | P-002 | ⬜ |
| Add Plugin Configuration UI | P-004 | Medium | P0 | P-002 | ⬜ |
| Implement MCPBackend as plugin | P-005 | Medium | P0 | P-001, Phase 1 | ⬜ |

**Acceptance Criteria**:
- [ ] Plugin protocol defined and documented
- [ ] Plugin registry can register/unregister plugins
- [ ] Plugins discovered at application startup
- [ ] Users can enable/disable plugins in UI
- [ ] MCPBackend works as first plugin

**Outcome**: Plugin architecture foundation established, MCP integrated

---

## Phase Summary

| Phase | Duration | Goal | Key Deliverables |
|-------|----------|------|-------------------|
| 1 | 1-2 weeks | ChatBackend Abstraction | Protocol + OllamaBackend + MCPBackend skeleton |
| 2 | 1-2 weeks | Dependency Injection | DI in ChatView + MessageViewModel |
| 3 | 1-2 weeks | Test Infrastructure | Test target + mocks + CI |
| 4 | 1-2 weeks | Plugin Architecture | Plugin system + MCPBackend |

**Total**: 4 phases, ~6 weeks, 16 requirements

---

## Milestone Success Criteria

- [ ] ChatBackend protocol defined and implemented
- [ ] Dependency injection working throughout
- [ ] Unit test target exists and tests pass
- [ ] CI pipeline active and running tests
- [ ] Plugin architecture foundation established
- [ ] MCPBackend integrated as first plugin
- [ ] Architecture documented
- [ ] No direct OllamaKit instantiation in views

---

## Dependencies

### Phase Dependencies
```
Phase 1 (ChatBackend Abstraction)
    ↓
Phase 2 (Dependency Injection) → depends on Phase 1
    ↓
Phase 3 (Test Infrastructure) → depends on Phase 1, 2
    ↓
Phase 4 (Plugin Architecture) → depends on Phase 1, 2
```

**Note**: Phase 3 (Tests) and Phase 4 (Plugin) can run in parallel after Phase 2

### External Dependencies
- Xcode 15+ (Swift 5.9+)
- macOS 14.0+ (for building)
- GitHub (for CI/CD)
- Ollama server (for integration testing)

---

## Key Design Decisions

### ChatBackend Protocol
```swift
protocol ChatBackend: Sendable {
    // Chat operations
    func sendMessage(prompt: String, chat: Chat, options: ChatOptions) async throws -> AsyncThrowingStream<ChatChunk, Error>
    
    // Model operations
    func listModels() async throws -> [Model]
    func getModelInfo(model: String) async throws -> ModelInfo
    
    // Connection
    func checkConnection() async throws -> Bool
    
    // Server info
    var baseURL: URL { get }
    var serverType: String { get }  // "Ollama", "MCP", etc.
}
```

### Plugin Protocol
```swift
protocol ChatPlugin: ChatBackend {
    // Plugin metadata
    static var pluginID: String { get }
    static var displayName: String { get }
    static var description: String { get }
    
    // Plugin lifecycle
    static func createInstance(config: PluginConfig) -> Self
}
```

### Architecture Diagram
```
┌─────────────────────────────────────────────────────┐
│                    Views (SwiftUI)                   │
│  ChatView ┬───────────────────────────────────────┐ │
│           │                                       │ │
│           ▼                                       ▼ │
│  ┌─────────────────┐             ┌─────────────┐ │
│  │ ChatViewModel   │◄────────────│  ChatBackend │ │
│  │                 │             │  (Protocol) │ │
│  │  @Environment   │             └──────┬──────┘ │
│  └────────┬────────┤                        │       │
│           │        │                        │       │
│           ▼        ▼                        ▼       │
│  ┌─────────────────┐         ┌─────────────────┐  │
│  │ MessageViewModel│         │ PluginRegistry  │  │
│  │                 │         │                 │  │
│  │  @Environment   │         └─────────────────┘  │
│  └─────────────────┘                   │          │
│                                      │          │
│          ┌───────────────────────────┴─────────┐ │
│          │                 Plugin Backends        │ │
│          ▼                                           │ │
│  ┌─────────────────┐    ┌─────────────────┐       │ │
│  │ OllamaBackend   │    │ MCPBackend       │       │ │
│  │ (refactored)    │    │ (new plugin)    │       │ │
│  └─────────────────┘    └─────────────────┘       │
└─────────────────────────────────────────────────────┘
```

---

## Release Plan

| Version | Phase | Date | Notes |
|---------|-------|------|-------|
| 3.0.3 | Current | Released | Baseline |
| 3.1.0 | Phase 1-2 | TBD | Architecture + DI |
| 3.2.0 | Phase 3 | TBD | Testing |
| 3.3.0 | Phase 4 | TBD | Plugin Architecture + MCP |

---

## Tracking
- **Project Board**: GitHub Projects (recommended)
- **Issues**: GitHub Issues with milestone label
- **PRs**: GitHub Pull Requests with milestone tracking
- **Progress**: Track in STATE.md

---

## Next Steps
1. Review and approve this roadmap
2. Run `/gsd-plan-phase 1` to start Phase 1 (ChatBackend Abstraction)
3. Or run `/gsd-plan-milestone-gaps` to identify additional gaps

---
*Roadmap for MCP Architecture Milestone*
*Single milestone with 4 phases, ~6 weeks total*
*Focus: Architecture adaptation, test introduction, plugin foundation*
