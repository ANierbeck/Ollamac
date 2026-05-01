# MCP Specification Research

## Overview
**Research Date**: 2024-05-01  
**Purpose**: Understand MCP (Model Context Protocol) requirements for Ollamac integration  
**Status**: Based on MCP specification knowledge and best practices

---

## What is MCP?

**Model Context Protocol (MCP)** is a standard interface for connecting large language models (LLMs) to external tools, APIs, and data sources. It allows LLMs to:

- **Discover** available tools and resources
- **Read** resource content (files, databases, APIs)
- **Call** tools (functions, commands, operations)
- **Receive** structured responses

### Key Concepts

| Concept | Description | Relevance for Ollamac |
|---------|-------------|----------------------|
| **Server** | A process that implements MCP and provides tools/resources | Ollamac will connect to MCP servers |
| **Client** | An LLM or application that uses MCP servers | Ollamac acts as MCP client |
| **Tool** | A callable function that performs an action | E.g., "list_emails", "read_email" |
| **Resource** | Readable data source | E.g., email content, file content |
| **Session** | A connection between client and server | Managed by Ollamac |

---

## MCP Architecture for Ollamac

### Integration Model

```
┌─────────────────────────────────────────────────────────────────┐
│                        Ollamac (MCP Client)                        │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    ChatViewModel                          │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │  Message Processing                                │  │  │
│  │  │                                                      │  │  │
│  │  │  User Message ──► LLM Request ──► LLM Response       │  │  │
│  │  │                    │                                 │  │  │
│  │  │                    ▼                                 │  │  │
│  │  │  ┌───────────────────────────────────────────────┐  │  │  │
│  │  │  │  Tool Call Detection                            │  │  │  │
│  │  │  │  "I need to check my emails"                     │  │  │  │
│  │  │  │       │                                           │  │  │  │
│  │  │  │       ▼                                           │  │  │  │
│  │  │  │  ┌───────────────────────────┐                  │  │  │  │
│  │  │  │  │  MCPBackend                  │                  │  │  │  │
│  │  │  │  │  (implements ChatBackend)    │                  │  │  │  │
│  │  │  │  │                               │                  │  │  │  │
│  │  │  │  │  ┌───────────────────────┐  │                  │  │  │  │
│  │  │  │  │  │ MCP Client              │  │                  │  │  │  │
│  │  │  │  │  │  (connects to MCP server)│  │                  │  │  │  │
│  │  │  │  │  └───────────────┬───────────┘  │                  │  │  │  │
│  │  │  │  │                  │              │                  │  │  │  │
│  │  │  │  │  ┌───────────────▼───────────┐  │                  │  │  │  │
│  │  │  │  │  │  MCP Server Connection    │  │                  │  │  │  │
│  │  │  │  │  │  (e.g., localhost:8080)   │  │                  │  │  │  │
│  │  │  │  │  └───────────────┬───────────┘  │                  │  │  │  │
│  │  │  │  │                  │              │                  │  │  │  │
│  │  │  │  └──────────► MCP Server (external) ►──────────────┘  │  │  │
│  │  │  │          (e.g., user's email MCP server)            │  │  │
│  │  │  └───────────────────────────────────────────────────┘  │  │  │
│  │  └─────────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Chat Flow with MCP

```
User: "What are my recent emails about project X?"
    ↓
Ollamac sends to Ollama:
  {"model": "llama2", "messages": [{"role": "user", "content": "What are my recent..."}]}
    ↓
Ollama responds (with tool call):
  "I need to check your emails. Let me call the list_emails tool..."
  + Tool call request: {"name": "list_emails", "arguments": {"query": "project X"}}
    ↓
Ollamac detects tool call in response
    ↓
MCPBackend executes tool via MCP Client
    ↓
MCP Server returns: [{"subject": "Project X Update", "date": "..."}, ...]
    ↓
MCPBackend integrates tool result into chat context
    ↓
Ollama receives tool result and continues response:
  "Based on your recent emails, I found..."
    ↓
User sees complete response with email information
```

---

## MCP Server Communication

### Transport

MCP uses **JSON-RPC 2.0** over **stdio** or **HTTP** as transport protocols.

For Ollamac integration, we recommend:

| Transport | Pros | Cons | Recommendation |
|-----------|------|------|----------------|
| **stdio** | Simple, universal | Requires subprocess | ❌ Not ideal for macOS GUI |
| **HTTP** | Network-capable, flexible | Slightly more complex | ✅ **Recommended** |
| **SSE** | Real-time streaming | Server support needed | ⚠️ Possible future |

**Decision**: Use **HTTP** for MCP server communication in Ollamac.

### HTTP Endpoints

| Method | Endpoint | Purpose | Request | Response |
|--------|----------|---------|---------|----------|
| POST | `/` | Send JSON-RPC request | JSON-RPC 2.0 | JSON-RPC 2.0 |

### JSON-RPC 2.0 Message Format

#### Request
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/list",
  "params": {}
}
```

#### Response (Success)
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "tools": [
      {
        "name": "list_emails",
        "description": "List emails matching query",
        "inputSchema": {
          "type": "object",
          "properties": {
            "query": {"type": "string"},
            "limit": {"type": "integer"}
          }
        }
      }
    ]
  }
}
```

#### Response (Error)
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "error": {
    "code": -32601,
    "message": "Method not found"
  }
}
```

---

## MCP Methods Required for Ollamac

### Server Capabilities

Ollamac's MCPBackend needs to support:

#### 1. Server Initialization
```swift
/// Initialize connection to MCP server
func initialize(serverConfig: MCPServerConfig) async throws
```

#### 2. Tool Discovery
```swift
/// List all available tools from the MCP server
func listTools() async throws -> [MCPTool]
```

#### 3. Tool Execution
```swift
/// Execute a tool and return the result
func callTool(name: String, arguments: [String: Any]) async throws -> MCPToolResult
```

#### 4. Resource Access (Optional for Phase 1)
```swift
/// List available resources
func listResources() async throws -> [MCPResource]

/// Read a resource
func readResource(uri: String) async throws -> MCPResourceContent
```

---

## Data Types

### MCPServerConfig
```swift
struct MCPServerConfig: Codable {
    /// Unique identifier for this server configuration
    let id: UUID
    
    /// Display name for UI
    let name: String
    
    /// Server URL (e.g., "http://localhost:8080")
    let url: URL
    
    /// Transport type (http, stdio)
    let transport: MCPTransport
    
    /// Whether this server is enabled
    var isEnabled: Bool
    
    /// Optional authentication headers
    let headers: [String: String]?
    
    /// Timeout for requests (seconds)
    let timeout: TimeInterval
}

enum MCPTransport: String, Codable {
    case http
    case stdio
}
```

### MCPTool
```swift
struct MCPTool: Codable {
    /// Unique name of the tool
    let name: String
    
    /// Human-readable description
    let description: String
    
    /// Input schema for tool arguments
    let inputSchema: MCPToolInputSchema
}

struct MCPToolInputSchema: Codable {
    let type: String  // "object"
    let properties: [String: MCPPropertySchema]
    let required: [String]?
}

struct MCPPropertySchema: Codable {
    let type: String  // "string", "integer", "boolean", etc.
    let description: String?
    let enum: [String]?
    // ... other JSON Schema properties
}
```

### MCPToolResult
```swift
struct MCPToolResult: Codable {
    /// Whether the tool call was successful
    let isSuccess: Bool
    
    /// Tool output content
    let content: [MCPTextContent]
    
    /// Error message if not successful
    let error: String?
}

struct MCPTextContent: Codable {
    let type: String  // "text"
    let text: String
}
```

---

## Integration with ChatBackend Protocol

### How MCPBackend Implements ChatBackend

```swift
final class MCPBackend: ChatBackend {
    private let serverConfig: MCPServerConfig
    private let mcpClient: MCPClient
    
    // MARK: - ChatBackend Protocol
    
    var baseURL: URL { serverConfig.url }
    var backendType: String { "MCP" }
    
    func reachable() async -> Bool {
        do {
            // Try to list tools as a health check
            _ = try await mcpClient.listTools()
            return true
        } catch {
            return false
        }
    }
    
    func listModels() async throws -> [String] {
        // MCP servers may not have "models" in the same way as Ollama
        // For now, return empty or list available tools as "models"
        let tools = try await mcpClient.listTools()
        return tools.map { $0.name }
    }
    
    func chat(request: ChatRequest) async throws -> AsyncThrowingStream<ChatResponseChunk, Error> {
        // This is where the magic happens:
        // 1. Send initial request to LLM (via Ollama? or via MCP?)
        // 2. Detect tool calls in LLM response
        // 3. Execute tools via MCP client
        // 4. Feed tool results back to LLM
        // 5. Stream final response to user
        
        // For Phase 1: Just implement basic streaming
        // Tool call detection and execution comes in later phases
        
        // Simple implementation for now:
        return try await handleChatRequest(request)
    }
    
    // MARK: - Private Methods
    
    private func handleChatRequest(_ request: ChatRequest) async throws -> AsyncThrowingStream<ChatResponseChunk, Error> {
        // Phase 1: Basic pass-through to MCP server's chat endpoint
        // Later: Add tool call handling
        
        // For now, assume MCP server has a chat method
        // This will be refined as we understand MCP better
        
        AsyncThrowingStream { continuation in
            Task {
                do {
                    // Convert ChatRequest to MCP format
                    // Call MCP server
                    // Stream responses back
                    // ...
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
```

---

## MCP Client Implementation

### Core MCP Client Interface

```swift
protocol MCPClient: Sendable {
    /// Initialize connection to MCP server
    func connect() async throws
    
    /// Disconnect from MCP server
    func disconnect() async
    
    /// List all available tools
    func listTools() async throws -> [MCPTool]
    
    /// Call a specific tool
    func callTool(name: String, arguments: [String: Any]) async throws -> MCPToolResult
    
    /// List available resources (optional)
    func listResources() async throws -> [MCPResource]
    
    /// Read a resource (optional)
    func readResource(uri: String) async throws -> String
}
```

### HTTP MCP Client Implementation

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
        // HTTP is stateless, nothing to do
    }
    
    func listTools() async throws -> [MCPTool] {
        let request = createJSONRPCRequest(method: "tools/list", params: [:])
        let response: MCPListToolsResponse = try await sendRequest(request)
        return response.result.tools
    }
    
    func callTool(name: String, arguments: [String: Any]) async throws -> MCPToolResult {
        let params: [String: Any] = [
            "name": name,
            "arguments": arguments
        ]
        let request = createJSONRPCRequest(method: "tools/call", params: params)
        let response: MCPCallToolResponse = try await sendRequest(request)
        return response.result
    }
    
    // MARK: - Private Helpers
    
    private func createJSONRPCRequest(method: String, params: [String: Any]) -> [String: Any] {
        requestID += 1
        return [
            "jsonrpc": "2.0",
            "id": requestID,
            "method": method,
            "params": params
        ]
    }
    
    private func sendRequest<T: Decodable>(_ request: [String: Any]) async throws -> T {
        var urlRequest = URLRequest(url: config.url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add custom headers if configured
        config.headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        let requestData = try JSONSerialization.data(withJSONObject: request)
        urlRequest.httpBody = requestData
        
        let (data, response) = try await urlSession.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw MCPError.invalidResponse
        }
        
        guard 200..<300 ~= httpResponse.statusCode else {
            throw MCPError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        // Handle JSON-RPC response
        if let error = json?["error"] as? [String: Any] {
            let code = error["code"] as? Int ?? 0
            let message = error["message"] as? String ?? "Unknown error"
            throw MCPError.serverError(code: code, message: message)
        }
        
        guard let result = json?["result"] else {
            throw MCPError.invalidResponse
        }
        
        let resultData = try JSONSerialization.data(withJSONObject: result)
        return try JSONDecoder().decode(T.self, from: resultData)
    }
}

enum MCPError: Error {
    case invalidResponse
    case httpError(statusCode: Int)
    case serverError(code: Int, message: String)
    case connectionFailed
    case timeout
}
```

---

## Streaming Considerations

### Current Ollama Streaming
```swift
for try await chunk in ollamaKit.chat(data: data) {
    tempResponse += chunk.message?.content ?? ""
    if chunk.done { /* complete */ }
}
```

### MCP Streaming Options

#### Option 1: Server-Sent Events (SSE)
```swift
// Server sends SSE for streaming responses
// Client listens to event stream
```

#### Option 2: JSON-RPC with Streaming
```swift
// Use JSON-RPC notifications for streaming chunks
// Each chunk is a separate notification
```

#### Option 3: HTTP Chunked Responses
```swift
// HTTP response with Transfer-Encoding: chunked
// Parse chunks as they arrive
```

**Recommendation for Phase 1**: Start with **non-streaming** MCP tool calls, then add streaming in Phase 2.

---

## Tool Call Detection

### Problem
When the LLM (Ollama) responds, it may include tool calls that need to be executed via MCP.

### Detection Approach

The LLM response can include tool calls in several formats:

#### Format 1: MCP Standard (Preferred)
```json
{
  "content": "Let me check your emails",
  "tool_calls": [
    {
      "id": "call_123",
      "name": "list_emails",
      "arguments": {"query": "project X"}
    }
  ]
}
```

#### Format 2: Function Calling (Common)
```text
I need to use a tool to answer your question.

<function_calls>
<invoke name="list_emails">
<parameter name="query">project X</parameter>
</invoke>
</function_calls>
```

#### Format 3: Markdown-style
```markdown
I will check your emails now.

[TOOL_CALL]
name: list_emails
arguments: {"query": "project X"}
[/TOOL_CALL]
```

### Detection Implementation

```swift
struct ToolCall {
    let id: String
    let name: String
    let arguments: [String: Any]
}

func detectToolCalls(in text: String) -> [ToolCall] {
    // Try to parse different tool call formats
    
    // 1. Try JSON format
    if let toolCalls = parseJSONToolCalls(from: text) {
        return toolCalls
    }
    
    // 2. Try XML/markdown format
    if let toolCalls = parseMarkdownToolCalls(from: text) {
        return toolCalls
    }
    
    return []
}

func parseJSONToolCalls(from text: String) -> [ToolCall]? {
    // Try to extract JSON from text
    // ...
}
```

---

## Phase 1 Scope for MCP

For **Phase 1 (ChatBackend Abstraction)**, we focus on:

### ✅ In Scope
1. **ChatBackend Protocol** - Define the protocol
2. **OllamaBackend** - Refactor existing code to use protocol
3. **MCPBackend Skeleton** - Create basic structure
4. **MCPClient Interface** - Define the client interface
5. **HTTP MCPClient** - Basic implementation

### ❌ Out of Scope (for Phase 1)
1. **Tool Call Detection** - Will be added in Phase 2
2. **Tool Execution in Chat Flow** - Will be added in Phase 2
3. **Streaming MCP Responses** - Will be added in Phase 2
4. **Resource Access** - Optional, lower priority
5. **UI for MCP Configuration** - Will be added in Phase 4

---

## Research Sources

### Official MCP Resources
- **Specification**: https://modelcontextprotocol.io/specification
- **GitHub**: https://github.com/modelcontextprotocol/specification
- **TypeScript SDK**: https://github.com/modelcontextprotocol/sdk

### Related Projects
- **Claude Code MCP**: https://github.com/sourcegraph/sourcegraph/tree/main/internal/mcp
- **Vibe MCP**: User's existing implementation
- **Ollama MCP**: Community implementations

---

## Conclusion

For Ollamac's MCP integration:

1. **Use HTTP transport** for MCP server communication
2. **Implement 3 core methods** in MCPClient: connect, listTools, callTool
3. **Create MCPBackend** that conforms to ChatBackend protocol
4. **Start simple** in Phase 1 (no tool call detection yet)
5. **Add complexity** in Phase 2 (tool calls, streaming)

The ChatBackend protocol abstraction (Phase 1) provides the foundation for clean MCP integration.

---

## Next Steps

1. **Phase 1**: Complete ChatBackend protocol and OllamaBackend
2. **Research**: Study MCP specification in detail
3. **Phase 2**: Add tool call detection and execution
4. **Phase 2**: Implement streaming for MCP responses
