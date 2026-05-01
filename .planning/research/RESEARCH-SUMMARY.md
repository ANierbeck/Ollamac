# Research Summary: OllamaKit Usage & ChatBackend Protocol Design

**Date**: 2024-05-01
**Purpose**: Executive summary for Phase 1 protocol design
**Sources**:
- `.planning/research/OllamaKit-API-Usage.md`
- `.planning/research/MCP-Specification-Research.md`

---

## 6 OllamaKit Usages in Codebase

| # | File | Method | Usage | Count |
|---|------|--------|-------|-------|
| 1.1 | ChatViewModel.swift | `reachable()` | Check server connectivity | 1 |
| 1.2 | ChatViewModel.swift | `models()` | Fetch available models | 1 |
| 2.1 | MessageViewModel.swift | `chat(data:)` | Generate message (streaming) | 1 |
| 2.2 | MessageViewModel.swift | `chat(data:)` | Regenerate message (streaming) | 1 |
| 2.3 | MessageViewModel.swift | `chat(data:)` | Generate title (streaming) | 1 |
| 3.1 | UpdateOllamaHostSheet.swift | `reachable()` | Validate host connection | 1 |

**Methods Used**: `reachable()`, `models()`, `chat(data:)`

---

## Derived ChatBackend Protocol Methods

```swift
protocol ChatBackend: Sendable {
    // Connection
    func reachable() async -> Bool

    // Model Management
    func listModels() async throws -> [String]

    // Chat Operations (Streaming)
    func chat(request: ChatRequest) async throws -> AsyncThrowingStream<ChatResponseChunk, Error>

    // Properties
    var baseURL: URL { get }
    var backendType: String { get }
}
```

**Rationale**:
- `reachable()`: Used in 2 files (ChatViewModel, UpdateOllamaHostSheet)
- `listModels()`: Replaces `models()` returning only names (simplified from `OKModelsResponse`)
- `chat(request:)`: Unified interface for all 3 streaming usages in MessageViewModel

---

## Supporting Types (from OllamaKit Analysis)

### Request Types

```swift
enum ChatRole: String, Codable {
    case user
    case assistant
    case system
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
```

### Response Types

```swift
struct ChatResponseChunk: Codable {
    let model: String
    let message: ChatMessage?
    let done: Bool
}
```

**Mapping from OllamaKit**:
- `OKChatRequestData` → `ChatRequest`
- `OKChatRequestData.Message` → `ChatMessage`
- `OKCompletionOptions` → `ChatOptions`
- `OKChatResponse` → `ChatResponseChunk`

---

## MCP Integration Considerations

**Transport**: HTTP + JSON-RPC 2.0
**Streaming**: AsyncThrowingStream for compatibility with existing code
**Phase 1 Scope**: Basic ChatBackend conformance without tool call handling

**MCPBackend Skeleton**:
```swift
final class MCPBackend: ChatBackend {
    private let config: MCPServerConfig
    private let mcpClient: MCPClient

    var baseURL: URL { config.url }
    var backendType: String { "MCP" }

    func reachable() async -> Bool { /* check via mcpClient */ }
    func listModels() async throws -> [String] { /* return tool names */ }
    func chat(request: ChatRequest) async throws -> AsyncThrowingStream<ChatResponseChunk, Error> { /* streaming */ }
}
```

---
## Key Design Decisions

1. **Minimal Interface**: Only 3 methods based on actual usage
2. **Sendable**: Thread-safe for Swift concurrency
3. **Codable Types**: All supporting types are Codable for serialization
4. **Streaming**: `AsyncThrowingStream` matches existing `chat(data:)` usage pattern
5. **Simplified Models**: `listModels()` returns `[String]` (only names used in codebase)

---
## Files Analyzed
- ChatViewModel.swift
- MessageViewModel.swift
- UpdateOllamaHostSheet.swift
