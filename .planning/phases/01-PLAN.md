# Phase 1: ChatBackend Abstraction - Execution Plan

## Overview
**Phase Number**: 1  
**Phase Name**: ChatBackend Abstraction  
**Milestone**: MCP Architecture Foundation  
**Duration**: 1-2 weeks  
**Status**: Not started  
**Wave Size**: 4 tasks per wave (default from config.json)  

---

## Phase Goals
1. Create ChatBackend protocol to abstract OllamaKit
2. Refactor existing code to use OllamaBackend (implementing ChatBackend)
3. Create skeleton MCPBackend (implementing ChatBackend)

---

## Requirements Covered
| Requirement ID | Title | Epic |
|----------------|-------|------|
| A-001 | Create ChatBackend Protocol | Architecture Adaptation |
| A-001 (second) | Implement OllamaBackend (refactor existing) | Architecture Adaptation |
| A-005 | Create MCPBackend Implementation | Architecture Adaptation |

---

## Wave 1: Protocol Definition
**Duration**: 3-5 days  
**Goal**: Define and document the ChatBackend protocol

### Tasks

#### Task 1.1.1: Analyze OllamaKit API Surface
- **ID**: A-001-research
- **Description**: Document all methods and properties used from OllamaKit in the codebase
- **Effort**: Small (1 day)
- **Priority**: P0
- **Dependencies**: None
- **Success Criteria**:
  - [ ] List all OllamaKit methods called in ChatViewModel
  - [ ] List all OllamaKit methods called in MessageViewModel
  - [ ] List all OllamaKit properties accessed
  - [ ] Document return types and parameters
- **Deliverable**: Document ` OllamaKit-API-Usage.md` in `.planning/research/`

#### Task 1.1.2: Design ChatBackend Protocol
- **ID**: A-001-design
- **Description**: Design the ChatBackend protocol interface based on OllamaKit API usage
- **Effort**: Medium (2-3 days)
- **Priority**: P0
- **Dependencies**: 1.1.1
- **Success Criteria**:
  - [ ] ChatBackend protocol defined in code
  - [ ] All required methods included
  - [ ] Protocol is `Sendable` for thread safety
  - [ ] Protocol documented with comments
- **Deliverable**: `ChatBackend.swift` protocol file

#### Task 1.1.3: Review Protocol Design
- **ID**: A-001-review
- **Description**: Code review of ChatBackend protocol design
- **Effort**: Small (1 day)
- **Priority**: P0
- **Dependencies**: 1.1.2
- **Success Criteria**:
  - [ ] Protocol reviewed for completeness
  - [ ] Protocol reviewed for Swift best practices
  - [ ] Protocol approved for implementation

#### Task 1.1.4: Document Protocol Contract
- **ID**: A-001-docs
- **Description**: Document the ChatBackend protocol contract and usage guidelines
- **Effort**: Small (1 day)
- **Priority**: P0
- **Dependencies**: 1.1.2
- **Success Criteria**:
  - [ ] Protocol usage documented
  - [ ] Example implementations documented
  - [ ] Integration guide created
- **Deliverable**: Updated ARCHITECTURE.md with ChatBackend section

**Wave 1 Acceptance Criteria**:
- [ ] OllamaKit API usage fully documented
- [ ] ChatBackend protocol defined and approved
- [ ] Protocol contract documented

---

## Wave 2: OllamaBackend Implementation
**Duration**: 3-5 days  
**Goal**: Refactor existing OllamaKit usage to use ChatBackend

### Tasks

#### Task 1.2.1: Create OllamaBackend Implementation
- **ID**: A-001-ollama
- **Description**: Implement OllamaBackend conforming to ChatBackend protocol
- **Effort**: Medium (2-3 days)
- **Priority**: P0
- **Dependencies**: Wave 1 complete
- **Success Criteria**:
  - [ ] OllamaBackend implements all ChatBackend methods
  - [ ] OllamaBackend wraps existing OllamaKit functionality
  - [ ] All OllamaKit calls go through OllamaBackend
- **Deliverable**: `OllamaBackend.swift` file

#### Task 1.2.2: Refactor ChatViewModel
- **ID**: A-002-chatview
- **Description**: Update ChatViewModel to use injected ChatBackend instead of OllamaKit directly
- **Effort**: Medium (2-3 days)
- **Priority**: P0
- **Dependencies**: 1.2.1
- **Success Criteria**:
  - [ ] ChatViewModel accepts ChatBackend via constructor/environment
  - [ ] No direct OllamaKit instantiation in ChatViewModel
  - [ ] All chat operations use ChatBackend
- **Deliverable**: Updated `ChatViewModel.swift`

#### Task 1.2.3: Refactor MessageViewModel
- **ID**: A-003-messageview
- **Description**: Update MessageViewModel to use injected ChatBackend instead of OllamaKit directly
- **Effort**: Medium (2-3 days)
- **Priority**: P0
- **Dependencies**: 1.2.1
- **Success Criteria**:
  - [ ] MessageViewModel accepts ChatBackend via constructor
  - [ ] No direct OllamaKit instantiation in MessageViewModel
  - [ ] All message operations use ChatBackend
- **Deliverable**: Updated `MessageViewModel.swift`

#### Task 1.2.4: Test Refactored Code
- **ID**: A-002-A-003-test
- **Description**: Manual testing of refactored ViewModels
- **Effort**: Small (1 day)
- **Priority**: P0
- **Dependencies**: 1.2.2, 1.2.3
- **Success Criteria**:
  - [ ] ChatView works with OllamaBackend
  - [ ] MessageViewModel works with OllamaBackend
  - [ ] All existing functionality preserved

**Wave 2 Acceptance Criteria**:
- [ ] OllamaBackend fully implemented
- [ ] ChatViewModel uses ChatBackend
- [ ] MessageViewModel uses ChatBackend
- [ ] Existing functionality verified

---

## Wave 3: MCPBackend Skeleton
**Duration**: 2-3 days  
**Goal**: Create skeleton MCPBackend implementation

### Tasks

#### Task 1.3.1: Research MCP Specification
- **ID**: A-005-research
- **Description**: Research MCP specification for chat integration requirements
- **Effort**: Small (1 day)
- **Priority**: P0
- **Dependencies**: Wave 1 complete
- **Success Criteria**:
  - [ ] MCP chat flow understood
  - [ ] Required MCP endpoints identified
  - [ ] Integration approach determined
- **Deliverable**: `MCP-Research.md` in `.planning/research/`

#### Task 1.3.2: Create MCPBackend Skeleton
- **ID**: A-005-skeleton
- **Description**: Implement MCPBackend conforming to ChatBackend protocol
- **Effort**: Medium (2-3 days)
- **Priority**: P0
- **Dependencies**: 1.3.1, Wave 1 complete
- **Success Criteria**:
  - [ ] MCPBackend implements all ChatBackend methods
  - [ ] MCPBackend has connection to MCP server
  - [ ] MCPBackend can list available tools
  - [ ] MCPBackend can execute tools (stub implementation)
- **Deliverable**: `MCPBackend.swift` skeleton file

#### Task 1.3.3: Integrate MCPBackend with ViewModels
- **ID**: A-005-integrate
- **Description**: Ensure ViewModels can use MCPBackend (dependency injection ready)
- **Effort**: Small (1 day)
- **Priority**: P0
- **Dependencies**: 1.3.2
- **Success Criteria**:
  - [ ] MCPBackend can be injected into ViewModels
  - [ ] ViewModels work with both OllamaBackend and MCPBackend
- **Deliverable**: Integration verified

**Wave 3 Acceptance Criteria**:
- [ ] MCP specification researched
- [ ] MCPBackend skeleton implemented
- [ ] MCPBackend integrates with ViewModels

---

## Phase Dependencies

```
Wave 1 (Protocol Definition)
    ↓
Wave 2 (OllamaBackend + Refactoring) → depends on Wave 1
    ↓
Wave 3 (MCPBackend Skeleton) → depends on Wave 1 + Wave 2
```

**Note**: Waves 2 and 3 can potentially overlap if Wave 1 completes early

---

## Verification Criteria

### Phase Success Criteria
- [ ] ChatBackend protocol defined and documented
- [ ] OllamaBackend implements ChatBackend
- [ ] MCPBackend skeleton implements ChatBackend
- [ ] ChatViewModel uses injected ChatBackend
- [ ] MessageViewModel uses injected ChatBackend
- [ ] No direct OllamaKit instantiation in views
- [ ] Manual testing passes

### Quality Gates
- [ ] All code compiles without errors
- [ ] All existing functionality preserved
- [ ] No breaking changes for users
- [ ] Code follows Swift conventions

---

## Success Measures

### Quantitative
| Metric | Target | Measurement |
|--------|--------|-------------|
| Lines of code changed | ~500-800 | Git diff |
| Files modified | 5-8 | Git status |
| Protocol methods | 8-12 | ChatBackend.swift |
| Backend implementations | 2 | OllamaBackend + MCPBackend |

### Qualitative
- [ ] Architecture is cleaner and more maintainable
- [ ] DI pattern established for future extensions
- [ ] Plugin foundation laid for MCP integration
- [ ] Code review approved

---

## External Dependencies
- OllamaKit (existing)
- MCP specification (modelcontextprotocol.io)
- Xcode 15+ (Swift 5.9+)
- macOS 14.0+ (for testing)

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Protocol design incomplete | Medium | High | Thorough API analysis (Task 1.1.1) |
| Refactoring breaks existing functionality | Medium | Critical | Comprehensive testing (Task 1.2.4) |
| MCP specification unclear | Low | Medium | Research upfront (Task 1.3.1) |
| Time estimation inaccurate | Medium | Medium | Track progress daily |

---

## Resource Requirements
- **Developers**: 1 (primary)
- **Reviewers**: 1 (for code review)
- **Tools**: Xcode 15+, Git, GitHub
- **Time**: 1-2 weeks

---

## Notes
- This is Phase 1 of the MCP Architecture Milestone
- Phase 2 will focus on Dependency Injection throughout
- Phase 3 will focus on Test Infrastructure
- Phase 4 will focus on Plugin Architecture

---

## Next Steps
1. **Execute Wave 1** - Start with Task 1.1.1 (Analyze OllamaKit API)
2. After Wave 1: Review protocol design before proceeding
3. After Wave 2: Test refactored code thoroughly
4. After Wave 3: Verify MCPBackend skeleton

---
*Phase 1 Plan for MCP Architecture Milestone*
*Created: 2024-05-01*
*Status: Ready for execution*
