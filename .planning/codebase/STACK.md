# Technology Stack

## Overview
Ollamac is a native macOS application built with modern Apple technologies and SwiftUI framework.

## Platform
- **Target OS**: macOS 14.0 Sonoma or later
- **Architecture**: Apple Silicon & Intel (Universal Binary)
- **Deployment**: Standalone .app bundle with embedded frameworks

## Language & Runtime
- **Primary Language**: Swift 5.9+
- **Swift Concurrency**: Async/await, Tasks, Actors
- **Minimum Swift Version**: 5.9 (inferred from `@Observable` usage)

## Core Frameworks

### Apple Frameworks
| Framework | Purpose | Usage |
|-----------|---------|-------|
| SwiftUI | UI layer | Primary UI framework |
| SwiftData | Persistence | Chat & Message model storage |
| Combine | Reactive | Limited use (AppUpdater) |
| Foundation | Core types | Throughout |
| AppKit | macOS APIs | NSFont, NSPasteboard, NSApplication |

## Build System
- **Project Format**: Xcode project (Xcode 15+)
- **Build Configuration**: Debug & Release
- **No Package.swift**: Uses Xcode project with embedded frameworks
- **Resource Management**: Asset catalogs for icons and colors

## External Dependencies (Frameworks)

### Via Sparkle Project
| Framework | Version | Source | Purpose |
|-----------|---------|--------|---------|
| **Sparkle** | 2.x | [sparkle-project/Sparkle](https://github.com/sparkle-project/Sparkle) | App auto-updates |

### Via Swift Package Manager (Embedded)
| Framework | Version | Source | Purpose |
|-----------|---------|--------|---------|
| **Defaults** | Latest | [sindresorhus/Defaults](https://github.com/sindresorhus/Defaults) | User defaults wrapper |
| **ChatField** | Latest | [kevinhermawan/ChatField](https://github.com/kevinhermawan/ChatField) | Rich text input component |
| **OllamaKit** | Latest | [kevinhermawan/OllamaKit](https://github.com/kevinhermawan/OllamaKit) | Ollama API client |
| **Highlightr** | Latest | [raspu/Highlightr](https://github.com/raspu/Highlightr) | Syntax highlighting |
| **MarkdownUI** | Latest | [gonzalezreal/swift-markdown-ui](https://github.com/gonzalezreal/swift-markdown-ui) | Markdown rendering |
| **ViewCondition** | Latest | [kevinhermawan/ViewCondition](https://github.com/kevinhermawan/ViewCondition) | Conditional view modifiers |
| **ViewState** | Latest | [kevinhermawan/ViewState](https://github.com/kevinhermawan/ViewState) | Loading/error state management |
| **SwiftUIIntrospect** | Latest | [siteline/swiftui-introspect](https://github.com/siteline/swiftui-introspect) | Runtime view introspection |
| **AppInfo** | N/A | Custom | Bundle info access |

## Dependency Graph
```
Ollamac
├── Sparkle (Auto-update)
├── Defaults (User preferences)
│   └── Stores: host, model, systemPrompt, temperature, topP, topK, fontSize
├── ChatField (Input)
│   └── Rich text input with accessories
├── OllamaKit (API)
│   ├── HTTP client for Ollama server
│   ├── Models: OKChatRequestData, OKChatResponse
│   └── Streaming chat responses
├── MarkdownUI (Rendering)
│   ├── Parses assistant responses
│   ├── Custom theme (.ollamac)
│   └── CodeBlockView integration
├── Highlightr (Syntax Highlighting)
│   ├── Theme: atom-one-dark / atom-one-light
│   └── Experimental feature (toggleable)
├── ViewCondition (UI Helpers)
│   └── .visible(), .hide() modifiers
├── ViewState (State Management)
│   └── Loading/error states in sheets
└── SwiftUIIntrospect (Debug)
    └── Runtime view inspection
```

## Toolchain
- **Xcode**: 15.0+ (required for Swift 5.9 features)
- **Swift Format**: Not configured (no .swift-format file)
- **SwiftLint**: Not configured
- **Git**: Version control
- **GitHub**: Hosting, Releases, Issues

## Platform Requirements
- macOS 14.0+ (Sonoma)
- Ollama installed and running locally
- At least one Ollama model pulled
- Internet connection for auto-updates (optional)

## Swift Features Used
- `@Observable` macro (Swift 5.9+)
- `Sendable` conformance
- `Task` and `TaskGroup`
- `async/await`
- `MainActor`
- `@Transient` property wrapper (SwiftData)
- `@Attribute` property wrapper (SwiftData)
- `@Relationship` property wrapper (SwiftData)
- `Identifiable` protocol
- `Hashable` conformance
- `Equatable` conformance
- Property wrappers: `@State`, `@Binding`, `@Environment`, `@Default`, `@AppStorage`, `@FocusState`
- View modifiers: `.onAppear`, `.onChange`, `.onDisappear`, `.task`, `.sheet`, `.alert`, `.confirmationDialog`
- Regex: `Regex`, `String.matches(of:)`, `String.ranges(of:)`
