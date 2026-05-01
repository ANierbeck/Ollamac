# MCP Architecture Milestone - Requirements

## Overview
**Milestone Name**: MCP Architecture Foundation  
**Objective**: Adapt architecture to support MCP, introduce tests, and establish plugin architecture fundamentals.  
**Priority**: P0 (Foundation for all future MCP work)  
**Status**: Not started  

---

## Milestone Goals
1. **Adapt Architecture**: Decouple ChatViewModel and MessageViewModel from direct OllamaKit usage
2. **Introduce Tests**: Create test infrastructure and first unit tests
3. **Plugin Architecture**: Establish foundation for MCP as a plugin/extension

---

## Epic 1: Architecture Adaptation
**Priority**: P0 (Critical - blocks MCP integration)

### Architecture Changes Required

| ID | Requirement | Description | Acceptance Criteria | Effort | Risk | Blocked By |
|----|-------------|-------------|---------------------|--------|------|------------|
| A-001 | Create ChatBackend Protocol | Abstract OllamaKit behind a protocol | All chat operations go through protocol | Medium | Low | None |
| A-002 | Implement DI in ChatView | Inject ChatBackend instead of creating OllamaKit directly | ChatView accepts ChatBackend via constructor/environment | Medium | Low | A-001 |
| A-003 | Implement DI in MessageViewModel | Inject ChatBackend and dependencies | MessageViewModel accepts dependencies via constructor | Medium | Low | A-001 |
| A-004 | Extract Business Logic from Views | Move logic out of view components | Views only handle UI, ViewModels handle logic | Medium | Low | A-002, A-003 |
| A-005 | Create MCPBackend Implementation | First concrete backend for MCP | Implements ChatBackend protocol, connects to MCP servers | Medium | Medium | A-001 |

**Success Criteria for Epic 1:**
- [ ] ChatBackend protocol defined and documented
- [ ] ChatView uses injected ChatBackend
- [ ] MessageViewModel uses injected dependencies
- [ ] MCPBackend can be injected as alternative to OllamaBackend
- [ ] No direct OllamaKit instantiation in views

---

## Epic 2: Test Infrastructure
**Priority**: P0 (Critical - enables verification)

### Test Foundation

| ID | Requirement | Description | Acceptance Criteria | Effort | Risk | Blocked By |
|----|-------------|-------------|---------------------|--------|------|------------|
| T-001 | Add Unit Test Target | Create OllamacTests in Xcode project | Target compiles and runs successfully | Small | Low | None |
| T-002 | Create Mock ChatBackend | Mock implementation for testing | Can simulate all ChatBackend operations | Medium | Low | A-001 |
| T-003 | Create Mock MCPBackend | Mock for MCP testing | Can simulate MCP server responses | Medium | Low | A-005 |
| T-004 | Add First Unit Tests | Test ChatViewModel with mocks | ViewModel tests pass with mock ChatBackend | Medium | Medium | T-001, T-002 |
| T-005 | Add MessageViewModel Tests | Test message generation and handling | Critical paths covered (generate, streaming) | Medium | Medium | T-001, T-002 |
| T-006 | Setup CI Pipeline | GitHub Actions for automated testing | Tests run on every push/PR | Medium | Low | T-001 |

**Success Criteria for Epic 2:**
- [ ] Unit test target exists and works
- [ ] Mock ChatBackend and MCPBackend available
- [ ] ViewModels have basic unit test coverage
- [ ] CI pipeline runs tests automatically

---

## Epic 3: Plugin Architecture Foundation
**Priority**: P0 (Critical - enables MCP integration)

### Plugin System Basics

| ID | Requirement | Description | Acceptance Criteria | Effort | Risk | Blocked By |
|----|-------------|-------------|---------------------|--------|------|------------|
| P-001 | Define Plugin Protocol | Protocol for chat backends/plugins | Clear interface for extending functionality | Small | Low | A-001 |
| P-002 | Create Plugin Registry | Manage available plugins/backends | Can register, unregister, list plugins | Medium | Low | P-001 |
| P-003 | Implement Plugin Discovery | Auto-detect available plugins | Plugins discovered at startup | Small | Low | P-002 |
| P-004 | Add Plugin Configuration UI | UI for managing plugins | Users can enable/disable plugins | Medium | Medium | P-002 |
| P-005 | Create MCP Plugin | First concrete plugin implementation | MCP functions as a plugin | Medium | Medium | P-001, A-005 |

**Success Criteria for Epic 3:**
- [ ] Plugin protocol defined
- [ ] Plugin registry implemented
- [ ] Plugin discovery works
- [ ] Users can manage plugins in UI
- [ ] MCP implemented as first plugin

---

## Requirement Summary

### Must Have (P0) - All Critical
| Epic | Requirements | Count | Effort |
|------|-------------|-------|--------|
| Architecture | A-001 to A-005 | 5 | ~2.5 weeks |
| Testing | T-001 to T-006 | 6 | ~1.5 weeks |
| Plugin Architecture | P-001 to P-005 | 5 | ~2 weeks |
| **Total** | **16 requirements** | **16** | **~6 weeks** |

### Priority Distribution
- **P0 (Critical)**: 16 requirements (100%)
- **P1 (High)**: 0 requirements
- **P2 (Medium)**: 0 requirements

---

## Dependencies

### Technical Dependencies
| Requirement | Depends On | Reason |
|-------------|------------|--------|
| A-002 | A-001 | Need ChatBackend protocol before injection |
| A-003 | A-001 | Need ChatBackend protocol before injection |
| A-004 | A-002, A-003 | Need DI first before extracting logic |
| A-005 | A-001 | Need protocol to implement MCPBackend |
| T-002 | A-001 | Need ChatBackend protocol for mock |
| T-003 | A-005 | Need MCPBackend to mock |
| T-004, T-005 | T-001, T-002 | Need test target and mocks |
| P-002 | P-001 | Need plugin protocol for registry |
| P-003 | P-002 | Need registry for discovery |
| P-004 | P-002 | Need registry for UI |
| P-005 | P-001, A-005 | Need protocol and MCPBackend |

### Resource Dependencies
- Xcode 15+ for Swift 5.9 features
- macOS 14.0+ for building
- GitHub repository for CI/CD

---

## Architecture Impact

### Current Architecture
```
ChatView ↔ MessageViewModel ↔ OllamaKit (direct)
```

### Target Architecture
```
ChatView ↔ MessageViewModel ↔ ChatBackend (Protocol)
                              ├── OllamaBackend
                              └── MCPBackend (Plugin)
                           
PluginRegistry
├── OllamaBackend
└── MCPBackend
```

### Key Changes
1. **ChatBackend Protocol**: Unified interface for all chat backends
2. **Dependency Injection**: ChatBackend injected into ViewModels
3. **Plugin System**: Backends can be registered as plugins
4. **MCPBackend**: First plugin implementation

---

## Success Criteria for Milestone

- [ ] ChatBackend protocol defined and all backends implement it
- [ ] Dependency injection implemented for ChatView and MessageViewModel
- [ ] Unit test target exists and first tests pass
- [ ] CI pipeline runs tests on every push
- [ ] Plugin protocol defined and registry implemented
- [ ] MCPBackend implemented as first plugin
- [ ] No direct OllamaKit instantiation in views
- [ ] Architecture documented

---

## Constraints
1. Must maintain backward compatibility with existing Ollama chats
2. Must maintain macOS 14.0+ support
3. Must maintain free/open-source license
4. Plugin system should be optional (can be disabled)
5. Should work with existing OllamaKit version

---

## Out of Scope
- Full MCP specification implementation
- MCP tool execution details
- UI for MCP-specific features
- Performance optimization
- Advanced plugin features (versioning, dependencies, etc.)

---
*Requirements defined for MCP Architecture Milestone*
*Focus: Architecture adaptation, test introduction, plugin foundation*
