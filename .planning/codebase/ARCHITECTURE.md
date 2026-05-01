# Software Architecture

## Overview
Ollamac follows a **clean MVVM (Model-View-ViewModel)** architecture with SwiftUI's declarative paradigm. The app is organized around chat sessions with streaming AI responses.

## Architecture Pattern: MVVM

```
┌─────────────────────────────────────────────────────────────┐
│                         VIEW LAYER                              │
│  AppView ↔ NavigationSplitView ↔ SidebarView ↔ ChatView      │
│  SettingsView ↔ GeneralView ↔ ExperimentalView               │
│  Sheets: UpdateOllamaHostSheet, UpdateSystemPromptSheet        │
└─────────────────────────┬───────────────────────────────────┘
                          │ @Environment
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                      VIEWMODEL LAYER                            │
│  ChatViewModel ───── MessageViewModel ───── CodeHighlighter     │
│  @Observable          @Observable          @Observable          │
│  @MainActor          @MainActor                              │
└─────────────────────────┬───────────────────────────────────┘
                          │ @Environment
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                         MODEL LAYER                             │
│  Chat (SwiftData) ──── Message (SwiftData)                     │
│  @Model               @Model                                   │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                      EXTERNAL LAYER                             │
│  OllamaKit ───── SwiftData ───── Defaults ───── Sparkle          │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow

### Primary Flow: User Sends Message
```
1. User types in ChatField
2. generateAction() called in ChatView
3. MessageViewModel.generate() creates Message
4. Message.toOKChatRequestData() formats request
5. OllamaKit.chat() streams response
6. Chunks appended to tempResponse
7. On completion: Message.response set, Chat.modifiedAt updated
8. SwiftData auto-persists
9. UI updates via @Observable
```

### Chat Selection Flow
```
1. User selects chat in SidebarView
2. chatViewModel.activeChat set
3. messageViewModel.load(of: activeChat) fetches messages
4. ChatView displays messages
5. OllamaKit reconfigured with chat's host
6. Models fetched for current host
```

## State Management

### Observable State
- **ChatViewModel**: @MainActor @Observable
  - chats: [Chat]
  - activeChat: Chat?
  - selectedChats: Set<Chat>
  - models: [String]
  - loading: ChatViewModelLoading?
  - error: ChatViewModelError?
  - shouldFocusPrompt: Bool
  - isHostReachable: Bool

- **MessageViewModel**: @MainActor @Observable
  - messages: [Message]
  - tempResponse: String
  - loading: MessageViewModelLoading?
  - error: MessageViewModelError?

- **CodeHighlighter**: @Observable
  - fontSize: Double
  - enabled: Bool
  - colorScheme: ColorScheme
  - stateHashValue: Int (for view invalidation)

### Environment Injection
- ViewModels passed via `.environment()` in OllamacApp
- CodeHighlighter passed via `.environment()`
- SwiftData ModelContainer passed via `.modelContainer()`

### User Defaults
- App-wide settings stored in Defaults/Keys
- Accessed via @Default property wrapper
- Persists across app launches

## Component Hierarchy

### App Structure
```
OllamacApp
├── WindowGroup
│   └── AppView
│       ├── NavigationSplitView
│       │   ├── Sidebar (master)
│       │   │   └── SidebarView
│       │   │       ├── List (chats)
│       │   │       │   └── SidebarListItemView
│       │   │       └── SidebarToolbarContent
│       │   └── Chat (detail)
│       │       └── ChatView
│       │           ├── ScrollViewReader
│       │           │   └── List (messages)
│       │           │       ├── UserMessageView
│       │           │       └── AssistantMessageView
│       │           │           └── Markdown
│       │           │               └── CodeBlockView
│       │           └── ChatField
│       │               └── ChatFieldFooterView
│       └── Settings
│           └── SettingsView
│               ├── GeneralView
│               │   ├── Box
│               │   │   └── DefaultFontSizeField
│               │   └── UpdateOllamaHostSheet
│               │   └── UpdateSystemPromptSheet
│               └── ExperimentalView
└── Commands
    ├── SidebarContextMenu
    └── Keyboard shortcuts
```

### Inspector Panel
- ChatPreferencesView (shown as inspector)
  - Model picker with refresh
  - Host configuration
  - System prompt configuration
  - Temperature slider
  - Top P slider
  - Top K stepper

## Module Responsibilities

### App Module (`App/`)
- App lifecycle management
- Window/scene configuration
- Keyboard shortcuts
- Auto-update handling
- Environment setup

### Models Module (`Models/`)
- Data entities (Chat, Message)
- SwiftData model definitions
- Business logic on models
- Transformation methods (toOKChatRequestData)

### ViewModels Module (`ViewModels/`)
- State management
- Business logic
- API integration (OllamaKit)
- Data fetching/persistence
- Error handling

### Views Module (`Views/`)
- UI components
- User interaction
- Data presentation
- Navigation

### Utils Module (`Utils/`)
- CodeHighlighter (syntax highlighting)
- CodeBlockView (custom markdown component)
- SectionFooter (UI helper)

### Extensions Module (`Extensions/`)
- Defaults+Keys (user defaults keys)
- String extensions (RemoveTrailingSlash, IsValidURL, ReplaceAndTrim)
- Color+Hex (hex color parsing)
- Theme+Ollamac (markdown theme)
- Optional+Utils (nil handling)

### Sheets Module (`Sheets/`)
- Modal dialogs
- Form inputs
- Validation logic

## Concurrency Model

### Main Thread
- All UI updates on MainActor
- ViewModels marked @MainActor
- SwiftUI views automatically run on main

### Background Tasks
- `Task { ... }` for async operations
- `Task.detached` not used (all tasks inherit main actor)
- Generation runs in background, UI updates via `defer { self.loading = nil }`

### Cancellation
- `generationTask: Task<Void, Never>?` stored in MessageViewModel
- `messageViewModel.cancelGeneration()` sets task to nil
- `Task.isCancelled` checked in streaming loops

### Streaming
- `for try await chunk in ollamaKit.chat(data: data)`
- Chunks processed sequentially
- tempResponse accumulated on main actor

## Error Handling

### Error Types
- ChatViewModelError: .fetchModels(String), .load(String)
- MessageViewModelError: .load(String), .generate(String), .generateTitle(String)

### Error Propagation
1. API errors caught in Task
2. Converted to ViewModel error enum
3. UI observes error state
4. Error displayed in ChatField footer or sheets

### Recovery
- "Try Again" button for fetch models errors
- Automatic retry on host change
- No exponential backoff implemented

## Persistence Strategy

### SwiftData
- Schema: Chat, Message
- Relationship: Chat ↔ Message (one-to-many, cascade delete)
- Storage: SQLite (default)
- Loading: On-demand per chat
- Sorting: By modifiedAt (descending for chats)

### Fetch Patterns
- ChatViewModel.load(): All chats, sorted by modifiedAt
- MessageViewModel.load(of:): Messages for specific chat, sorted by createdAt

## Separation of Concerns

| Concern | Layer | Responsibility |
|---------|-------|----------------|
| UI Rendering | Views | Display data, handle user input |
| State | ViewModels | Manage mutable state |
| Business Logic | ViewModels | Process user actions |
| Data | Models | Define data structure |
| Persistence | Models + SwiftData | Store/retrieve data |
| API | OllamaKit | Network communication |
| Configuration | Defaults | User preferences |
| Auto-update | Sparkle | Update management |

## Design Patterns Used

1. **MVVM**: Primary architecture pattern
2. **Observer**: @Observable for state changes
3. **Repository**: SwiftData as data repository
4. **Factory**: Message.toOKChatRequestData() transforms domain to API model
5. **Strategy**: CodeHighlighter can be enabled/disabled
6. **Builder**: OKChatRequestData construction
7. **Singleton**: ThemeCache.shared

## Anti-Patterns to Note
- ViewModels passed via environment (SwiftUI convention, but can be hard to test)
- Business logic mixed with UI in some places (being addressed in Phase 2)
- No clear separation between domain and API models

---

## Phase 1 & 2 Architecture Updates

### New ChatBackend Protocol Layer

**Added in Phase 1**: Protocol abstraction for all chat backends.

```swift
protocol ChatBackend: Sendable {
    var baseURL: URL { get }
    var backendType: String { get }
    func reachable() async -> Bool
    func listModels() async throws -> [String]
    func chat(request: ChatRequest) async throws -> AsyncThrowingStream<ChatResponseChunk, Error>
}
```

**Implementations**:
- `OllamaBackend`: Wraps existing OllamaKit functionality
- `MCPBackend`: MCP server integration (Phase 1 skeleton)

### Dependency Injection Pattern

**Added in Phase 1**: SwiftUI Environment-based DI.

```
// Environment Key
private struct ChatBackendEnvironmentKey: EnvironmentKey {
    static let defaultValue: any ChatBackend = OllamaBackend(baseURL: Defaults[.defaultHost])
}

extension EnvironmentValues {
    var chatBackend: any ChatBackend {
        get { self[ChatBackendEnvironmentKey.self] }
        set { self[ChatBackendEnvironmentKey.self] = newValue }
    }
}

// Usage in ViewModels
@Environment(ChatBackend.self) private var chatBackend

// Injection in Views
.environment(\.chatBackend, backend)
```

**Benefits**:
- No direct OllamaKit instantiation in views
- Easy to swap backends for testing
- Supports multiple backend types (Ollama, MCP, etc.)
- Type-safe protocol interface

### Service Layer (Phase 2)

**Added in Phase 2**: ChatService for business logic extraction.

```swift
@MainActor
final class ChatService: ObservableObject {
    private(set) var chatBackend: any ChatBackend
    private var messageViewModel: MessageViewModel?
    private var chatViewModel: ChatViewModel?
    
    func setViewModels(chatViewModel: ChatViewModel, messageViewModel: MessageViewModel)
    func updateChatBackend(_ chatBackend: any ChatBackend)
    func generate(activeChat: Chat, prompt: String)
    func regenerate(activeChat: Chat)
    func cancelGeneration()
}
```

**Responsibilities**:
- Manages ChatBackend instance lifecycle
- Coordinates between ChatViewModel and MessageViewModel
- Handles message generation actions
- Maintains active chat state

### Updated Data Flow (Phase 1-2)

**User Sends Message**:
```
1. User types in ChatField
2. generateAction() called in ChatView
3. ChatView delegates to chatService.generate()
4. ChatService calls messageViewModel.generate()
5. MessageViewModel uses @Environment(ChatBackend.self)
6. ChatBackend.chat() streams response via OllamaBackend or MCPBackend
7. Chunks processed and accumulated
8. On completion: Message.response set, Chat.modifiedAt updated
9. SwiftData auto-persists
10. UI updates via @Observable
```

**Backend Switching**:
```
1. User changes active chat with different host
2. ChatView.onActiveChatChanged() triggered
3. ChatService.updateChatBackend() creates new OllamaBackend
4. ChatView updates .environment(\.chatBackend, newBackend)
5. All ViewModels automatically receive new backend via environment
6. fetchModels() called with new backend
```

### New Module: ChatBackend

**Location**: `Ollamac/ChatBackend/`

**Files**:
- `ChatBackend.swift`: Protocol + supporting types (ChatRole, ChatMessage, ChatOptions, ChatRequest, ChatResponseChunk)
- `ChatBackendEnvironment.swift`: Environment key for DI
- `OllamaBackend.swift`: OllamaKit adapter
- `MCPBackend.swift`: MCP server backend (skeleton)
- `Clients/MCPClient.swift`: MCP client protocol + types
- `Clients/HTTPMCPClient.swift`: HTTP-based MCP client implementation

### New Module: Services

**Location**: `Ollamac/Services/`

**Files**:
- `ChatService.swift`: Chat coordination service

### Updated Component Responsibilities

| Concern | Layer | Responsibility |
|---------|-------|----------------|
| UI Rendering | Views | Display data, handle user input |
| UI Coordination | Services | Coordinate between ViewModels, manage backend |
| State | ViewModels | Manage mutable state |
| Business Logic | ViewModels + Services | Process user actions |
| Backend Abstraction | ChatBackend | Protocol + implementations |
| Data | Models | Define data structure |
| Persistence | Models + SwiftData | Store/retrieve data |
| API Integration | Backend Implementations | Network communication |
| Configuration | Defaults | User preferences |
| Auto-update | Sparkle | Update management |

### New Design Patterns

8. **Protocol-Oriented Design**: ChatBackend protocol for backend abstraction
9. **Dependency Injection**: Environment-based DI for backends
10. **Adapter Pattern**: OllamaBackend adapts OllamaKit to ChatBackend
11. **Service Layer**: ChatService for business logic extraction
12. **Plugin Architecture Foundation**: MCPBackend as first plugin

### Resolved Anti-Patterns
✅ Direct OllamaKit instantiation in ChatView - RESOLVED (via ChatBackend DI)  
✅ No dependency injection for OllamaKit - RESOLVED (via Environment)  
⚠️ Business logic mixed with UI - PARTIALLY RESOLVED (ChatService extracted)  
⚠️ ViewModels passed via environment - STILL EXISTS (SwiftUI convention)  
⚠️ No clear separation between domain and API models - PARTIALLY RESOLVED (ChatRequest types)
