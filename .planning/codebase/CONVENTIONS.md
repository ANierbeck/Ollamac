# Coding Conventions

## Swift Style Guide

### Formatting
- **Indentation**: 4 spaces (Xcode default)
- **Line Length**: No hard limit enforced (no SwiftLint)
- **Braces**: K&R style (opening brace on same line)
- **Line Breaks**: Between logical sections
- **Trailing Commas**: Used in multi-line arrays/dictionaries
- **Semicolons**: Never used (Swift convention)

### Example Code Style
```swift
@MainActor
@Observable
final class ChatViewModel {
    private var modelContext: ModelContext
    
    var chats: [Chat] = []
    var activeChat: Chat? = nil
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func load() {
        do {
            let sortDescriptor = SortDescriptor(\Chat.modifiedAt, order: .reverse)
            let fetchDescriptor = FetchDescriptor<Chat>(sortBy: [sortDescriptor])
            self.chats = try self.modelContext.fetch(fetchDescriptor)
        } catch {
            self.error = .load(error.localizedDescription)
        }
    }
}
```

## Naming Conventions

### Types
- **Classes**: PascalCase (e.g., `ChatViewModel`, `OllamacApp`)
- **Structs**: PascalCase (e.g., `UserMessageView`, `CircleButton`)
- **Enums**: PascalCase (e.g., `ChatViewModelLoading`, `MessageViewModelError`)
- **Protocols**: PascalCase (e.g., `CodeSyntaxHighlighter`)

### Properties & Variables
- **Properties**: camelCase (e.g., `activeChat`, `tempResponse`)
- **Private Properties**: camelCase with underscore prefix for backing storage (e.g., `_chatNameTemp`)
- **Constants**: camelCase (e.g., `defaultHost`, `fontSize`)
- **Static Properties**: camelCase (e.g., `ollamac` theme)

### Functions & Methods
- **Instance Methods**: camelCase (e.g., `generate()`, `load()`, `fetchModels()`)
- **Static Methods**: camelCase (e.g., not used in codebase)
- **Initializers**: No prefix (e.g., `init(model:)`)

### Parameters
- **External**: camelCase (e.g., `model: String`, `activeChat: Chat`)
- **Internal**: camelCase with leading underscore if different from external (e.g., `_ chatViewModel`)
- **Closure Parameters**: Short, descriptive names (e.g., `action: () -> Void`)

### Files
- **PascalCase**: All Swift files (e.g., `ChatViewModel.swift`)
- **Grouping**: By feature/feature area in directories

## Access Control
- **No Explicit Access Control**: All code uses default `internal` access
- **Private**: Used for private backing properties and helper methods
- **Public**: Only used for extensions meant to be used externally (e.g., `Theme.ollamac`)
- **File-private**: Not used
- **Open**: Not used

## Property Wrappers

### SwiftUI
- `@State`: Local view state (e.g., `prompt: String`, `isPresented: Bool`)
- `@Binding`: Two-way binding for child views
- `@Environment`: Access parent environment values (e.g., viewModels, colorScheme)
- `@FocusState`: Manage focus state (e.g., `isFocused`)
- `@AppStorage`: Persist simple values to UserDefaults with SwiftUI binding

### Defaults
- `@Default(.key)`: Access UserDefaults with type-safe keys
- Used for: `fontSize`, `defaultHost`, `defaultModel`, etc.

### SwiftData
- `@Model`: Mark class as SwiftData model
- `@Attribute(.unique)`: Mark property as unique
- `@Relationship(deleteRule: .cascade)`: Define relationship behavior
- `@Transient`: Mark computed property as non-persisted

## Async/Await Patterns

### Task Usage
- All async operations wrapped in `Task { ... }`
- No `Task.detached` usage (all inherit MainActor)
- `Task.isCancelled` checked in long-running operations

### Error Handling in Tasks
```swift
Task {
    defer { self.loading = nil }
    
    do {
        // async work
    } catch {
        self.error = .generate(error.localizedDescription)
    }
}
```

### Streaming
- `for try await chunk in ollamaKit.chat(data: data)`
- Chunks processed sequentially
- Accumulation on main actor: `tempResponse += chunk.message?.content ?? ""`

### Cancellation
- Tasks stored as optional properties: `private var generationTask: Task<Void, Never>?`
- Cancellation via: `generationTask?.cancel()`
- Check in loops: `if Task.isCancelled { break }`

## Error Handling

### Error Types
- Custom enums for view model errors:
  - `ChatViewModelError`: `.fetchModels(String)`, `.load(String)`
  - `MessageViewModelError`: `.load(String)`, `.generate(String)`, `.generateTitle(String)`

### Error Propagation
- Errors caught in Task blocks
- Converted to view model error enums
- UI observes error state via @Observable
- Displayed in UI (e.g., ChatField footer)

### Error Display
- Chat field footer shows error messages
- Sheets show validation errors (e.g., UpdateOllamaHostSheet)
- Error message style: `.foregroundStyle(.red)`

## Optional Handling

### Force Unwrapping
- Used in `OllamacApp.init()`: `guard let activeChat = chatViewModel.selectedChats.first else { return }`
- Minimal use, mostly in early initialization

### Nil Coalescing
- Default values: `message.response ?? tempResponse`
- Empty strings: `self.response ?? ""`

### Optional Chaining
- Safe access: `message.chat?.model`
- Array access: `chat.firstMessage?.responseText`

### Guard Statements
- Early returns with guards for validation
- Example: `guard let activeChat = chatViewModel.activeChat else { return }`

## Comments

### Style
- **File Headers**: Standard Xcode template
  ```swift
  //
  //  FileName.swift
  //  ProjectName
  //
  //  Created by Author on Date.
  //
  ```
- **Function Documentation**: Minimal inline comments
- **Complex Logic**: Some inline comments for regex patterns
- **TODO/FIXME**: Not used

### Usage
- Low comment density (code is self-documenting)
- Comments mainly for file headers and complex regex
- No documentation comments (///) used
- No MARK: comments for section organization

## String Handling

### Localization
- **No Localization**: No localized strings
- All text is hardcoded in English
- No NSLocalizedString usage

### String Literals
- Direct strings for UI text
- Raw strings for error messages
- String interpolation for dynamic values

### Extensions
- Custom string helpers in Extensions/
  - `removeTrailingSlash()`: Removes trailing / from URLs
  - `isValidURL()`: Validates URL format
  - `replaceAndTrim(string:)`: Replaces substring and trims
  - `matches(of:)`: Regex matching
  - `ranges(of:)`: Find all ranges of substring

## Type Usage

### Structs vs Classes
- **Structs**: Default for views, value types
- **Classes**: Used when:
  - Reference semantics needed (CodeHighlighter)
  - @Model required (Chat, Message)
  - ObservableObject conformance needed
  - @Observable macro used

### Value Types
- All models use reference types (classes) for SwiftData
- View state uses value types (structs)
- Configuration objects as structs

### Enums
- Used for:
  - Loading states (ChatViewModelLoading, MessageViewModelLoading)
  - Error types (ChatViewModelError, MessageViewModelError)
  - Message roles (from OllamaKit)
- Raw values not used (associated values not used)

## View Patterns

### View Composition
- Small, focused view components
- Views composed from subviews
- Clear parent-child relationships

### View Modifiers
- Chained modifiers (SwiftUI style)
- Common patterns:
  - `.padding(.horizontal)` / `.padding(.vertical)` / `.padding(.all)`
  - `.foregroundStyle(.secondary)` / `.foregroundStyle(.red)`
  - `.font(.system(size:))`
  - `.cornerRadius()`
  - `.listRowSeparator(.hidden)`

### Conditional Views
- `ViewCondition` framework for conditional rendering:
  - `.visible(if:condition)` - hides but keeps in layout
  - `.hide(if:condition, removeCompletely:true)` - removes completely

### Lists
- `List` with `ForEach` for dynamic content
- `section` headers for grouping
- `.listStyle(.sidebar)` for sidebar
- `.listRowSeparator(.hidden)` for clean look

### Scrolling
- `ScrollViewReader` with proxy for programmatic scrolling
- `scrollTo()` for auto-scrolling to latest message
- DispatchQueue.main.async for scroll operations

## SwiftData Conventions

### Model Definition
```swift
@Model
final class Chat: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    // ... other properties
    
    @Relationship(deleteRule: .cascade)
    var messages: [Message] = []
}
```

### Transient Properties
- Computed properties marked with `@Transient`
- Example: `firstMessage` in Chat
- Not persisted to database

### Relationships
- One-to-many: Chat -> [Message]
- Delete rule: `.cascade` (messages deleted with chat)
- Bidirectional: Message has `chat: Chat?` relationship

## Markdown Handling

### Custom Theme
- `Theme.ollamac` defined in Theme+Ollamac.swift
- Custom CodeBlockView integration
- Custom blockquote styling for `<think>` content

### Think Tag Handling
- `<think>...</think>` blocks converted to blockquotes
- Implemented in AssistantMessageView.convertThinkTagsToMarkdownQuote()
- Regex-based parsing with line-by-line processing

### Code Blocks
- Custom CodeBlockView for rendering
- Copy button integrated
- Syntax highlighting via CodeHighlighter

## Testing Conventions

### Current State
- No unit tests
- No UI tests
- No test target in project
- No test files in codebase

### Testability
- ViewModels use @Observable (hard to test)
- No dependency injection for OllamaKit
- Direct SwiftData usage (hard to mock)
- No protocol-based design for testability

## Accessibility

### Not Implemented
- No accessibility labels
- No accessibility hints
- No VoiceOver support
- No dynamic type support beyond system defaults

### Implicit Support
- SwiftUI built-in accessibility
- System font size respected
- Color contrast (uses system colors)

## Performance

### Concerns Addressed
- Streaming responses (low memory)
- Disableable syntax highlighting
- Lazy loading of chat messages

### Not Optimized
- No pagination for chat history
- All chats loaded at once in SidebarView
- No caching of model lists
- No debouncing on rapid actions

## File Organization

### Imports
- Organized by usage
- No wildcard imports
- Apple frameworks first, then third-party

### File Structure
- Type declarations first
- Properties next
- Initializers
- Methods grouped by functionality
- Computed properties before methods

### Grouping
- Files grouped by feature area
- Subdirectories for related components
- Flat structure within each feature
