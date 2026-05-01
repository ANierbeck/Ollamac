# OllamaKit API Usage Analysis

## Overview
This document analyzes the current usage of OllamaKit in the Ollamac codebase to inform the design of the ChatBackend protocol.

**Analysis Date**: 2024-05-01  
**Purpose**: Define ChatBackend protocol methods based on actual usage  
**Scope**: All files in Ollamac/Ollamac directory

---

## OllamaKit Usage by File

### ChatViewModel.swift (3 usages)

#### Usage 1: Reachability Check
```swift
let isReachable = await ollamaKit.reachable()
```
- **Method**: `reachable()`
- **Return Type**: `Bool`
- **Purpose**: Check if Ollama server is reachable
- **Context**: Called before fetching models
- **Async**: Yes (await)

#### Usage 2: Fetch Models
```swift
let response = try await ollamaKit.models()
self.models = response.models.map { $0.name }
```
- **Method**: `models()`
- **Return Type**: `OKModelsResponse`
- **Purpose**: Get list of available Ollama models
- **Used Properties**: `response.models` (Array of model names)
- **Async**: Yes (await)
- **Error Handling**: Wrapped in do-catch

#### Usage 3: Connection Status
- **Implicit**: Uses `isReachable` to set `self.isHostReachable`

---

### MessageViewModel.swift (3 usages)

#### Usage 1: Generate Message (Streaming)
```swift
for try await chunk in ollamaKit.chat(data: data) {
    if Task.isCancelled { break }
    
    tempResponse = tempResponse + (chunk.message?.content ?? "")
    
    if chunk.done {
        message.response = tempResponse
        activeChat.modifiedAt = .now
        tempResponse = ""
        // ... title generation
    }
}
```
- **Method**: `chat(data: OKChatRequestData)`
- **Return Type**: `AsyncThrowingStream<OKChatResponse, Error>`
- **Parameter**: `OKChatRequestData` (contains model, messages, options)
- **Purpose**: Send chat message and receive streaming response
- **Stream Processing**: 
  - Accumulates `chunk.message?.content` in `tempResponse`
  - Checks `chunk.done` for completion
  - Handles cancellation via `Task.isCancelled`
- **Async**: Yes (for try await)
- **Error Handling**: Wrapped in do-catch

#### Usage 2: Regenerate Message (Streaming)
```swift
for try await chunk in ollamaKit.chat(data: data) {
    // Same structure as generate()
}
```
- **Method**: `chat(data: OKChatRequestData)`
- **Same as Usage 1** above

#### Usage 3: Generate Title (Streaming)
```swift
for try await chunk in ollamaKit.chat(data: OKChatRequestData(model: activeChat.model, messages: requestMessages)) {
    if Task.isCancelled { break }
    
    guard let content = chunk.message?.content else { continue }
    
    // Handle <think> tags
    if content.contains("<think>") { isReasoningContent = true; continue }
    if content.contains("</think>") { isReasoningContent = false; continue }
    
    if !isReasoningContent {
        title += content
        if title.isEmpty == false {
            activeChat.name = title.trimmingCharacters(in: .whitespacesAndNewlines.union(.punctuationCharacters))
        }
    }
    
    if chunk.done {
        activeChat.modifiedAt = .now
    }
}
```
- **Method**: `chat(data: OKChatRequestData)`
- **Same as Usage 1**, but with different data construction
- **Additional Logic**: Handles `<think>` tags specially

---

### UpdateOllamaHostSheet.swift (1 usage)

#### Usage: Reachability Check
```swift
guard await ollamaKit.reachable() else {
    viewState = .error(message: "The Ollama host is not reachable")
    return
}
```
- **Method**: `reachable()`
- **Same as ChatViewModel Usage 1**

---

## Summary: OllamaKit Methods Used

| Method | Return Type | Used In | Count | Streaming | Async |
|--------|-------------|---------|-------|----------|-------|
| `reachable()` | `Bool` | ChatViewModel, UpdateOllamaHostSheet | 2 | No | Yes |
| `models()` | `OKModelsResponse` | ChatViewModel | 1 | No | Yes |
| `chat(data:)` | `AsyncThrowingStream<OKChatResponse, Error>` | MessageViewModel | 3 | **Yes** | Yes |

---

## OllamaKit Types Used

### Input Types

#### OKChatRequestData
- **Purpose**: Request data for chat completion
- **Properties** (from Message.swift):
  - `model: String`
  - `messages: [OKChatRequestData.Message]`
  - `options: OKCompletionOptions?`
    - `temperature: Double?`
    - `topK: Int?`
    - `topP: Double?`

#### OKChatRequestData.Message
- **Purpose**: Individual message in chat request
- **Properties**:
  - `role: OKChatRequestData.Message.Role` (user, assistant, system)
  - `content: String`

### Response Types

#### OKChatResponse
- **Purpose**: Response chunk from chat
- **Properties**:
  - `model: String`
  - `message: OKChatResponse.Message?`
    - `role: String`
    - `content: String`
  - `done: Bool` (indicates stream completion)

#### OKModelsResponse
- **Purpose**: Response from models() call
- **Properties**:
  - `models: [OKModel]`
    - `name: String`
    - (other properties not used in Ollamac)

---

## Derived ChatBackend Protocol Requirements

Based on the actual usage, the ChatBackend protocol needs:

### Required Methods

```swift
protocol ChatBackend: Sendable {
    // Connection
    func reachable() async -> Bool
    
    // Model Management
    func models() async throws -> [String]  // Only model names are used
    
    // Chat Operations
    func chat(data: ChatRequestData) async throws -> AsyncThrowingStream<ChatResponseChunk, Error>
}
```

### Supporting Types

```swift
// Request type (Ollamac-specific, wraps OKChatRequestData)
struct ChatRequestData {
    let model: String
    let messages: [ChatMessage]
    let options: ChatOptions?
}

struct ChatMessage {
    let role: ChatRole  // user, assistant, system
    let content: String
}

struct ChatOptions {
    let temperature: Double?
    let topK: Int?
    let topP: Double?
}

// Response type (Ollamac-specific, wraps OKChatResponse)
struct ChatResponseChunk {
    let model: String
    let message: ChatMessage?
    let done: Bool
}
```

### Key Design Decisions

1. **Return Types Simplified**: 
   - `models()` returns `[String]` instead of `OKModelsResponse` (only names are used)
   
2. **Request/Response Types**:
   - Create Ollamac-specific types that wrap OllamaKit types
   - This decouples from OllamaKit's specific implementations
   
3. **Streaming Support**:
   - `chat()` must return `AsyncThrowingStream` for streaming
   - Chunks must contain `done` flag for completion detection
   
4. **Error Handling**:
   - Both synchronous (`reachable`) and asynchronous (`models`, `chat`) methods
   - Streaming method uses `AsyncThrowingStream` for error propagation

---

## Integration Points

### Current Code Pattern
```swift
// In ChatViewModel
func fetchModels(_ ollamaKit: OllamaKit) {
    let isReachable = await ollamaKit.reachable()
    let response = try await ollamaKit.models()
    self.models = response.models.map { $0.name }
}

// In MessageViewModel
func generate(_ ollamaKit: OllamaKit, activeChat: Chat, prompt: String) {
    let data = message.toOKChatRequestData(messages: self.messages)
    for try await chunk in ollamaKit.chat(data: data) {
        // Process chunk
    }
}
```

### Target Code Pattern (with ChatBackend)
```swift
// In ChatViewModel
func fetchModels() {
    let isReachable = await chatBackend.reachable()
    let models = try await chatBackend.models()
    self.models = models  // Already [String]
}

// In MessageViewModel
func generate(activeChat: Chat, prompt: String) {
    let request = createChatRequest(activeChat: activeChat, prompt: prompt)
    for try await chunk in chatBackend.chat(data: request) {
        // Process chunk
    }
}
```

---

## MCP Integration Considerations

### For MCPBackend Implementation

The MCPBackend will need to:

1. **Implement all ChatBackend methods**:
   - `reachable()` → Check MCP server connection
   - `models()` → Return available models from MCP server (if applicable)
   - `chat(data:)` → Send request to MCP server and stream response

2. **Handle MCP-Specific Logic**:
   - Tool calls from LLM
   - Tool result integration into response stream
   - MCP-specific error handling

3. **Configuration**:
   - MCP server URL/configuration
   - MCP server capabilities

---

## Recommendations

### 1. ChatBackend Protocol Design
```swift
/// Protocol for all chat backends (Ollama, MCP, etc.)
protocol ChatBackend: Sendable {
    /// Check if the backend server is reachable
    func reachable() async -> Bool
    
    /// Get list of available models
    func listModels() async throws -> [String]
    
    /// Send a chat message and receive streaming response
    /// - Parameter request: The chat request containing model, messages, and options
    /// - Returns: Async stream of response chunks
    func chat(request: ChatRequest) async throws -> AsyncThrowingStream<ChatResponseChunk, Error>
    
    /// Base URL of the backend server (for display/diagnostic purposes)
    var baseURL: URL { get }
    
    /// Type of backend (for UI display)
    var backendType: String { get }
}
```

### 2. Request/Response Types
```swift
/// Chat message role
enum ChatRole: String, Codable {
    case user
    case assistant
    case system
}

/// Individual chat message
struct ChatMessage: Codable {
    let role: ChatRole
    let content: String
}

/// Chat completion options
struct ChatOptions: Codable {
    var temperature: Double?
    var topK: Int?
    var topP: Double?
}

/// Complete chat request
struct ChatRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let options: ChatOptions?
}

/// Response chunk from streaming chat
struct ChatResponseChunk: Codable {
    let model: String
    let message: ChatMessage?
    let done: Bool
}
```

### 3. Adapter Pattern for OllamaKit

Instead of refactoring all existing code at once:

```swift
/// Adapter that wraps OllamaKit to conform to ChatBackend
final class OllamaBackend: ChatBackend {
    private let ollamaKit: OllamaKit
    
    init(ollamaKit: OllamaKit) {
        self.ollamaKit = ollamaKit
    }
    
    func reachable() async -> Bool {
        await ollamaKit.reachable()
    }
    
    func listModels() async throws -> [String] {
        let response = try await ollamaKit.models()
        return response.models.map { $0.name }
    }
    
    func chat(request: ChatRequest) async throws -> AsyncThrowingStream<ChatResponseChunk, Error> {
        let data = convertToOKChatRequestData(request)
        var stream = ollamaKit.chat(data: data)
        
        // Convert stream to ChatResponseChunk
        // ... conversion logic
    }
    
    var baseURL: URL { ollamaKit.baseURL }
    var backendType: String { "Ollama" }
}

// Helper to convert between types
private func convertToOKChatRequestData(_ request: ChatRequest) -> OKChatRequestData {
    // Convert ChatMessage to OKChatRequestData.Message
    // Convert ChatOptions to OKCompletionOptions
    // ...
}
```

---

## Conclusion

The ChatBackend protocol needs **3 core methods** to support all current OllamaKit usage:
1. `reachable() async -> Bool`
2. `listModels() async throws -> [String]`
3. `chat(request: ChatRequest) async throws -> AsyncThrowingStream<ChatResponseChunk, Error>`

These methods cover:
- ✅ All 6 OllamaKit usages in the codebase
- ✅ Both synchronous (reachable) and asynchronous operations
- ✅ Streaming chat responses
- ✅ Model listing
- ✅ Error handling

The protocol design should be **minimal** (only what's needed) and **extensible** (can add methods later if needed).

---

## Files Analyzed
- ✅ ChatViewModel.swift
- ✅ MessageViewModel.swift
- ✅ UpdateOllamaHostSheet.swift

## Next Steps
1. Define ChatBackend protocol based on this analysis
2. Create OllamaBackend adapter
3. Refactor ViewModels to use ChatBackend
4. Create MCPBackend skeleton
