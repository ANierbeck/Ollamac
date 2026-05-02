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

### Phase 8: Performance Optimization
**Duration**: 1-2 weeks  
**Goal**: Address critical performance bottlenecks identified in codebase audit

Based on comprehensive performance analysis, this phase addresses 10 critical bottlenecks:
- String concatenation in streaming (O(n²) → O(n))
- Scroll thrashing during streaming
- Excessive SwiftData saves causing disk I/O storms
- Unnecessary re-computations on every render
- Plugin loading on main thread

See `.planning/phases/08-performance-optimization/PLAN.md` for detailed breakdown.

---

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

### Phase 5: OllamaKit Local Integration
**Duration**: 1-2 weeks
**Goal**: Remove external OllamaKit package dependency and ensure local Sources/OllamaKit/Sources is used.

| Task | ID | Effort | Priority | Dependencies | Status |
|------|-----|--------|----------|--------------|--------|
| Remove OllamaKit XCRemoteSwiftPackageReference from Xcode project | O-001 | Medium | P0 | Phase 4 | ⬜ |
| Add local Sources/OllamaKit/Sources as target in Xcode | O-002 | Medium | P0 | O-001 | ⬜ |
| Apply -strict-concurrency=minimal flag to OllamaKit target | O-003 | Small | P0 | O-002 | ⬜ |
| Verify build succeeds without data race errors | O-004 | Small | P0 | O-003 | ⬜ |

**Acceptance Criteria**:
- [ ] External OllamaKit package dependency completely removed
- [ ] Local Sources/OllamaKit/Sources integrated as target
- [ ] -strict-concurrency=minimal flag applied
- [ ] Build completes successfully without concurrency warnings

**Outcome**: Local OllamaKit integration complete

---

### Phase 6: Swift 6 Concurrency Fixes
**Duration**: 1-2 weeks
**Goal**: Fix Sendable conformance errors and MainActor isolation issues discovered during Phase 5.

| Task | ID | Effort | Priority | Dependencies | Status |
|------|-----|--------|----------|--------------|--------|
| Fix mutable stored properties in Sendable classes | S-001 | Medium | P0 | Phase 5 | ⬜ |
| Resolve MainActor-isolated static properties | S-002 | Medium | P0 | Phase 5 | ⬜ |
| Implement type conversion between OKGenerateResponse/OKModelResponse and ChatResponseChunk/[String] | S-003 | Medium | P0 | Phase 5 | ⬜ |
| Fix non-final classes conforming to Sendable | S-004 | Medium | P0 | Phase 5 | ⬜ |

**Acceptance Criteria**:
- [ ] All Sendable conformance errors resolved
- [ ] MainActor isolation issues fixed
- [ ] Type conversions between OllamaKit and Chat types working
- [ ] All non-final Sendable classes made final or refactored
- [ ] Build completes without Swift concurrency warnings

**Outcome**: Full Swift 6 concurrency compliance achieved

---

## Phase Summary

| Phase | Duration | Goal | Key Deliverables |
|-------|----------|------|-------------------|
| 8 | 1-2 weeks | Performance Optimization | 10 critical bottlenecks fixed, memory/CPU/disk improvements |
| 1 | 1-2 weeks | ChatBackend Abstraction | Protocol + OllamaBackend + MCPBackend skeleton |
| 2 | 1-2 weeks | Dependency Injection | DI in ChatView + MessageViewModel |
| 3 | 1-2 weeks | Test Infrastructure | Test target + mocks + CI |
| 4 | 1-2 weeks | Plugin Architecture | Plugin system + MCPBackend |
| 5 | 1-2 weeks | OllamaKit Local Integration | Local OllamaKit target + concurrency flags |
| 6 | 1-2 weeks | Swift 6 Concurrency Fixes | Sendable conformance + MainActor isolation + type conversions |

**Total**: 7 phases, ~9-14 weeks, 34+ requirements

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
    ↓
Phase 5 (OllamaKit Local Integration) → depends on Phase 4
    ↓
Phase 6 (Swift 6 Concurrency Fixes) → depends on Phase 5
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
| 3.4.0 | Phase 5 | TBD | OllamaKit Local Integration |
| 3.5.0 | Phase 6 | TBD | Swift 6 Concurrency Fixes |
| 3.6.0 | Phase 8 | TBD | Performance Optimization |

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
*Single milestone with 7 phases, ~9-14 weeks total*
*Focus: Architecture adaptation, test introduction, plugin foundation, OllamaKit integration, Swift 6 concurrency, Performance Optimization*
