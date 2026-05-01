# Phase 1: ChatBackend Abstraction - Execution Plan

## Overview
**Phase Number**: 1  
**Phase Name**: ChatBackend Abstraction  
**Milestone**: MCP Architecture Foundation  
**Duration**: 1-2 weeks  
**Status**: Not started  
**Research**: Completed (see `.planning/research/OllamaKit-API-Usage.md` and `.planning/research/MCP-Specification-Research.md`)

---

## Research Summary

**Based on research documents:**
1. **OllamaKit-API-Usage.md**: Analyzed all 6 OllamaKit usages in codebase
   - Only 3 methods used: `reachable()`, `models()`, `chat(data:)`
   - Defined minimal ChatBackend protocol requirements
   
2. **MCP-Specification-Research.md**: Complete MCP integration research
   - HTTP + JSON-RPC 2.0 transport recommended
   - ChatBackend protocol design with code examples
   - MCP architecture for Ollamac

**Key Finding**: ChatBackend protocol only needs **3 core methods** to support all current usage.

---

## Phase Goals
1. **Create ChatBackend Protocol**: Abstract OllamaKit behind a protocol interface
2. **Refactor to OllamaBackend**: Adapt existing code to use the protocol
3. **Create MCPBackend Skeleton**: Foundation for MCP integration

---

## Requirements Covered

| Requirement ID | Title | Epic | Research Status |
|----------------|-------|------|-----------------|
| A-001 | Create ChatBackend Protocol | Architecture Adaptation | ✅ Completed |
| A-001 (second) | Implement OllamaBackend (refactor existing) | Architecture Adaptation | ✅ Completed |
| A-005 | Create MCPBackend Implementation | Architecture Adaptation | ✅ Completed |

**All Phase 1 requirements have research completed.**

---

## Dependencies

### External Dependencies
- OllamaKit (existing framework)
- Xcode 15+ (Swift 5.9+)
- macOS 14.0+ (for testing)

### Internal Dependencies
- None (Phase 1 is the foundation)

### Blockers
- None identified (research completed)

---

## Wave-Based Task Breakdown

**Wave Size**: 4 tasks (from config.json)  
**Total Tasks**: 10  
**Waves**: 3 waves

---

### Wave 1: Protocol Definition & Design
**Duration**: 3-5 days  
**Goal**: Define and finalize ChatBackend protocol
**Research**: ✅ Completed (OllamaKit-API-Usage.md)

#### Tasks

##### Task 1.1: Create Research Documentation Summary
- **ID**: RESEARCH-001
- **Description**: Create executive summary of OllamaKit API research
- **Effort**: Small (0.5 day)
- **Priority**: P0
- **Dependencies**: None
- **Research Source**: `.planning/research/OllamaKit-API-Usage.md`
- **Success Criteria**:
  - [ ] Summary document created in `.planning/research/`
  - [ ] Lists all 6 OllamaKit usages
  - [ ] Derives ChatBackend protocol methods
  - [ ] Approved by team
- **Deliverable**: `RESEARCH-SUMMARY.md`
- **Status**: ⬜ Not started

##### Task 1.2: Define ChatBackend Protocol Interface
- **ID**: A-001
- **Description**: Create ChatBackend protocol with 3 core methods based on research
- **Effort**: Medium (2 days)
- **Priority**: P0
- **Dependencies**: RESEARCH-001
- **Research Source**: `.planning/research/OllamaKit-API-Usage.md` (Section: Derived ChatBackend Protocol Requirements)
- **Implementation**:
  ```swift
  /// Protocol for all chat backends (Ollama, MCP, etc.)
  protocol ChatBackend: Sendable {
      /// Check if the backend server is reachable
      func reachable() async -> Bool
      
      /// Get list of available models
      func listModels() async throws -> [String]
      
      /// Send a chat message and receive streaming response
      func chat(request: ChatRequest) async throws -> AsyncThrowingStream<ChatResponseChunk, Error>
      
      /// Base URL of the backend server
      var baseURL: URL { get }
      
      /// Type of backend for UI display
      var backendType: String { get }
  }
  ```
- **Success Criteria**:
  - [ ] Protocol defined in `Sources/ChatBackend/ChatBackend.swift`
  - [ ] All 3 required methods implemented
  - [ ] Protocol is `Sendable` for thread safety
  - [ ] Protocol documented with comments
  - [ ] Code compiles without errors
- **Deliverable**: `ChatBackend.swift`
- **Status**: ⬜ Not started

##### Task 1.3: Define Supporting Types
- **ID**: A-001-support
- **Description**: Create ChatRequest, ChatResponseChunk, and related types
- **Effort**: Small (1 day)
- **Priority**: P0
- **Dependencies**: 1.2
- **Research Source**: `.planning/research/OllamaKit-API-Usage.md` (Section: Supporting Types)
- **Implementation**:
  ```swift
  enum ChatRole: String, Codable {
      case user, assistant, system
  }
  
  struct ChatMessage: Codable {
      let role: ChatRole
      let content: String
  }
  
  struct ChatOptions: Codable {
      var temperature: Double?
      var topK: Int?
      var topP: Double?
  }
  
  struct ChatRequest: Codable {
      let model: String
      let messages: [ChatMessage]
      let options: ChatOptions?
  }
  
  struct ChatResponseChunk: Codable {
      let model: String
      let message: ChatMessage?
      let done: Bool
  }
  ```
- **Success Criteria**:
  - [ ] All types defined and Codable
  - [ ] Types match OllamaKit usage patterns
  - [ ] Code compiles without errors
- **Deliverable**: Types in same file as protocol
- **Status**: ⬜ Not started

##### Task 1.4: Protocol Code Review
- **ID**: A-001-review
- **Description**: Review ChatBackend protocol design with team
- **Effort**: Small (0.5 day)
- **Priority**: P0
- **Dependencies**: 1.2, 1.3
- **Success Criteria**:
  - [ ] Protocol reviewed for completeness
  - [ ] Protocol reviewed for Swift best practices
  - [ ] Protocol approved for implementation
  - [ ] Any changes incorporated
- **Deliverable**: Approved protocol design
- **Status**: ⬜ Not started

**Wave 1 Acceptance Criteria**:
- [ ] Research summary created
- [ ] ChatBackend protocol defined with all required methods
- [ ] Supporting types defined
- [ ] Protocol code reviewed and approved

---

### Wave 2: OllamaBackend Implementation
**Duration**: 3-5 days  
**Goal**: Refactor existing code to use ChatBackend protocol
**Research**: ✅ Completed

#### Tasks

##### Task 2.1: Create OllamaBackend Adapter
- **ID**: A-001-ollama
- **Description**: Implement OllamaBackend conforming to ChatBackend protocol
- **Effort**: Medium (2 days)
- **Priority**: P0
- **Dependencies**: Wave 1 complete
- **Research Source**: `.planning/research/OllamaKit-API-Usage.md` (Section: Adapter Pattern for OllamaKit)
- **Implementation**:
  ```swift
  /// Adapter that wraps OllamaKit to conform to ChatBackend
  final class OllamaBackend: ChatBackend {
      private let ollamaKit: OllamaKit
      
      init(ollamaKit: OllamaKit) {
          self.ollamaKit = ollamaKit
      }
      
      // MARK: - ChatBackend Protocol
      
      func reachable() async -> Bool {
          await ollamaKit.reachable()
      }
      
      func listModels() async throws -> [String] {
          let response = try await ollamaKit.models()
          return response.models.map { $0.name }
      }
      
      func chat(request: ChatRequest) async throws -> AsyncThrowingStream<ChatResponseChunk, Error> {
          let data = convertToOKChatRequestData(request)
          
          return AsyncThrowingStream { continuation in
              Task {
                  do {
                      for try await chunk in ollamaKit.chat(data: data) {
                          if Task.isCancelled { break }
                          
                          let responseChunk = ChatResponseChunk(
                              model: chunk.model,
                              message: chunk.message.map { ChatMessage(role: .assistant, content: $0.content) },
                              done: chunk.done
                          )
                          continuation.yield(responseChunk)
                      }
                      continuation.finish()
                  } catch {
                      continuation.finish(throwing: error)
                  }
              }
          }
      }
      
      var baseURL: URL { ollamaKit.baseURL }
      var backendType: String { "Ollama" }
      
      // MARK: - Private Helpers
      
      private func convertToOKChatRequestData(_ request: ChatRequest) -> OKChatRequestData {
          let messages = request.messages.map { message in
              OKChatRequestData.Message(
                  role: convertRole(message.role),
                  content: message.content
              )
          }
          
          return OKChatRequestData(
              model: request.model,
              messages: messages,
              options: request.options.map { options in
                  OKCompletionOptions(
                      temperature: options.temperature,
                      topK: options.topK,
                      topP: options.topP
                  )
              }
          )
      }
      
      private func convertRole(_ role: ChatRole) -> OKChatRequestData.Message.Role {
          switch role {
          case .user: return .user
          case .assistant: return .assistant
          case .system: return .system
          }
      }
  }
  ```
- **Success Criteria**:
  - [ ] OllamaBackend implements all ChatBackend methods
  - [ ] OllamaBackend wraps existing OllamaKit functionality
  - [ ] All OllamaKit calls go through OllamaBackend
  - [ ] Code compiles without errors
- **Deliverable**: `OllamaBackend.swift`
- **Status**: ⬜ Not started

##### Task 2.2: Refactor ChatViewModel to Use ChatBackend
- **ID**: A-002
- **Description**: Update ChatViewModel to use injected ChatBackend instead of OllamaKit directly
- **Effort**: Medium (2 days)
- **Priority**: P0
- **Dependencies**: 2.1
- **Current Code** (from research):
  ```swift
  func fetchModels(_ ollamaKit: OllamaKit) {
      let isReachable = await ollamaKit.reachable()
      let response = try await ollamaKit.models()
      self.models = response.models.map { $0.name }
  }
  ```
- **Target Code**:
  ```swift
  // ChatBackend injected via environment
  @Environment(ChatBackend.self) private var chatBackend
  
  func fetchModels() {
      self.loading = .fetchModels
      self.error = nil
      
      Task {
          defer { self.loading = nil }
          
          do {
              let isReachable = await chatBackend.reachable()
              
              guard isReachable else {
                  self.error = .fetchModels("Unable to connect to server. Please verify that the server is running and accessible.")
                  return
              }
              
              let models = try await chatBackend.listModels()
              self.models = models
              
              guard !self.models.isEmpty else {
                  self.error = .fetchModels("No models available. Please pull at least one model first.")
                  return
              }
              
              if let host = activeChat?.host, host.isEmpty {
                  self.activeChat?.host = self.models.first
              }
          } catch {
              self.error = .fetchModels(error.localizedDescription)
          }
      }
  }
  ```
- **Success Criteria**:
  - [ ] ChatViewModel accepts ChatBackend via @Environment
  - [ ] No direct OllamaKit instantiation in ChatViewModel
  - [ ] All chat operations use ChatBackend
  - [ ] Existing functionality preserved
- **Deliverable**: Updated `ChatViewModel.swift`
- **Status**: ⬜ Not started

##### Task 2.3: Refactor MessageViewModel to Use ChatBackend
- **ID**: A-003
- **Description**: Update MessageViewModel to use injected ChatBackend instead of OllamaKit directly
- **Effort**: Medium (2 days)
- **Priority**: P0
- **Dependencies**: 2.1
- **Current Code** (from research):
  ```swift
  func generate(_ ollamaKit: OllamaKit, activeChat: Chat, prompt: String) {
      let message = Message(prompt: prompt)
      message.chat = activeChat
      messages.append(message)
      modelContext.insert(message)
      
      self.loading = .generate
      self.error = nil
      
      generationTask = Task {
          defer { self.loading = nil }
          
          do {
              let data = message.toOKChatRequestData(messages: self.messages)
              
              for try await chunk in ollamaKit.chat(data: data) {
                  // ... process chunks
              }
          } catch {
              self.error = .generate(error.localizedDescription)
          }
      }
  }
  ```
- **Target Code**:
  ```swift
  // ChatBackend injected via environment
  @Environment(ChatBackend.self) private var chatBackend
  
  func generate(activeChat: Chat, prompt: String) {
      let message = Message(prompt: prompt)
      message.chat = activeChat
      messages.append(message)
      modelContext.insert(message)
      
      self.loading = .generate
      self.error = nil
      
      // Convert messages to ChatRequest format
      let chatMessages = messages.map { msg in
          ChatMessage(role: .user, content: msg.prompt) // Simplified for now
      }
      
      let request = ChatRequest(
          model: activeChat.model,
          messages: chatMessages,
          options: ChatOptions(
              temperature: activeChat.temperature,
              topK: activeChat.topK,
              topP: activeChat.topP
          )
      )
      
      generationTask = Task {
          defer { self.loading = nil }
          
          do {
              for try await chunk in chatBackend.chat(request: request) {
                  if Task.isCancelled { break }
                  
                  tempResponse = tempResponse + (chunk.message?.content ?? "")
                  
                  if chunk.done {
                      message.response = tempResponse
                      activeChat.modifiedAt = .now
                      tempResponse = ""
                      
                      if messages.count == 1 {
                          self.generateTitle(activeChat: activeChat)
                      }
                  }
              }
              
              // Handle incomplete response
              if !tempResponse.isEmpty {
                  // ... same as before
              }
          } catch {
              self.error = .generate(error.localizedDescription)
          }
      }
  }
  
  private func generateTitle(activeChat: Chat) {
      // Will need separate handling for title generation
      // For now, keep existing logic but adapt to ChatBackend
  }
  ```
- **Success Criteria**:
  - [ ] MessageViewModel accepts ChatBackend via @Environment
  - [ ] No direct OllamaKit instantiation in MessageViewModel
  - [ ] All message operations use ChatBackend
  - [ ] Existing functionality preserved
- **Deliverable**: Updated `MessageViewModel.swift`
- **Status**: ⬜ Not started

##### Task 2.4: Manual Testing of Refactored Code
- **ID**: TEST-001
- **Description**: Test refactored ViewModels with OllamaBackend
- **Effort**: Small (1 day)
- **Priority**: P0
- **Dependencies**: 2.2, 2.3
- **Test Cases**:
  - [ ] Create new chat
  - [ ] Send message
  - [ ] Regenerate response
  - [ ] Switch between chats
  - [ ] Fetch models
  - [ ] Check reachability
- **Success Criteria**:
  - [ ] All existing functionality works
  - [ ] No regressions introduced
  - [ ] ChatBackend abstraction is transparent to users
- **Deliverable**: Test report in `.planning/phases/01/TEST-REPORT.md`
- **Status**: ⬜ Not started

**Wave 2 Acceptance Criteria**:
- [ ] OllamaBackend fully implemented
- [ ] ChatViewModel uses ChatBackend
- [ ] MessageViewModel uses ChatBackend
- [ ] Manual testing passes
- [ ] No direct OllamaKit instantiation in views

---

### Wave 3: MCPBackend Skeleton
**Duration**: 2-3 days  
**Goal**: Create skeleton MCPBackend implementation
**Research**: ✅ Completed (MCP-Specification-Research.md)

#### Tasks

##### Task 3.1: Create MCPClient Interface
- **ID**: A-005-client-interface
- **Description**: Define MCPClient protocol based on research
- **Effort**: Small (0.5 day)
- **Priority**: P0
- **Dependencies**: Wave 1 complete
- **Research Source**: `.planning/research/MCP-Specification-Research.md` (Section: MCP Client Implementation)
- **Implementation**:
  ```swift
  protocol MCPClient: Sendable {
      func connect() async throws
      func disconnect() async
      func listTools() async throws -> [MCPTool]
      func callTool(name: String, arguments: [String: Any]) async throws -> MCPToolResult
  }
  
  // Supporting types
  struct MCPTool: Codable {
      let name: String
      let description: String
      let inputSchema: MCPToolInputSchema
  }
  
  struct MCPToolInputSchema: Codable {
      let type: String
      let properties: [String: MCPPropertySchema]
      let required: [String]?
  }
  
  struct MCPPropertySchema: Codable {
      let type: String
      let description: String?
  }
  
  struct MCPToolResult: Codable {
      let isSuccess: Bool
      let content: [MCPTextContent]
      let error: String?
  }
  
  struct MCPTextContent: Codable {
      let type: String
      let text: String
  }
  ```
- **Success Criteria**:
  - [ ] MCPClient protocol defined
  - [ ] All supporting types defined
  - [ ] Protocol is Sendable
- **Deliverable**: `MCPClient.swift`
- **Status**: ⬜ Not started

##### Task 3.2: Implement HTTPMCPClient
- **ID**: A-005-http-client
- **Description**: Create HTTP-based MCPClient implementation
- **Effort**: Medium (2 days)
- **Priority**: P0
- **Dependencies**: 3.1
- **Research Source**: `.planning/research/MCP-Specification-Research.md` (Section: HTTP MCP Client Implementation)
- **Implementation**:
  ```swift
  final class HTTPMCPClient: MCPClient {
      private let config: MCPServerConfig
      private let urlSession: URLSession
      private var requestID: Int = 0
      
      init(config: MCPServerConfig, urlSession: URLSession = .shared) {
          self.config = config
          self.urlSession = urlSession
      }
      
      func connect() async throws {
          // Test connection by listing tools
          _ = try await listTools()
      }
      
      func disconnect() async {
          // HTTP is stateless
      }
      
      func listTools() async throws -> [MCPTool] {
          let request = createJSONRPCRequest(method: "tools/list", params: [:])
          let response: MCPListToolsResponse = try await sendRequest(request)
          return response.result.tools
      }
      
      func callTool(name: String, arguments: [String: Any]) async throws -> MCPToolResult {
          let params: [String: Any] = ["name": name, "arguments": arguments]
          let request = createJSONRPCRequest(method: "tools/call", params: params)
          let response: MCPCallToolResponse = try await sendRequest(request)
          return response.result
      }
      
      // MARK: - Private Helpers
      
      private func createJSONRPCRequest(method: String, params: [String: Any]) -> [String: Any] {
          requestID += 1
          return ["jsonrpc": "2.0", "id": requestID, "method": method, "params": params]
      }
      
      private func sendRequest<T: Decodable>(_ request: [String: Any]) async throws -> T {
          // Implementation from research
      }
  }
  ```
- **Success Criteria**:
  - [ ] HTTPMCPClient implements MCPClient
  - [ ] JSON-RPC 2.0 format used
  - [ ] Error handling implemented
  - [ ] Code compiles without errors
- **Deliverable**: `HTTPMCPClient.swift`
- **Status**: ⬜ Not started

##### Task 3.3: Create MCPBackend Skeleton
- **ID**: A-005-skeleton
- **Description**: Implement MCPBackend conforming to ChatBackend protocol
- **Effort**: Medium (1 day)
- **Priority**: P0
- **Dependencies**: 3.2, Wave 1 complete
- **Research Source**: `.planning/research/MCP-Specification-Research.md` (Section: Integration with ChatBackend Protocol)
- **Implementation**:
  ```swift
  final class MCPBackend: ChatBackend {
      private let config: MCPServerConfig
      private let mcpClient: MCPClient
      
      init(config: MCPServerConfig, mcpClient: MCPClient) {
          self.config = config
          self.mcpClient = mcpClient
      }
      
      // MARK: - ChatBackend Protocol
      
      var baseURL: URL { config.url }
      var backendType: String { "MCP" }
      
      func reachable() async -> Bool {
          do {
              try await mcpClient.connect()
              return true
          } catch {
              return false
          }
      }
      
      func listModels() async throws -> [String] {
          // MCP servers may not have "models" in the same way
          // Return available tools as "models" for now
          let tools = try await mcpClient.listTools()
          return tools.map { $0.name }
      }
      
      func chat(request: ChatRequest) async throws -> AsyncThrowingStream<ChatResponseChunk, Error> {
          // Phase 1: Basic implementation
          // Convert ChatRequest to MCP format and call MCP server
          // For now, we'll use a simple approach that doesn't handle tool calls
          
          return AsyncThrowingStream { continuation in
              Task {
                  do {
                      // For Phase 1, we'll just call the MCP server's chat method
                      // This is a placeholder - actual implementation depends on MCP server capabilities
                      // In reality, we might need to:
                      // 1. Send initial prompt to LLM via MCP
                      // 2. Detect tool calls in response
                      // 3. Execute tools via MCP client
                      // 4. Feed results back to LLM
                      // But for Phase 1, we just implement the basic streaming
                      
                      // Placeholder: Assume MCP server has a compatible chat method
                      // This will be refined in Phase 2
                      
                      for try await chunk in callMCPChat(request: request) {
                          if Task.isCancelled { break }
                          continuation.yield(chunk)
                      }
                      continuation.finish()
                  } catch {
                      continuation.finish(throwing: error)
                  }
              }
          }
      }
      
      // MARK: - Private Helpers
      
      private func callMCPChat(request: ChatRequest) async throws -> AsyncThrowingStream<ChatResponseChunk, Error> {
          // Placeholder implementation
          // In Phase 1, this might just pass through to a compatible MCP server
          // Or return a simple stream for testing
          
          AsyncThrowingStream { continuation in
              Task {
                  do {
                      // For now, just echo back a simple response
                      // Real implementation in Phase 2
                      let responseChunk = ChatResponseChunk(
                          model: request.model,
                          message: ChatMessage(role: .assistant, content: "Response from MCP backend"),
                          done: true
                      )
                      continuation.yield(responseChunk)
                      continuation.finish()
                  } catch {
                      continuation.finish(throwing: error)
                  }
              }
          }
      }
  }
  ```
- **Success Criteria**:
  - [ ] MCPBackend implements all ChatBackend methods
  - [ ] MCPBackend uses MCPClient internally
  - [ ] Code compiles without errors
- **Deliverable**: `MCPBackend.swift`
- **Status**: ⬜ Not started

##### Task 3.4: Verify MCPBackend Integration
- **ID**: A-005-verify
- **Description**: Verify MCPBackend can be used alongside OllamaBackend
- **Effort**: Small (0.5 day)
- **Priority**: P0
- **Dependencies**: 3.3
- **Success Criteria**:
  - [ ] MCPBackend can be instantiated with config
  - [ ] MCPBackend can be injected into ViewModels
  - [ ] ViewModels work with both OllamaBackend and MCPBackend
- **Deliverable**: Integration test report
- **Status**: ⬜ Not started

**Wave 3 Acceptance Criteria**:
- [ ] MCPClient interface defined
- [ ] HTTPMCPClient implemented
- [ ] MCPBackend skeleton implemented
- [ ] Integration verified

---

## Phase Dependencies

```
Wave 1 (Protocol Definition)
    │
    ├── Task 1.1: Research Summary
    ├── Task 1.2: ChatBackend Protocol
    ├── Task 1.3: Supporting Types
    └── Task 1.4: Protocol Review
        │
        ▼
Wave 2 (OllamaBackend Implementation)
    │
    ├── Task 2.1: OllamaBackend Adapter
    ├── Task 2.2: ChatViewModel Refactor
    ├── Task 2.3: MessageViewModel Refactor
    └── Task 2.4: Manual Testing
        │
        ▼
Wave 3 (MCPBackend Skeleton)
    │
    ├── Task 3.1: MCPClient Interface
    ├── Task 3.2: HTTPMCPClient
    ├── Task 3.3: MCPBackend Skeleton
    └── Task 3.4: Integration Verification
```

**Note**: Waves must be completed sequentially. Tasks within a wave can be parallelized.

---

## Verification Criteria

### Phase Success Criteria
- [ ] ChatBackend protocol defined and documented
- [ ] OllamaBackend implements ChatBackend and works correctly
- [ ] MCPBackend skeleton implements ChatBackend
- [ ] ChatViewModel uses injected ChatBackend
- [ ] MessageViewModel uses injected ChatBackend
- [ ] No direct OllamaKit instantiation in views
- [ ] Manual testing passes for all existing functionality

### Wave Success Criteria

#### Wave 1 Complete
- [ ] Research summary created
- [ ] ChatBackend protocol defined
- [ ] Supporting types defined
- [ ] Protocol reviewed and approved

#### Wave 2 Complete
- [ ] OllamaBackend implemented
- [ ] ChatViewModel refactored
- [ ] MessageViewModel refactored
- [ ] Manual testing passes

#### Wave 3 Complete
- [ ] MCPClient interface defined
- [ ] HTTPMCPClient implemented
- [ ] MCPBackend skeleton created
- [ ] Integration verified

---

## Success Measures

### Quantitative Metrics
| Metric | Target | Measurement Method |
|--------|--------|---------------------|
| Lines of code added | ~800-1200 | Git diff |
| Files created | 4-5 | Git status |
| Files modified | 2-3 | Git status |
| Protocol methods | 3 core + 2 properties | Code inspection |
| Backend implementations | 2 (Ollama + MCP) | Code inspection |
| Test cases passed | 6 | Manual test report |

### Qualitative Metrics
- [ ] Architecture is cleaner and more maintainable
- [ ] DI pattern established for future extensions
- [ ] Plugin foundation laid for MCP integration
- [ ] Code follows Swift conventions and best practices
- [ ] No breaking changes for existing users
- [ ] Code review approved

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation Strategy | Owner |
|------|-------------|--------|---------------------|-------|
| Protocol design incomplete | Medium | High | Thorough research completed (see research docs) | Team |
| Refactoring breaks existing functionality | Medium | Critical | Comprehensive manual testing (Task 2.4) | Developer |
| MCP specification unclear | Low | Medium | Research completed (see MCP-Specification-Research.md) | Team |
| Time estimation inaccurate | Medium | Medium | Daily progress tracking | PM |
| Integration issues between components | Medium | High | Wave-based approach with verification at each stage | Team |

---

## Resource Requirements

### Human Resources
- **Developers**: 1 primary developer
- **Reviewers**: 1 for code review
- **Testers**: 1 for manual testing (can be same as developer)

### Technical Resources
- **Xcode**: 15.0+ (Swift 5.9+)
- **macOS**: 14.0+ (Sonoma)
- **Ollama**: Running instance for testing
- **GitHub**: Repository for code review

### Time Estimate
- **Total**: 1-2 weeks
- **Wave 1**: 3-5 days
- **Wave 2**: 3-5 days
- **Wave 3**: 2-3 days

---

## Verification Checklist

### Pre-Execution
- [ ] Research documents reviewed and understood
- [ ] Development environment set up (Xcode 15+, macOS 14.0+)
- [ ] Ollama server running for testing
- [ ] Git branch created and checked out
- [ ] Team aligned on protocol design

### Post-Wave 1
- [ ] ChatBackend protocol compiles
- [ ] Supporting types defined correctly
- [ ] Protocol reviewed and approved
- [ ] Ready to proceed to Wave 2

### Post-Wave 2
- [ ] OllamaBackend compiles and runs
- [ ] ChatViewModel refactored successfully
- [ ] MessageViewModel refactored successfully
- [ ] Manual testing passes
- [ ] No regressions introduced
- [ ] Ready to proceed to Wave 3

### Post-Wave 3
- [ ] MCPClient interface defined
- [ ] HTTPMCPClient compiles
- [ ] MCPBackend skeleton compiles
- [ ] Integration with ViewModels verified
- [ ] Ready for Phase 2

### Phase Complete
- [ ] All acceptance criteria met
- [ ] Code committed to branch
- [ ] Code review completed
- [ ] Documentation updated

---

## File Structure

```
Ollamac/
├── Sources/
│   └── ChatBackend/
│       ├── ChatBackend.swift          # Protocol + types
│       ├── OllamaBackend.swift        # Ollama implementation
│       ├── MCPBackend.swift           # MCP skeleton
│       └── Clients/
│           ├── MCPClient.swift         # Interface
│           └── HTTPMCPClient.swift     # HTTP implementation
├── Ollamac/
│   ├── ViewModels/
│   │   ├── ChatViewModel.swift        # Modified (uses @Environment)
│   │   └── MessageViewModel.swift     # Modified (uses @Environment)
│   └── ...
└── .planning/
    └── phases/
        └── 01-PLAN.md                  # This file
```

---

## Notes

### Design Decisions
1. **Minimal Protocol**: Only 3 methods based on actual usage analysis
2. **Sendable**: Protocol marked as Sendable for thread safety
3. **Adapter Pattern**: OllamaBackend wraps existing OllamaKit
4. **HTTP Transport**: MCP uses HTTP + JSON-RPC 2.0
5. **Phase 1 Scope**: Basic skeleton, tool calls in Phase 2

### Assumptions
1. OllamaKit API remains stable during development
2. MCP specification version is compatible
3. Existing OllamaKit functionality is preserved
4. Manual testing is sufficient for Phase 1

### Open Questions
1. Should MCPBackend handle tool call detection in Phase 1? **No** - moved to Phase 2
2. Should streaming be implemented in Phase 1? **Basic only** - full streaming in Phase 2
3. How to handle multiple MCP servers? **Out of scope** - Phase 4

---

## Next Steps

1. **Start Wave 1**: Task 1.1 (Research Summary)
2. **After Wave 1**: Review protocol design before Wave 2
3. **After Wave 2**: Test thoroughly before Wave 3
4. **After Wave 3**: Verify integration and prepare for Phase 2
5. **Phase Complete**: Run `/gsd-verify-work` to verify Phase 1

---

## Related Documents
- `.planning/research/OllamaKit-API-Usage.md` - OllamaKit usage analysis
- `.planning/research/MCP-Specification-Research.md` - MCP research
- `.planning/ROADMAP.md` - Overall milestone roadmap
- `.planning/REQUIREMENTS.md` - All milestone requirements

---
*Phase 1 Plan for MCP Architecture Milestone*
*Created: 2024-05-01*
*Status: Ready for execution*
*Research: Completed*
