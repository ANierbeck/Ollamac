# External Integrations

## API Integrations

### Ollama Server
- **Type**: REST API (HTTP/JSON)
- **Base URL**: Configurable (default: `http://localhost:11434`)
- **Protocol**: HTTP (no HTTPS by default)
- **Authentication**: None (local server)
- **Timeout**: Not explicitly configured (uses URLSession defaults)

#### Endpoints Used
| Endpoint | Method | Purpose | Implementation |
|----------|--------|---------|----------------|
| `/api/tags` | GET | List available models | `ollamaKit.models()` |
| `/api/chat` | POST | Send chat message (streaming) | `ollamaKit.chat(data:)` |
| `/` or `/api` | GET | Health check / reachability | `ollamaKit.reachable()` |

#### Request/Response Models
- **Request**: `OKChatRequestData`
  - `model`: String (model name)
  - `messages`: [OKChatRequestData.Message]
  - `options`: OKCompletionOptions?
    - `temperature`: Double?
    - `topK`: Int?
    - `topP`: Double?
  - Message roles: `.system`, `.user`, `.assistant`

- **Response**: `OKChatResponse` (streaming chunks)
  - `model`: String
  - `message`: OKChatResponse.Message?
    - `role`: String
    - `content`: String
  - `done`: Bool (indicates stream completion)

#### Streaming Implementation
```swift
for try await chunk in ollamaKit.chat(data: data) {
    // Process each chunk
    tempResponse += chunk.message?.content ?? ""
    if chunk.done { /* complete */ }
}
```

#### Error Handling
- Network errors: Caught and converted to `MessageViewModelError.generate`
- Invalid responses: Handled by OllamaKit
- Unreachable server: Detected via `ollamaKit.reachable()` before requests
- Timeout: Not explicitly handled (URLSession default behavior)

## Third-Party Services

### Sparkle (Auto-Update)
- **Service**: [sparkle-project.org](https://sparkle-project.org/)
- **Purpose**: App auto-updates for macOS
- **Feed URL**: `https://raw.githubusercontent.com/kevinhermawan/Ollamac/main/appcast.xml`
- **Public EdDSA Key**: `xEv1HCqq1iI29hbUSHP7BuExQBfIMupe2d1Xa5bvW2Y=`
- **Integration**: `SPUStandardUpdaterController`

#### Update Flow
1. User triggers "Check for Updates..." or automatic check
2. Sparkle downloads appcast.xml
3. Compares current version with latest
4. Downloads and installs update if available
5. AppUpdater observes `canCheckForUpdates` state

## Data Persistence

### SwiftData
- **Backend**: SQLite (default for SwiftData)
- **Schema Version**: Not explicitly versioned
- **Stored Types**: `Chat`, `Message`

#### Entities
1. **Chat**
   - Stores: id, name, model, host, systemPrompt, temperature, topP, topK, createdAt, modifiedAt
   - Relationship: one-to-many with Message (cascade delete)
   - Index: modifiedAt (used for sorting)

2. **Message**
   - Stores: id, prompt, response, createdAt
   - Relationship: many-to-one with Chat
   - Transient: `model` (derived from chat.model)
   - Computed: `responseText` (strips `<think>` blocks)

#### Storage Location
- macOS default: `~/Library/Application Support/com.kevinhermawan.Ollamac/`
- Shared across all chats

## User Preferences

### Defaults Framework
- **Storage**: UserDefaults (macOS preferences system)
- **Keys**: Defined in `Defaults+Keys.swift`

#### Stored Preferences
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `defaultChatName` | String | "New Chat" | Default name for new chats |
| `defaultModel` | String | "" | Default model for new chats |
| `defaultHost` | String | "http://localhost:11434" | Default Ollama server URL |
| `fontSize` | Double | System font size | Message font size |
| `defaultSystemPrompt` | String | "You're Ollamac, a helpful assistant." | Default system prompt |
| `defaultTemperature` | Double | 0.7 | Default temperature |
| `defaultTopP` | Double | 0.9 | Default top P |
| `defaultTopK` | Int | 40 | Default top K |
| `experimentalCodeHighlighting` | Bool | false | Enable syntax highlighting |

### AppStorage
- Used for settings that need SwiftUI binding
- `experimentalCodeHighlighting`: Toggles code highlighting feature

## Clipboard Integration
- **Framework**: AppKit.NSPasteboard
- **Usage**: Copy message content, copy code blocks
- **Methods**:
  - `NSPasteboard.general.clearContents()`
  - `NSPasteboard.general.setString(_:forType:)`
- **Type**: `.string` (UTF-8 text)

## File System Access
- No direct file system access for user files
- All data stored in SwiftData or UserDefaults
- Asset loading from app bundle (icons, colors)

## Network Security
- **No TLS/SSL**: Connects to localhost via HTTP (not HTTPS)
- **No certificate pinning**: Not implemented
- **No authentication**: Ollama server has no auth by default
- **Host validation**: Basic URL validation via `isValidURL()` extension
- **Reachability check**: Verifies server is responding before use

## Integration Points Summary

| Integration | Type | Direction | Data Flow |
|-------------|------|-----------|-----------|
| Ollama Server | API | Outbound | Request → Stream Response |
| Sparkle | Service | Outbound | Check updates, download |
| UserDefaults | Storage | Local | Read/Write preferences |
| SwiftData | Storage | Local | Read/Write chat data |
| Clipboard | System | Outbound | Write copied text |

## Data Flow Diagram

```
User Input (ChatField)
    ↓
MessageViewModel.generate()
    ↓
Message toOKChatRequestData()
    ↓
OllamaKit.chat(data:)
    ↓
Stream chunks → tempResponse
    ↓
Message.response = accumulated response
    ↓
SwiftData persist
    ↓
UI updates via @Observable
```

## Performance Considerations
- Streaming responses: Minimal memory footprint (chunk-based)
- Syntax highlighting: Disableable via `experimentalCodeHighlighting`
- Chat history: Loaded on-demand per chat
- Model list: Fetched once per chat activation

## Offline Capabilities
- Full offline support for existing chats
- Reading saved conversations
- Copying messages
- Requires Ollama server for generation
