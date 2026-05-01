# Roadmap

## Overview
This roadmap defines the phased approach for adding **MCP (Model Context Protocol) support** to Ollamac. MCP extends LLM capabilities by allowing access to external tools/resources. Ollamac will use **Ollama + MCP** together – MCP enhances the LLM's abilities during chat sessions.

## Current State
- **Version**: 3.0.3
- **Status**: Functional Ollama client
- **Architecture**: MVVM with SwiftUI, SwiftData
- **Test Coverage**: 0%
- **MCP Status**: Not supported yet

---

## Phase Structure

### Phase 0: Foundation (Current - Complete)
**Duration**: Already complete
**Goal**: Establish project, codebase mapping
**Status**: ✅ Complete

| Task | Status | Owner | Notes |
|------|--------|-------|-------|
| Analyze existing codebase | ✅ Done | GSD | 7 codebase docs created |
| Document architecture | ✅ Done | GSD | ARCHITECTURE.md, STRUCTURE.md |
| Identify technical debt | ✅ Done | GSD | CONCERNS.md created |
| Define requirements | ✅ Done | GSD | REQUIREMENTS.md created |

---

## Milestone 1: Architecture for MCP Support
**Duration**: 2-3 weeks
**Goal**: Enable MCP integration by decoupling architecture
**Success**: Ollamac can integrate MCP servers alongside Ollama

### Phase 1.1: Dependency Injection & Network Abstraction
**Outcome**: Decoupled architecture enabling MCP integration

| Task | ID | Effort | Priority | Dependencies |
|------|-----|--------|----------|--------------|
| Create OllamaKit protocol abstraction | R-001 | Medium | P0 | None |
| Create MCP client protocol/interface | NEW | Medium | P0 | R-001 |
| Implement dependency injection in ChatView | R-001 | Medium | P0 | R-001 |
| Implement dependency injection in MessageViewModel | R-001 | Medium | P0 | R-001 |
| Extract business logic from views | R-003 | Medium | P0 | R-001 |

**Acceptance Criteria**:
- [ ] OllamaKit can be mocked for testing
- [ ] MCP client interface defined
- [ ] ViewModels accept dependencies via constructor
- [ ] No direct OllamaKit instantiation in views

### Phase 1.2: Test Infrastructure for MCP
**Outcome**: Foundation for testing MCP integration

| Task | ID | Effort | Priority | Dependencies |
|------|-----|--------|----------|--------------|
| Add unit test target to Xcode project | R-010 | Small | P0 | None |
| Create MockOllamaKit implementation | R-011 | Medium | P0 | R-001 |
| Create MockMCPClient implementation | NEW | Medium | P0 | R-001 |
| Add first unit tests for MessageViewModel | R-012 | Medium | P0 | R-010, R-011 |
| Setup GitHub Actions CI pipeline | R-016 | Medium | P0 | R-010 |

**Acceptance Criteria**:
- [ ] Test target compiles and runs
- [ ] MockOllamaKit can simulate all API responses
- [ ] MockMCPClient can simulate tool calls
- [ ] CI runs tests on every PR

### Phase 1.3: MCP Client Implementation
**Outcome**: Basic MCP client functionality

| Task | ID | Effort | Priority | Dependencies |
|------|-----|--------|----------|--------------|
| Implement MCP client module | NEW | Medium | P0 | 1.1 |
| Add MCP server connection management | NEW | Medium | P0 | 1.1 |
| Implement MCP tool listing | NEW | Small | P0 | 1.3 |
| Implement MCP tool execution | NEW | Medium | P0 | 1.3 |

**Acceptance Criteria**:
- [ ] MCP client can connect to MCP servers
- [ ] MCP client can list available tools
- [ ] MCP client can execute tools and return results
- [ ] MCP errors handled gracefully

---

## Milestone 2: MCP Integration in Chat
**Duration**: 2 weeks
**Goal**: Full MCP integration in chat flow
**Success**: Users can use MCP tools during Ollama chats

### Phase 2.1: MCP Tool Integration
**Outcome**: MCP tools available during chat

| Task | ID | Effort | Priority | Dependencies |
|------|-----|--------|----------|--------------|
| Integrate MCP client with MessageViewModel | NEW | Medium | P0 | M1 |
| Add MCP tool discovery to chat context | NEW | Medium | P0 | 2.1 |
| Display available MCP tools in UI | NEW | Medium | P0 | 2.1 |
| Handle MCP tool calls from LLM | NEW | Medium | P0 | 2.1 |

**Acceptance Criteria**:
- [ ] MCP tools discovered and available in chat
- [ ] LLM can request MCP tool usage
- [ ] Tool results displayed in chat
- [ ] Multiple MCP servers can be configured

### Phase 2.2: Streaming with MCP
**Outcome**: Seamless MCP integration in streaming responses

| Task | ID | Effort | Priority | Dependencies |
|------|-----|--------|----------|--------------|
| Integrate MCP tool calls in streaming | NEW | Medium | P0 | 2.1 |
| Handle MCP tool responses in chat flow | NEW | Medium | P0 | 2.2 |
| Add MCP error handling in chat | NEW | Small | P0 | 2.2 |
| Optimize MCP tool call performance | NEW | Small | P1 | 2.2 |

**Acceptance Criteria**:
- [ ] MCP tool calls don't block streaming
- [ ] Tool results inserted at correct position in response
- [ ] MCP errors shown to user without breaking chat
- [ ] Tool calls are performant

### Phase 2.3: MCP Server Management
**Outcome**: User can configure and manage MCP servers

| Task | ID | Effort | Priority | Dependencies |
|------|-----|--------|----------|--------------|
| Add MCP server configuration UI | NEW | Medium | P0 | 2.1 |
| Add MCP server connection testing | NEW | Small | P0 | 2.3 |
| Add MCP server enable/disable | NEW | Small | P0 | 2.3 |
| Persist MCP server configurations | NEW | Small | P0 | 2.3 |

**Acceptance Criteria**:
- [ ] Users can add/remove MCP servers
- [ ] Users can test MCP server connections
- [ ] MCP server configs persisted
- [ ] MCP servers can be enabled/disabled

---

## Milestone 3: Testing & Polish
**Duration**: 1-2 weeks
**Goal**: Comprehensive testing and quality improvements
**Success**: MCP integration fully tested and production-ready

### Phase 3.1: MCP Integration Testing
**Outcome**: Full test coverage for MCP features

| Task | ID | Effort | Priority | Dependencies |
|------|-----|--------|----------|--------------|
| Add unit tests for MCP client | NEW | Medium | P0 | M1, M2 |
| Add integration tests for MCP + Ollama | NEW | Medium | P0 | M2 |
| Add UI tests for MCP features | NEW | Medium | P1 | M2 |
| Add code coverage reporting | R-017 | Small | P1 | M1 |

**Acceptance Criteria**:
- [ ] MCP client has 80%+ test coverage
- [ ] MCP integration tests pass
- [ ] UI tests cover critical MCP flows
- [ ] Code coverage visible in CI

### Phase 3.2: Code Quality & Documentation
**Outcome**: Production-ready MCP implementation

| Task | ID | Effort | Priority | Dependencies |
|------|-----|--------|----------|--------------|
| Extract common streaming logic | R-040 | Small | P1 | None |
| Unify think tag handling | R-041 | Small | P1 | None |
| Centralize configuration | R-042 | Small | P1 | None |
| Add MCP documentation | NEW | Medium | P0 | M2 |
| Add SwiftLint for style enforcement | R-044 | Small | P1 | None |

**Acceptance Criteria**:
- [ ] No duplicate streaming code
- [ ] Consistent think tag handling
- [ ] All configuration in one place
- [ ] MCP usage documented
- [ ] Linting passes on CI

---

## Phase Summary

| Milestone | Phases | Duration | Primary Focus | Success Metric |
|-----------|--------|----------|----------------|----------------|
| M1 | 1.1-1.3 | 2-3 weeks | Architecture & MCP Client | MCP client functional, testable |
| M2 | 2.1-2.3 | 2 weeks | MCP Chat Integration | MCP tools usable in chat |
| M3 | 3.1-3.2 | 1-2 weeks | Testing & Quality | MCP fully tested, production-ready |

---

## Total Estimates
- **Total Phases**: 8 phases across 3 milestones
- **Total Duration**: 5-7 weeks
- **Total Effort**: ~35-45 person-days

---

## Release Plan

| Version | Milestone | Date | Notes |
|---------|-----------|------|-------|
| 3.0.3 | Current | Released | Baseline |
| 3.1.0 | M1 Complete | TBD | MCP client + architecture |
| 3.2.0 | M2 Complete | TBD | MCP chat integration |
| 3.3.0 | M3 Complete | TBD | MCP production-ready |

---

## Dependencies

### External Dependencies
- MCP specification (modelcontextprotocol.io)
- Ollama server (for integration testing)
- Xcode 15+ (Swift 5.9+)
- macOS 14.0+ (for builds)
- GitHub (for CI/CD)

### Internal Dependencies
- M1 must be complete before M2 can start (architecture first)
- M2 must be complete before M3 can start (integration before testing)
- Testing infrastructure required for all MCP development

---

## Key Design Decisions

### MCP Architecture in Ollamac
```
ChatView
   └── MessageViewModel
        ├── OllamaKit (existing) -- for LLM chat
        └── MCPClient (new) -- for tool/resources
             └── MCPServerConnection -- manages server connections
                  └── MCPToolExecutor -- executes tools
```

### MCP + Ollama Integration Flow
```
User sends message
   ↓
MessageViewModel processes
   ↓
OllamaKit streams LLM response
   ↓
IF LLM requests MCP tool:
   ├─ MCPClient lists available tools
   ├─ MCPClient executes requested tool
   └─ Tool result inserted into stream
   ↓
Response with tool results displayed
```

### MCP Server Configuration
- Multiple MCP servers can be configured
- Each server provides its own set of tools
- Users can enable/disable servers per chat
- Server connection tested before use

---

## Tracking
- **Project Board**: GitHub Projects (recommended)
- **Issues**: GitHub Issues with labels
- **PRs**: GitHub Pull Requests with templates
- **Progress**: Manual tracking in STATE.md

---

## Next Steps
1. Review and approve this updated roadmap
2. Run `/gsd-plan-phase 1.1` to start Phase 1.1 (Dependency Injection & Network Abstraction)
3. Or run `/gsd-plan-milestone-gaps` to identify additional gaps

---
*Roadmap updated for MCP integration*
*Ollama + MCP (not Ollama OR MCP) - MCP extends LLM capabilities*
*E-Mail specific features removed (user has existing MCP integration)*
