# Requirements

## V1 Scope (Current State - Baseline)
Ollamac v3.0.3 provides core chat functionality with Ollama:

### ✅ Implemented
- [x] Native macOS SwiftUI application
- [x] Chat interface with streaming responses
- [x] Multiple chat sessions management
- [x] Model selection from Ollama server
- [x] Custom host configuration
- [x] System prompt customization
- [x] Temperature/TopP/TopK parameters
- [x] Auto-generated chat titles
- [x] Message regeneration
- [x] Copy messages/code blocks
- [x] Markdown rendering with code blocks
- [x] Experimental syntax highlighting
- [x] Auto-updates via Sparkle
- [x] Dark/Light mode support
- [x] Font size adjustment
- [x] Keyboard shortcuts (cmd+±, cmd+shift+R)
- [x] SwiftData persistence (SQLite)
- [x] UserDefaults for settings

### V1 Technical Stack
- Swift 5.9+, SwiftUI, SwiftData
- Xcode 15+ project
- 10 external frameworks (Sparkle, OllamaKit, ChatField, etc.)
- No tests, no CI/CD

---

## V2 Requirements: MCP Integration
**Core Objective**: Enable Ollamac to use **Ollama + MCP** together, where MCP extends LLM capabilities with external tools/resources. User already has working MCP integration for emails (Vibe/Claude), so we only need to enable MCP support in Ollamac.

### Epic 1: Architecture for MCP Support
**Priority**: P0 (Critical - blocks MCP)

| ID | Requirement | Description | Acceptance Criteria | Effort | Risk | MCP Impact |
|----|-------------|-------------|---------------------|--------|------|------------|
| R-001 | Introduce Dependency Injection | Decouple ViewModels from OllamaKit | ViewModels accept dependencies via constructor | Medium | Low | **BLOCKS MCP** |
| R-002 | Create Network Layer Abstraction | Protocol for chat backends | Mockable, supports Ollama + MCP | Medium | Low | **BLOCKS MCP** |
| R-003 | Separate Business Logic from UI | Move logic out of views | ViewModels contain only state | Medium | Low | Improves maintainability |
| R-004 | Add MVVM Data Flow Documentation | Document architecture patterns | Clear docs for contributors | Small | Low | Documentation |
| NEW | Create MCP Client Interface | Define MCP client protocol | Can connect to MCP servers, list/execute tools | Medium | Low | **CORE MCP** |
| NEW | Create MCP Server Configuration | Store MCP server endpoints | Multiple servers, enable/disable | Small | Low | **CORE MCP** |

### Epic 2: Testing Infrastructure
**Priority**: P0 (Critical - blocks MCP verification)

| ID | Requirement | Description | Acceptance Criteria | Effort | Risk | MCP Impact |
|----|-------------|-------------|---------------------|--------|------|------------|
| R-010 | Add Unit Test Target | Create OllamacTests target | Tests compile and run | Small | Low | **BLOCKS MCP** |
| R-011 | Mock OllamaKit for Testing | Create MockOllamaKit | Can simulate all API responses | Medium | Low | **BLOCKS MCP** |
| NEW | Mock MCP Client for Testing | Create MockMCPClient | Can simulate tool calls/responses | Medium | Low | **CORE MCP** |
| R-012 | Test Message Generation | Test streaming logic | 80% coverage of MessageViewModel.generate() | Medium | Medium | Verification |
| R-014 | Test Chat Persistence | Test SwiftData operations | All CRUD operations tested | Medium | Medium | Verification |
| R-016 | Setup CI Pipeline | GitHub Actions for build & test | Tests run on every PR | Medium | Low | Quality |
| R-017 | Add Code Coverage Reporting | Enable coverage in CI | Coverage visible in PRs | Small | Low | Quality |

### Epic 3: MCP Client Implementation
**Priority**: P0 (Core MCP functionality)

| ID | Requirement | Description | Acceptance Criteria | Effort | Risk | MCP Impact |
|----|-------------|-------------|---------------------|--------|------|------------|
| NEW | Implement MCP Client | Connect to MCP servers | Can discover and call tools | Medium | Medium | **CORE MCP** |
| NEW | Implement Tool Discovery | List available MCP tools | Tools shown in UI | Small | Low | **CORE MCP** |
| NEW | Implement Tool Execution | Call MCP tools, get results | Tools work during chat | Medium | Medium | **CORE MCP** |
| NEW | Handle Tool Results in Chat | Display tool outputs | Results integrated in chat | Medium | Medium | **CORE MCP** |
| NEW | MCP Error Handling | Graceful error handling | MCP errors don't break chat | Small | Low | **CORE MCP** |

### Epic 4: MCP + Ollama Integration
**Priority**: P0 (Core functionality)

| ID | Requirement | Description | Acceptance Criteria | Effort | Risk | MCP Impact |
|----|-------------|-------------|---------------------|--------|------|------------|
| NEW | Integrate MCP in Chat Flow | Use MCP during Ollama chat | LLM can use MCP tools | Medium | Medium | **CORE MCP** |
| NEW | Streaming with Tool Calls | Handle tools in streaming | Tool calls don't block streaming | Medium | Medium | **CORE MCP** |
| NEW | MCP Server Management UI | Configure MCP servers | Users can add/remove servers | Medium | Low | **CORE MCP** |
| NEW | MCP Server Connection Testing | Test server connections | Users can verify servers work | Small | Low | UX |

### Epic 5: Code Quality Improvements
**Priority**: P1 (Nice to have, not blocking)

| ID | Requirement | Description | Acceptance Criteria | Effort | Risk | MCP Impact |
|----|-------------|-------------|---------------------|--------|------|------------|
| R-040 | Extract Common Streaming Logic | Reduce duplication | Single source of truth | Small | Low | Maintenance |
| R-041 | Unify Think Tag Handling | Consistent approach | Same logic everywhere | Small | Low | Maintenance |
| R-042 | Centralize Configuration | Single config file | All defaults in one place | Small | Low | Maintenance |
| R-043 | Add Code Documentation | Code and architecture docs | All public APIs documented | Medium | Low | Documentation |
| R-044 | Add SwiftLint | Style enforcement | Linting passes on CI | Small | Low | Quality |
| R-045 | Add Swift Format | Consistent formatting | Auto-formatting on CI | Small | Low | Quality |

---

## Requirement Categories

### Must Have (P0) - **Blocks MCP Integration**
- R-001 to R-002: Architecture improvements (DI, abstractions) - **CRITICAL**
- R-010 to R-011, NEW Mocks: Testing infrastructure - **CRITICAL**
- NEW MCP Client: Core MCP functionality - **CRITICAL**
- NEW MCP Integration: Ollama + MCP together - **CRITICAL**

### Should Have (P1) - **Improves MCP Experience**
- NEW MCP Streaming: Seamless tool calls - **IMPORTANT**
- NEW Server Management: User configuration - **IMPORTANT**
- R-040 to R-045: Code quality - **NICE TO HAVE**

### Nice to Have (P2) - **Future Enhancements**
- Plugins/Extensions architecture (for third-party MCP servers)
- Advanced tool management
- Performance optimizations

### Out of Scope
- Windows/Linux ports
- Mobile apps (iOS/iPadOS)
- Web version
- Commercial features
- Cloud hosting
- **E-Mail specific features** (user already has MCP integration for this)

---

## Dependencies

### Technical Dependencies
| Requirement | Depends On | Reason |
|-------------|------------|--------|
| NEW MCP Client | R-001, R-002 | Need DI and abstraction for MCP |
| NEW Mock MCP Client | R-010, NEW MCP Client | Need test infrastructure and client |
| NEW MCP Integration | NEW MCP Client | Need client to integrate |
| NEW Streaming with Tools | NEW MCP Integration | Need integration first |
| R-012, R-014 | R-010, R-011 | Need test infrastructure |

### MCP-Specific Dependencies
- MCP specification (modelcontextprotocol.io)
- User's existing MCP email integration
- Test MCP servers for integration testing

---

## Assumptions
1. MCP specification is stable enough for implementation
2. User's existing MCP email integration is compatible with Ollamac's needs
3. MCP servers can be configured by users (endpoint URLs)
4. Ollama will continue to support the current chat API
5. MCP tool calls can be integrated into the existing streaming flow

---

## Constraints
1. Must maintain backward compatibility with existing Ollama chats
2. Must maintain macOS 14.0+ support
3. Must maintain free/open-source license
4. MCP integration should be optional (users can disable it)
5. Should work with any MCP-compliant server

---

## MCP Integration Architecture

### High-Level Design
```
Ollamac (SwiftUI)
├── ChatView
│   └── MessageViewModel
│       ├── ChatBackend (Protocol)  ← NEW
│       │   ├── OllamaBackend      ← Existing (refactored)
│       │   └── MCPBackend         ← NEW
│       │       └── MCPClient     ← NEW
│       │           └── MCPServerConnection
│       │               └── MCPToolExecutor
│       └── Message Processing
│           └── MCP Tool Call Handler ← NEW
└── Settings
    └── MCP Server Configuration ← NEW
```

### Chat Flow with MCP
```
User sends message
   ↓
MessageViewModel receives message
   ↓
OllamaBackend sends to Ollama (via ChatBackend protocol)
   ↓
LLM responds with text + optional MCP tool calls
   ↓
IF tool calls present:
   ├─ MCPBackend executes tools via MCPClient
   ├─ Tool results returned to LLM context
   └─ LLM continues response with tool results
   ↓
Full response (text + tool results) displayed to user
```

### Key Interfaces
```swift
// ChatBackend Protocol (NEW)
protocol ChatBackend {
    func sendMessage(prompt: String, context: ChatContext) async throws -> AsyncThrowingStream<ChatChunk, Error>
    func listModels() async throws -> [Model]
    // ...
}

// MCPClient Protocol (NEW)
protocol MCPClient {
    func connect(to server: MCPServerConfig) async throws
    func listTools() async throws -> [MCPTool]
    func callTool(name: String, arguments: [String: Any]) async throws -> MCPToolResult
    // ...
}
```

---

## Success Criteria for V2 (MCP Support)
- [ ] Ollamac can connect to MCP servers
- [ ] LLM can discover and use MCP tools during chat
- [ ] MCP tool results are displayed in chat
- [ ] Users can configure MCP servers
- [ ] MCP integration is optional (can be disabled)
- [ ] Existing Ollama functionality unchanged
- [ ] Test coverage for MCP features >= 70%
- [ ] Documentation updated
- [ ] CI pipeline passing

---
*Requirements defined for MCP integration*
*V1 = Current state, V2 = MCP-enabled version*
*E-Mail features excluded (user has existing MCP integration)*
