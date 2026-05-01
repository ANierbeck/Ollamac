# Testing

## Overview
**Ollamac has no formal testing infrastructure.** No test target exists in the Xcode project, and no test files are present in the codebase.

## Test Infrastructure

### Test Target
- **Status**: Does not exist
- **Type**: None
- **Framework**: None configured

### Test Files
- **Count**: 0 test files
- **Location**: None
- **Naming**: N/A

## Testing Approach

### Manual Testing
The project appears to rely entirely on manual testing:
- Developer testing during development
- User testing via GitHub releases
- Issue reporting via GitHub Issues

### Automated Testing
- **Unit Tests**: None
- **UI Tests**: None
- **Integration Tests**: None
- **Snapshot Tests**: None
- **Performance Tests**: None

## Test Coverage

### Estimated Coverage: 0%
- No tests = no coverage
- All code paths untested
- No CI testing pipeline

### Critical Areas Without Tests
| Area | Risk | Test Difficulty |
|------|------|----------------|
| MessageViewModel.generate() | High | Medium (requires mocking OllamaKit) |
| MessageViewModel.regenerate() | High | Medium |
| ChatViewModel.fetchModels() | High | Medium |
| Message.toOKChatRequestData() | Medium | Low (pure function) |
| Stream processing | High | High (async, requires mocking) |
| Error handling | Medium | Medium |
| SwiftData persistence | Medium | High (requires test container) |
| UI rendering | Low | High (UI tests needed) |

## Testability Analysis

### Blockers to Testing

1. **No Dependency Injection**
   - OllamaKit instantiated directly in ChatView
   - No protocol abstraction for network layer
   - ViewModels created with real ModelContext

2. **SwiftUI Architecture**
   - @Observable ViewModels difficult to test
   - Environment injection pattern hard to mock
   - Views tightly coupled to ViewModels

3. **No Test Target**
   - Cannot add tests without project changes
   - No test bundle configuration

4. **Async Code**
   - Heavy use of async/await
   - Streaming responses difficult to test
   - Task cancellation logic complex to verify

### Potential Testing Strategies

#### Unit Testing ViewModels
```swift
// Hypothetical approach (not implemented)
protocol OllamaKitProtocol {
    func models() async throws -> OKModelsResponse
    func chat(data: OKChatRequestData) -> AsyncThrowingStream<OKChatResponse, Error>
    func reachable() async -> Bool
}

class MockOllamaKit: OllamaKitProtocol {
    var modelsResponse: OKModelsResponse?
    var chatResponses: [OKChatResponse]
    var isReachable: Bool = true
    
    func models() async throws -> OKModelsResponse { modelsResponse! }
    func chat(data: OKChatRequestData) -> AsyncThrowingStream<OKChatResponse, Error> { ... }
    func reachable() async -> Bool { isReachable }
}
```

#### SwiftData Testing
```swift
// Hypothetical approach
let config = ModelConfiguration(isStoredInMemoryOnly: true)
let container = try! ModelContainer(for: Chat.self, configurations: config)
let context = ModelContext(container)
// Test with in-memory store
```

#### UI Testing
- Xcode UI Testing framework
- Test user journeys:
  - Create new chat
  - Send message
  - Switch between chats
  - Update settings
  - Copy messages

## Test Organization (If Implemented)

### Recommended Structure
```
OllamacTests/
├── UnitTests/
│   ├── ModelsTests/
│   │   ├── ChatTests.swift
│   │   └── MessageTests.swift
│   ├── ViewModelsTests/
│   │   ├── ChatViewModelTests.swift
│   │   └── MessageViewModelTests.swift
│   ├── ExtensionsTests/
│   │   └── StringExtensionsTests.swift
│   └── UtilsTests/
│       └── CodeHighlighterTests.swift
├── UITests/
│   ├── ChatUITests.swift
│   ├── SidebarUITests.swift
│   └── SettingsUITests.swift
└── IntegrationTests/
    └── OllamaIntegrationTests.swift
```

### Test Naming
- `test[Feature]_[Scenario]_[ExpectedResult]`
- Example: `testMessage_toOKChatRequestData_includesSystemPrompt`

## Test Dependencies

### Required for Testing
| Dependency | Purpose | Status |
|------------|---------|--------|
| XCTest | Test framework | Available (Apple) |
| @testable import Ollamac | Import app code | Would work |
| Mocking framework | Create mocks | Not configured |
| Snapshot testing | UI verification | Not configured |

### Recommended Additions
- **Mocking**: Use protocol-based or Cuckoo/Mockingbird
- **Assertions**: Nimble or XCTAssert
- **Snapshot**: Point-Free/SnapshotTesting
- **Coverage**: Enable code coverage in Xcode

## CI/CD Testing

### Current State
- **GitHub Actions**: Not configured (no .github/workflows/)
- **Build Verification**: None
- **Test Automation**: None
- **Release Process**: Manual (GitHub Releases)

### Recommended CI Pipeline
```yaml
name: Build & Test

on: [push, pull_request]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - run: xcodebuild -project Ollamac.xcodeproj -scheme Ollamac -destination 'platform=macOS'
  
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - run: xcodebuild test -project Ollamac.xcodeproj -scheme Ollamac -destination 'platform=macOS'
```

## How to Run Tests (If They Existed)

### Command Line
```bash
# Build and run tests
xcodebuild test \
  -project Ollamac.xcodeproj \
  -scheme Ollamac \
  -destination 'platform=macOS'

# With coverage
xcodebuild test \
  -project Ollamac.xcodeproj \
  -scheme Ollamac \
  -destination 'platform=macOS' \
  -enableCodeCoverage YES
```

### Xcode
1. Open Ollamac.xcodeproj
2. Select Ollamac scheme
3. Cmd+U to run tests
4. View results in Test Navigator

## Test Data

### Fixtures Needed
- Sample OKChatResponse for streaming tests
- Sample OKModelsResponse for model fetching tests
- Sample Chat and Message data for persistence tests

### Factory Methods
```swift
// Hypothetical test helpers
 extension Chat {
    static func makeTestChat(model: String = "llama2") -> Chat {
        let chat = Chat(model: model)
        chat.id = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!
        return chat
    }
}
```

## Test Priorities (If Implementing)

### High Priority
1. MessageViewModel streaming logic
2. Chat persistence (SwiftData)
3. OllamaKit integration (reachability, models, chat)
4. Error handling paths
5. Auto-update flow

### Medium Priority
1. View rendering with different states
2. Keyboard shortcuts
3. Clipboard integration
4. Settings persistence
5. Theme switching

### Low Priority
1. Code highlighting performance
2. Markdown rendering edge cases
3. Accessibility (once implemented)
4. Localization (once implemented)

## Known Issues Preventing Testing
1. No test target in Xcode project
2. No dependency injection
3. Tight coupling between layers
4. Heavy use of @MainActor on ViewModels
5. No mockable abstractions

## Recommendations

### Immediate
1. Add test target to Xcode project
2. Create mock abstractions for OllamaKit
3. Add basic unit tests for pure functions

### Short Term
1. Introduce dependency injection for ViewModels
2. Add SwiftData in-memory tests
3. Test critical error paths
4. Set up CI pipeline

### Long Term
1. Add UI tests for main user journeys
2. Implement code coverage reporting
3. Add snapshot tests for UI components
4. Test accessibility features
5. Add performance tests for streaming

## Current Test Status: ❌ No Tests
- **Test Files**: 0
- **Test Coverage**: 0%
- **CI/CD**: Not configured
- **Testability**: Low (architecture not test-friendly)
