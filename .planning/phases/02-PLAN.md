# Phase 2: Dependency Injection & Architecture Refinement - Execution Plan

## Overview
**Phase Number**: 2  
**Phase Name**: Dependency Injection & Architecture Refinement  
**Milestone**: MCP Architecture Foundation  
**Duration**: 1 week (reduced from 1-2 weeks - most DI work completed in Phase 1)  
**Status**: Not started  
**Previous Phase**: Phase 1 (ChatBackend Abstraction) - COMPLETE

---

## Phase Goals
1. **Complete Business Logic Extraction**: Finish extracting business logic from views (A-004)
2. **Verify DI Implementation**: Ensure all dependency injection works correctly throughout the app
3. **Architecture Refinement**: Clean up and document the new architecture

---

## Research Summary

**Phase 1 completed all major DI work**:
- ChatBackend protocol defined and implemented
- OllamaBackend adapter created
- MCPBackend skeleton created
- ChatViewModel refactored to use @Environment(ChatBackend.self)
- MessageViewModel refactored to use @Environment(ChatBackend.self)
- ChatView updated to inject ChatBackend via environment
- ChatPreferencesView updated to use @Environment(ChatBackend.self)
- UpdateOllamaHostSheet updated to use OllamaBackend

**Remaining Work**:
- A-004: Extract Business Logic from Views
  - ChatView still contains business logic that could be extracted
  - `createChatBackend()` function in ChatView
  - `generateAction()` and `regenerateAction()` coordinate between views and ViewModels
  - Could benefit from a ChatService or Coordinator pattern

---

## Requirements Covered

| Requirement ID | Title | Epic | Status |
|----------------|-------|------|--------|
| A-004 | Extract Business Logic from Views | Architecture Adaptation | ⬜ Not started |

**Note**: A-001, A-002, A-003, A-005 were completed in Phase 1.

---

## Dependencies

### External Dependencies
- Xcode 15+ (Swift 5.9+)
- macOS 14.0+ (for testing)

### Internal Dependencies
- Phase 1: ChatBackend Abstraction (COMPLETE)

### Blockers
- None identified

---

## Wave-Based Task Breakdown

**Wave Size**: 4 tasks (from config.json)  
**Total Tasks**: 4  
**Waves**: 1 wave

---

### Wave 1: Business Logic Extraction & Architecture Refinement
**Duration**: 1 week  
**Goal**: Complete business logic extraction and verify architecture

#### Tasks

##### Task 2.1: Extract Chat Service Logic
- **ID**: A-004-01
- **Description**: Create ChatService to handle chat coordination logic currently in ChatView
- **Effort**: Medium (2 days)
- **Priority**: P0
- **Dependencies**: Phase 1 complete
- **Current Issues**:
  - ChatView creates ChatBackend via `createChatBackend()` - should be centralized
  - ChatView coordinates between ChatViewModel and MessageViewModel
  - `generateAction()` and `regenerateAction()` contain coordination logic
- **Proposed Solution**:
  - Create `ChatService` class conforming to `ObservableObject`
  - Move chat coordination logic from ChatView to ChatService
  - ChatService uses @Environment(ChatBackend.self)
  - ChatView uses ChatService via @StateObject or @Environment
- **Success Criteria**:
  - [ ] ChatService created
  - [ ] Business logic extracted from ChatView
  - [ ] ChatView is thinner (UI only)
  - [ ] Code compiles without errors
- **Deliverable**: `Ollamac/Services/ChatService.swift`
- **Status**: ⬜ Not started

##### Task 2.2: Update ChatView to Use ChatService
- **ID**: A-004-02
- **Description**: Refactor ChatView to delegate to ChatService
- **Effort**: Medium (2 days)
- **Priority**: P0
- **Dependencies**: 2.1
- **Changes**:
  - Replace direct ViewModel coordination with ChatService calls
  - ChatService manages ChatViewModel and MessageViewModel interaction
  - ChatView only handles UI events and delegates to service
- **Success Criteria**:
  - [ ] ChatView uses ChatService
  - [ ] All existing functionality preserved
  - [ ] No direct ViewModel-to-ViewModel coordination in ChatView
- **Deliverable**: Updated `ChatView.swift`
- **Status**: ⬜ Not started

##### Task 2.3: Verify Complete DI Implementation
- **ID**: A-004-verify
- **Description**: Verify no direct OllamaKit or business logic in views
- **Effort**: Small (1 day)
- **Priority**: P0
- **Dependencies**: 2.1, 2.2
- **Verification Checklist**:
  - [ ] No `OllamaKit` instantiation in any View file
  - [ ] All ChatBackend access via @Environment
  - [ ] Business logic extracted from views
  - [ ] Manual testing passes
- **Success Criteria**:
  - [ ] Full DI audit complete
  - [ ] All views use injected dependencies
  - [ ] Architecture documentation updated
- **Deliverable**: DI verification report
- **Status**: ⬜ Not started

##### Task 2.4: Update Architecture Documentation
- **ID**: DOC-001
- **Description**: Update ARCHITECTURE.md with new patterns
- **Effort**: Small (1 day)
- **Priority**: P0
- **Dependencies**: 2.3
- **Documentation Updates**:
  - Data flow with ChatBackend protocol
  - DI pattern using SwiftUI Environment
  - Service layer (ChatService) architecture
  - Plugin foundation for MCP
- **Success Criteria**:
  - [ ] ARCHITECTURE.md updated
  - [ ] New patterns documented
  - [ ] Diagrams updated
- **Deliverable**: Updated `.planning/codebase/ARCHITECTURE.md`
- **Status**: ⬜ Not started

**Wave 1 Acceptance Criteria**:
- [ ] ChatService created and used
- [ ] Business logic extracted from views
- [ ] Complete DI verification
- [ ] Architecture documentation updated

---

## Verification Criteria

### Phase Success Criteria
- [ ] Business logic fully extracted from views
- [ ] ChatService manages chat coordination
- [ ] All dependency injection working correctly
- [ ] Architecture documented
- [ ] Manual testing passes
- [ ] No direct OllamaKit usage in views

---

## Success Measures

### Quantitative Metrics
| Metric | Target | Measurement Method |
|--------|--------|---------------------|
| Lines of code added | ~200-300 | Git diff |
| Files created | 1 | Git status |
| Files modified | 1-2 | Git status |
| Views with direct business logic | 0 | Code inspection |

### Qualitative Metrics
- [ ] Architecture is cleaner and more maintainable
- [ ] Separation of concerns improved
- [ ] Views contain only UI logic
- [ ] Service layer handles coordination
- [ ] Code follows Swift conventions

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation Strategy | Owner |
|------|-------------|--------|---------------------|-------|
| Extraction breaks functionality | Medium | High | Comprehensive manual testing | Developer |
| Service layer becomes too complex | Low | Medium | Keep ChatService focused | Team |
| Time estimation inaccurate | Medium | Medium | Daily progress tracking | PM |

---

## Resource Requirements

### Human Resources
- **Developers**: 1 primary developer
- **Reviewers**: 1 for code review

### Technical Resources
- **Xcode**: 15.0+ (Swift 5.9+)
- **macOS**: 14.0+ (Sonoma)
- **Ollama**: Running instance for testing

### Time Estimate
- **Total**: 1 week
- **Wave 1**: 1 week

---

## File Structure

```
Ollamac/
├── Services/
│   └── ChatService.swift          # NEW: Chat coordination service
├── ChatBackend/
│   ├── ChatBackend.swift          # Protocol + types
│   ├── ChatBackendEnvironment.swift # Environment injection
│   ├── OllamaBackend.swift        # Ollama implementation
│   ├── MCPBackend.swift           # MCP skeleton
│   └── Clients/
│       ├── MCPClient.swift         # MCP client interface
│       └── HTTPMCPClient.swift     # HTTP implementation
├── ViewModels/
│   ├── ChatViewModel.swift        # Modified (uses @Environment)
│   └── MessageViewModel.swift     # Modified (uses @Environment)
├── Views/
│   └── Chats/
│       ├── ChatView.swift          # Modified (uses ChatService)
│       └── ChatPreferencesView.swift # Modified (uses @Environment)
└── Sheets/
    └── UpdateOllamaHostSheet.swift # Modified (uses OllamaBackend)

.planning/
├── phases/
│   ├── 01-PLAN.md                 # Phase 1 (complete)
│   └── 02-PLAN.md                 # This file
└── codebase/
    └── ARCHITECTURE.md             # To be updated
```

---

## Notes

### Design Decisions
1. **ChatService Pattern**: Lightweight service layer for chat coordination
2. **Minimal Changes**: Only extract what's necessary, don't over-engineer
3. **Backward Compatibility**: Ensure all existing functionality works
4. **Testable**: ChatService should be easy to mock for testing (Phase 3)

### Assumptions
1. ChatService will be a reference type (class) for shared state
2. ChatService will conform to ObservableObject for SwiftUI
3. ChatView will own the ChatService instance
4. Manual testing is sufficient for Phase 2

### Open Questions
1. Should ChatService be a singleton or instance-per-chat? **Instance-per-chat** - but ChatView manages it
2. Should we extract more services? **Not in Phase 2** - keep scope focused

---

## Next Steps

1. **Start Wave 1**: Task 2.1 (Create ChatService)
2. **After Wave 1**: Verify and test
3. **Phase Complete**: Update STATE.md and prepare for Phase 3
4. **Next Phase**: Phase 3 (Test Infrastructure)

---

## Related Documents
- `.planning/ROADMAP.md` - Overall milestone roadmap
- `.planning/REQUIREMENTS.md` - All milestone requirements
- `.planning/phases/01-PLAN.md` - Phase 1 plan
- `.planning/codebase/ARCHITECTURE.md` - Architecture documentation

---
*Phase 2 Plan for MCP Architecture Milestone*
*Created: 2024-05-01*
*Status: Ready for execution*
*Previous Phase: Phase 1 (Complete)*
