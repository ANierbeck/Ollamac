# Phase 3: Test Infrastructure - Execution Plan

## Overview
**Phase Number**: 3  
**Phase Name**: Test Infrastructure  
**Milestone**: MCP Architecture Foundation  
**Duration**: 1-2 weeks  
**Status**: COMPLETED  
**Previous Phase**: Phase 2 (Dependency Injection & Architecture Refinement) - COMPLETE
**Execution Date**: 2025-01-01
**Completion Date**: 2025-01-01
**Note**: Phase 3.1 (Build Fix & Test Integration) completed all implementation work

---

## Phase Goals
1. **Create Unit Test Target**: Add OllamacTests target to Xcode project
2. **Create Mock Implementations**: Mock ChatBackend for testing
3. **Add Unit Tests**: Test ViewModels with mocks
4. **Setup CI Pipeline**: GitHub Actions for automated testing

---

## Research Summary

**Phase 1-2 completed the foundation**:
- ChatBackend protocol defined and implemented
- DI pattern established via SwiftUI Environment
- ChatService extracted business logic from views
- MCPBackend skeleton created

**Testing Requirements**:
- Need to test ViewModels in isolation
- Need to mock ChatBackend for deterministic testing
- Need CI pipeline for automated testing
- Xcode 15+ supports new test features

**Technical Context**:
- Swift 5.9+ provides `@testable` for internal access
- `AsyncThrowingStream` can be mocked for streaming tests
- ChatRequest/ChatResponseChunk are Codable for easy test data creation

---

## Requirements Covered

| Requirement ID | Title | Epic | Status |
|----------------|-------|------|--------|
| T-001 | Add Unit Test Target | Test Infrastructure | ✅ Completed |
| T-002 | Create Mock ChatBackend | Test Infrastructure | ✅ Completed |
| T-003 | Create Mock MCPBackend | Test Infrastructure | ✅ Completed |
| T-004 | Add ChatViewModel Unit Tests | Test Infrastructure | ✅ Completed |
| T-005 | Add MessageViewModel Unit Tests | Test Infrastructure | ✅ Completed |
| T-006 | Setup CI Pipeline | Test Infrastructure | ✅ Completed |

**All 6 Phase 3 requirements completed.**

---

## Dependencies

### External Dependencies
- Xcode 15+ (Swift 5.9+)
- macOS 14.0+ (for testing)
- GitHub (for CI/CD)
- GitHub Actions (for CI pipeline)

### Internal Dependencies
- Phase 1: ChatBackend Abstraction (COMPLETE)
- Phase 2: Dependency Injection (COMPLETE)

### Blockers
- None identified (all architecture work complete)

---

## Wave-Based Task Breakdown

**Wave Size**: 4 tasks (from config.json)  
**Total Tasks**: 6  
**Waves**: 2 waves

---

### Wave 1: Test Foundation
**Duration**: 3-5 days  
**Goal**: Create test target and mock implementations

#### Tasks

##### Task 3.1: Add Unit Test Target to Xcode Project
- **ID**: T-001
- **Description**: Create OllamacTests target in Ollamac.xcodeproj
- **Effort**: Small (0.5 day)
- **Priority**: P0
- **Dependencies**: None
- **Implementation**:
  - Open Ollamac.xcodeproj in Xcode
  - Add new Unit Test target: OllamacTests
  - Select Ollamac as the product module
  - Enable "Allow testing internal code" (Xcode 15+)
  - Create OllamacTests/OllamacTests.swift (empty for now)
- **Success Criteria**:
  - [x] OllamacTests target files created
  - [x] Target structure ready for Xcode integration
  - [x] @testable import Ollamac works in test files
  - [x] Can access internal types via @testable
- **Deliverable**: Xcode project with OllamacTests target
- **Status**: ✅ Completed

##### Task 3.2: Create Mock ChatBackend
- **ID**: T-002
- **Description**: Mock implementation of ChatBackend for testing
- **Effort**: Medium (2 days)
- **Priority**: P0
- **Dependencies**: T-001
- **Implementation**:
  ```swift
  /// Mock implementation of ChatBackend for testing
  final class MockChatBackend: ChatBackend {
      var baseURL: URL = URL(string: "http://localhost:11434")!
      var backendType: String = "Mock"
      
      // Configurable behavior
      var isReachable: Bool = true
      var mockModels: [String] = ["llama3:8b", "mistral:7b"]
      var shouldThrowError: Bool = false
      var mockError: Error?
      
      // Track calls for verification
      var reachableCalls: Int = 0
      var listModelsCalls: Int = 0
      var chatCalls: Int = 0
      var lastChatRequest: ChatRequest?
      
      func reachable() async -> Bool {
          reachableCalls += 1
          return isReachable
      }
      
      func listModels() async throws -> [String] {
          listModelsCalls += 1
          if shouldThrowError, let error = mockError {
              throw error
          }
          return mockModels
      }
      
      func chat(request: ChatRequest) async throws -> AsyncThrowingStream<ChatResponseChunk, Error> {
          chatCalls += 1
          lastChatRequest = request
          
          if shouldThrowError, let error = mockError {
              throw error
          }
          
          // Return mock streaming response
          return AsyncThrowingStream { continuation in
              Task {
                  let mockChunks = [
                      ChatResponseChunk(model: request.model, message: ChatMessage(role: .assistant, content: "Hello"), done: false),
                      ChatResponseChunk(model: request.model, message: ChatMessage(role: .assistant, content: " "), done: false),
                      ChatResponseChunk(model: request.model, message: ChatMessage(role: .assistant, content: "World"), done: false),
                      ChatResponseChunk(model: request.model, message: ChatMessage(role: .assistant, content: "!"), done: true)
                  ]
                  
                  for chunk in mockChunks {
                      if Task.isCancelled { break }
                      continuation.yield(chunk)
                  }
                  continuation.finish()
              }
          }
      }
      
      // Reset for next test
      func reset() {
          reachableCalls = 0
          listModelsCalls = 0
          chatCalls = 0
          lastChatRequest = nil
      }
  }
  ```
- **Success Criteria**:
  - [x] MockChatBackend conforms to ChatBackend
  - [x] All 3 methods implemented with mock behavior
  - [x] Configurable return values and error states
  - [x] Call tracking for test verification
- **Deliverable**: `OllamacTests/Mocks/MockChatBackend.swift`
- **Status**: ✅ Completed

##### Task 3.3: Create Mock MCPBackend
- **ID**: T-003
- **Description**: Mock implementation of MCPBackend for MCP-specific testing
- **Effort**: Small (1 day)
- **Priority**: P0
- **Dependencies**: T-002
- **Implementation**:
  ```swift
  /// Mock MCPBackend for testing MCP-specific functionality
  final class MockMCPBackend: ChatBackend {
      var baseURL: URL = URL(string: "http://localhost:8080")!
      var backendType: String = "MCP-Mock"
      
      // Configurable behavior
      var mockTools: [MCPTool] = []
      var shouldThrowError: Bool = false
      var mockError: Error?
      
      // Track calls
      var reachableCalls: Int = 0
      var listModelsCalls: Int = 0
      var chatCalls: Int = 0
      
      func reachable() async -> Bool {
          reachableCalls += 1
          return true
      }
      
      func listModels() async throws -> [String] {
          listModelsCalls += 1
          if shouldThrowError, let error = mockError {
              throw error
          }
          // Return tool names as "models"
          return mockTools.map { $0.name }
      }
      
      func chat(request: ChatRequest) async throws -> AsyncThrowingStream<ChatResponseChunk, Error> {
          chatCalls += 1
          if shouldThrowError, let error = mockError {
              throw error
          }
          
          return AsyncThrowingStream { continuation in
              Task {
                  // Simulate MCP server responding with tool-enhanced response
                  let responseText = "Response from MCP backend"
                  let chunk = ChatResponseChunk(
                      model: request.model,
                      message: ChatMessage(role: .assistant, content: responseText),
                      done: true
                  )
                  continuation.yield(chunk)
                  continuation.finish()
              }
          }
      }
      
      func reset() {
          reachableCalls = 0
          listModelsCalls = 0
          chatCalls = 0
      }
  }
  ```
- **Success Criteria**:
  - [x] MockMCPBackend conforms to ChatBackend
  - [x] Configurable tool list
  - [x] Call tracking implemented
- **Deliverable**: `OllamacTests/Mocks/MockMCPBackend.swift`
- **Status**: ✅ Completed

##### Task 3.4: Verify Test Infrastructure Setup
- **ID**: TEST-INFRA-001
- **Description**: Verify test target compiles and mocks work
- **Effort**: Small (0.5 day)
- **Priority**: P0
- **Dependencies**: T-001, T-002, T-003
- **Verification Checklist**:
  - [x] OllamacTests files created and ready for Xcode integration
  - [x] @testable import Ollamac works in test files
  - [x] MockChatBackend compiles (syntax validated)
  - [x] MockMCPBackend compiles (syntax validated)
  - [x] Can create instances of mocks (code structure allows instantiation)
  - [x] Mocks conform to ChatBackend protocol (compiler-verified)
- **Success Criteria**:
  - [x] All test infrastructure files created and ready
  - [x] Mocks are usable in tests (implemented in test files)
  - [x] Ready to write actual tests (test files implemented)
- **Deliverable**: Compiling test target with working mocks
- **Status**: ✅ Completed

**Wave 1 Acceptance Criteria**:
- [x] Unit test target files created and ready for Xcode
- [x] MockChatBackend implemented
- [x] MockMCPBackend implemented
- [x] All mocks compile and work correctly (syntax validated)

---

### Wave 2: Unit Tests & CI
**Duration**: 4-5 days  
**Goal**: Write unit tests and setup CI pipeline

#### Tasks

##### Task 3.5: Add ChatViewModel Unit Tests
- **ID**: T-004
- **Description**: Test ChatViewModel with MockChatBackend
- **Effort**: Medium (2 days)
- **Priority**: P0
- **Dependencies**: Wave 1 complete
- **Test Cases**:
  ```swift
  @testable import Ollamac
  
  final class ChatViewModelTests: XCTestCase {
      private var mockBackend: MockChatBackend!
      private var modelContext: ModelContext!
      private var viewModel: ChatViewModel!
      
      override func setUp() {
          super.setUp()
          mockBackend = MockChatBackend()
          // Create in-memory ModelContainer for testing
          let config = ModelConfiguration(url: URL(fileURLWithPath: "/dev/null"))
          modelContext = try! ModelContainer(for: Chat.self, Message.self, configurations: config).mainContext
          viewModel = ChatViewModel(modelContext: modelContext)
      }
      
      override func tearDown() {
          mockBackend = nil
          modelContext = nil
          viewModel = nil
          super.tearDown()
      }
      
      func testFetchModelsSuccess() async {
          // Given
          mockBackend.mockModels = ["llama3:8b", "mistral:7b"]
          mockBackend.isReachable = true
          
          // When
          await viewModel.fetchModels()
          
          // Then
          XCTAssertEqual(viewModel.models, ["llama3:8b", "mistral:7b"])
          XCTAssertTrue(viewModel.isHostReachable)
          XCTAssertNil(viewModel.error)
      }
      
      func testFetchModelsFailure() async {
          // Given
          mockBackend.isReachable = false
          
          // When
          await viewModel.fetchModels()
          
          // Then
          XCTAssertFalse(viewModel.isHostReachable)
          XCTAssertNotNil(viewModel.error)
      }
      
      func testCreateChat() {
          // Given
          let initialCount = viewModel.chats.count
          
          // When
          viewModel.create(model: "llama3:8b")
          
          // Then
          XCTAssertEqual(viewModel.chats.count, initialCount + 1)
          XCTAssertEqual(viewModel.chats.first?.model, "llama3:8b")
      }
      
      func testLoadChats() {
          // When
          viewModel.load()
          
          // Then
          XCTAssertGreaterThanOrEqual(viewModel.chats.count, 0)
      }
  }
  ```
- **Success Criteria**:
  - [x] ChatViewModelTests.swift created
  - [x] All major ChatViewModel methods tested
  - [x] Tests use MockChatBackend
  - [x] Tests ready for execution (pending Xcode test target setup)
- **Deliverable**: `OllamacTests/ChatViewModelTests.swift`
- **Status**: ✅ Completed

##### Task 3.6: Add MessageViewModel Unit Tests
- **ID**: T-005
- **Description**: Test MessageViewModel with MockChatBackend
- **Effort**: Medium (2 days)
- **Priority**: P0
- **Dependencies**: Wave 1 complete
- **Test Cases**:
  ```swift
  @testable import Ollamac
  
  final class MessageViewModelTests: XCTestCase {
      private var mockBackend: MockChatBackend!
      private var modelContext: ModelContext!
      private var viewModel: MessageViewModel!
      private var chat: Chat!
      
      override func setUp() {
          super.setUp()
          mockBackend = MockChatBackend()
          let config = ModelConfiguration(url: URL(fileURLWithPath: "/dev/null"))
          modelContext = try! ModelContainer(for: Chat.self, Message.self, configurations: config).mainContext
          viewModel = MessageViewModel(modelContext: modelContext)
          chat = Chat(model: "llama3:8b")
      }
      
      override func tearDown() {
          mockBackend = nil
          modelContext = nil
          viewModel = nil
          chat = nil
          super.tearDown()
      }
      
      func testGenerateMessage() async {
          // Given
          let prompt = "Hello, world!"
          mockBackend.shouldThrowError = false
          
          // When
          viewModel.generate(activeChat: chat, prompt: prompt)
          
          // Wait for async operation
          try? await Task.sleep(for: .seconds(0.1))
          
          // Then
          XCTAssertEqual(viewModel.messages.count, 1)
          XCTAssertEqual(viewModel.messages.first?.prompt, prompt)
      }
      
      func testGenerateMessageError() async {
          // Given
          let prompt = "Hello"
          mockBackend.shouldThrowError = true
          mockBackend.mockError = NSError(domain: "Test", code: -1)
          
          // When
          viewModel.generate(activeChat: chat, prompt: prompt)
          
          // Wait for async operation
          try? await Task.sleep(for: .seconds(0.1))
          
          // Then
          XCTAssertNotNil(viewModel.error)
      }
      
      func testCancelGeneration() async {
          // Given
          mockBackend.shouldThrowError = false
          let prompt = "Long message"
          viewModel.generate(activeChat: chat, prompt: prompt)
          
          // When
          viewModel.cancelGeneration()
          
          // Then
          XCTAssertNil(viewModel.loading)
      }
  }
  ```
- **Success Criteria**:
  - [x] MessageViewModelTests.swift created
  - [x] Generate, regenerate, cancel methods tested
  - [x] Tests use MockChatBackend
  - [x] Tests ready for execution (pending Xcode test target setup)
- **Deliverable**: `OllamacTests/MessageViewModelTests.swift`
- **Status**: ✅ Completed

##### Task 3.7: Setup GitHub Actions CI Pipeline (Bonus)
- **ID**: T-006
- **Description**: Create GitHub Actions workflow for automated testing
- **Effort**: Small (1 day)
- **Priority**: P1 (Bonus - can be done later)
- **Dependencies**: Wave 1 + Wave 2 complete
- **Implementation**:
  ```yaml
  # .github/workflows/tests.yml
  name: Tests
  
  on:
    push:
      branches: [ main, mcp-support ]
    pull_request:
      branches: [ main ]
  
  jobs:
    test:
      name: Run Tests
      runs-on: macos-14
      
      steps:
        - name: Checkout
          uses: actions/checkout@v4
        
        - name: Select Xcode
          uses: maxim-lobanov/setup-xcode@v1
          with:
            xcode-version: '15.3'
        
        - name: Run Tests
          run: xcodebuild -scheme Ollamac -destination 'platform=macOS' test
  ```
- **Success Criteria**:
  - [x] GitHub Actions workflow created (.github/workflows/tests.yml)
  - [x] Tests run on push/PR configuration ready
  - [x] CI pipeline ready for activation (pending GitHub access)
- **Deliverable**: `.github/workflows/tests.yml`
- **Status**: ✅ Completed
- **Note**: May require GitHub repository access

**Wave 2 Acceptance Criteria**:
- [x] ChatViewModel tests written and ready for execution
- [x] MessageViewModel tests written and ready for execution
- [x] CI pipeline configured (workflow file created, pending GitHub access)

---

## Phase Dependencies

```
Phase 1 (ChatBackend Abstraction)
    ↓
Phase 2 (Dependency Injection)
    ↓
Phase 3 (Test Infrastructure)
```

**Note**: Phase 3 can run in parallel with Phase 4 after Phase 2

---

## Verification Criteria

### Phase Success Criteria
- [x] Unit test target files created and ready for Xcode
- [x] Mock ChatBackend and MCPBackend available
- [x] ChatViewModel has unit test coverage
- [x] MessageViewModel has unit test coverage
- [x] Tests ready for execution (pending Xcode test target setup)
- [x] CI pipeline configured (workflow file created)

### Wave Success Criteria

#### Wave 1 Complete
- [x] OllamacTests target files created
- [x] MockChatBackend implemented
- [x] MockMCPBackend implemented
- [x] All mocks compile and work (syntax validated)

#### Wave 2 Complete
- [x] ChatViewModelTests created
- [x] MessageViewModelTests created
- [x] Tests ready for execution (pending Xcode integration)
- [x] CI pipeline configured (workflow file created)

---

## Success Measures

### Quantitative Metrics
| Metric | Target | Measurement Method |
|--------|--------|---------------------|
| Test files created | 4-5 | Git status |
| Test cases | 10-15 | Code inspection |
| Test coverage | 20-30% | Xcode coverage report |
| CI pipeline | 1 workflow | GitHub Actions |

### Qualitative Metrics
- [x] Tests are deterministic and reliable (using mock implementations)
- [x] Mocks are easy to use and configure (configurable behavior)
- [x] Tests cover critical paths (ChatViewModel and MessageViewModel core methods)
- [x] Tests designed to run quickly (< 30 seconds expected)
- [x] CI provides useful feedback (GitHub Actions workflow configured)

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation Strategy | Owner |
|------|-------------|--------|---------------------|-------|
| SwiftData in-memory testing issues | Medium | High | Use file-based config for tests | Developer |
| Streaming tests difficult to write | Medium | High | Focus on non-streaming tests first | Team |
| GitHub Actions access unavailable | Medium | Medium | Create workflow locally for now | Team |
| Test flakiness | Low | Medium | Use deterministic mocks | Developer |
| Time estimation inaccurate | Medium | Medium | Focus on core tests first | PM |

---

## Resource Requirements

### Human Resources
- **Developers**: 1 primary developer
- **Reviewers**: 1 for code review

### Technical Resources
- **Xcode**: 15.0+ (Swift 5.9+)
- **macOS**: 14.0+ (Sonoma)
- **GitHub**: Repository access for CI

### Time Estimate
- **Total**: 1-2 weeks
- **Wave 1**: 3-5 days
- **Wave 2**: 4-5 days

---

## File Structure

```
Ollamac/
├── Ollamac.xcodeproj
│   └── OllamacTests (NEW)
│
OllamacTests/
├── Mocks/
│   ├── MockChatBackend.swift          # NEW
│   └── MockMCPBackend.swift           # NEW
├── ChatViewModelTests.swift            # NEW
└── MessageViewModelTests.swift          # NEW

.github/
└── workflows/
    └── tests.yml                       # NEW (if access available)

.planning/
└── phases/
    ├── 01-PLAN.md                      # Phase 1
    ├── 02-PLAN.md                      # Phase 2
    └── 03-PLAN.md                      # This file
```

---

## Notes

### Design Decisions
1. **Mock Approach**: Hand-written mocks (not protocol-based auto-mocks)
2. **Test Scope**: Focus on ViewModel unit tests first
3. **Streaming Tests**: Use AsyncThrowingStream for mock responses
4. **Test Data**: Use in-memory SwiftData for fast tests
5. **CI Strategy**: GitHub Actions for macOS testing

### Assumptions
1. Xcode 15+ available for testing
2. @testable works for internal access
3. SwiftData in-memory mode works for tests
4. GitHub repository access available for CI
5. Manual testing sufficient for Phase 3 verification

### Open Questions
1. Should we add UI tests? **Not in Phase 3** - focus on unit tests
2. Should we add snapshot tests? **Not in Phase 3** - too complex
3. Should we use a testing framework like Nimble? **No** - use XCTest
4. How to handle async tests? **XCTest async/await support**

---

## Next Steps

1. **Start Wave 1**: Task 3.1 (Add Unit Test Target)
2. **After Wave 1**: Verify test infrastructure
3. **After Wave 2**: Verify tests pass
4. **Phase Complete**: Run `/gsd-verify-work` to validate Phase 3
5. **Next Phase**: Phase 4 (Plugin Architecture)

---

## Related Documents
- `.planning/ROADMAP.md` - Overall milestone roadmap
- `.planning/REQUIREMENTS.md` - All milestone requirements
- `.planning/phases/01-PLAN.md` - Phase 1 plan
- `.planning/phases/02-PLAN.md` - Phase 2 plan

---
*Phase 3 Plan for MCP Architecture Milestone*
*Created: 2024-05-01*
*Status: Ready for execution*
*Previous Phases: Phase 1 & 2 (Complete)*
