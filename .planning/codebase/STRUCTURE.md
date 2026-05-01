# Project Structure

## Directory Layout

```
Ollamac/
├── .github/
│   └── FUNDING.yml           # GitHub Sponsors configuration
├── .gitignore
├── LICENSE                   # Apache License 2.0
├── README.md                 # Project documentation
├── appcast.xml               # Sparkle update feed
├── assets/                   # Marketing assets (screenshots, banners)
├── Ollamac/                  # Main source directory
│   ├── App/
│   │   ├── AppUpdater.swift  # Sparkle update wrapper
│   │   └── OllamacApp.swift   # App entry point
│   ├── Extensions/
│   │   ├── Color+Hex.swift              # Hex color parsing
│   │   ├── Defaults+Keys.swift          # User defaults keys
│   │   ├── Optional+Utils.swift          # Optional helpers
│   │   ├── String+IsValidURL.swift       # URL validation
│   │   ├── String+ReplaceAndTrim.swift   # String utilities
│   │   ├── String+RemoveTrailingSlash.swift # Path utilities
│   │   └── Theme+Ollamac.swift          # Markdown theme
│   ├── Models/
│   │   ├── Chat.swift    # Chat entity (SwiftData model)
│   │   └── Message.swift # Message entity (SwiftData model)
│   ├── Resources/
│   │   ├── Assets.xcassets/   # App icons, accent colors
│   │   │   ├── AccentColor.colorset/
│   │   │   │   └── Contents.json
│   │   │   └── AppIcon.appiconset/
│   │   │       └── Contents.json
│   │   └── Info.plist           # App configuration
│   ├── Sheets/
│   │   ├── UpdateOllamaHostSheet.swift    # Host configuration
│   │   └── UpdateSystemPromptSheet.swift  # System prompt configuration
│   ├── Utils/
│   │   ├── CodeBlockView.swift    # Custom markdown code block
│   │   ├── CodeHighlighter.swift  # Syntax highlighting wrapper
│   │   └── SectionFooter.swift    # UI helper component
│   ├── ViewModels/
│   │   ├── ChatViewModel.swift    # Manages chats, selection
│   │   └── MessageViewModel.swift  # Manages messages, generation
│   ├── Views/
│   │   ├── AppView.swift          # Root view (NavigationSplitView)
│   │   ├── Chats/
│   │   │   ├── ChatPreferencesView.swift    # Chat settings inspector
│   │   │   ├── ChatView.swift              # Main chat view
│   │   │   └── Subviews/
│   │   │       ├── AssistantMessageView.swift
│   │   │       ├── ChatFieldFooterView.swift
│   │   │       ├── ChatPreferencesFooterView.swift
│   │   │       ├── CircleButton.swift
│   │   │       ├── MessageButton.swift
│   │   │       └── UserMessageView.swift
│   │   ├── Settings/
│   │   │   ├── GeneralView.swift       # General settings
│   │   │   ├── SettingsView.swift       # Settings tab container
│   │   │   └── Subviews/
│   │   │       ├── Box.swift
│   │   │       └── DefaultFontSizeField.swift
│   │   │   └── ExperimentalView.swift   # Experimental features
│   │   └── Sidebar/
│   │       ├── SidebarContextMenu.swift
│   │       ├── SidebarListItemView.swift
│   │       ├── SidebarToolbarContent.swift
│   │       └── SidebarView.swift
│   └── Preview Content/
│       └── Preview Assets.xcassets/
│           └── Contents.json
├── Ollamac.xcodeproj/
│   ├── project.pbxproj        # Xcode project file
│   ├── project.xcworkspace/
│   │   └── contents.xcworkspacedata
│   └── xcshareddata/
│       └── xcschemes/
│           └── Ollamac.xcscheme
└── assets/                    # Marketing assets (external)
    ├── banner-dark.jpg
    ├── banner.jpg
    ├── screenshot-dark.png
    └── screenshot.png
```

## File Count by Directory

| Directory | Swift Files | Other Files | Total |
|-----------|-------------|-------------|-------|
| App/ | 2 | 0 | 2 |
| Extensions/ | 7 | 0 | 7 |
| Models/ | 2 | 0 | 2 |
| Resources/ | 0 | 3 (json) | 3 |
| Sheets/ | 2 | 0 | 2 |
| Utils/ | 3 | 0 | 3 |
| ViewModels/ | 2 | 0 | 2 |
| Views/ | 2 | 0 | 2 |
| Views/Chats/ | 1 | 0 | 1 |
| Views/Chats/Subviews/ | 6 | 0 | 6 |
| Views/Settings/ | 2 | 0 | 2 |
| Views/Settings/Subviews/ | 2 | 0 | 2 |
| Views/Sidebar/ | 4 | 0 | 4 |
| Preview Content/ | 0 | 1 (json) | 1 |
| **Total** | **36** | **4** | **40** |

## File Organization

### By Type
- **App Entry**: 1 file (OllamacApp.swift)
- **Models**: 2 files (Chat.swift, Message.swift)
- **ViewModels**: 2 files (ChatViewModel.swift, MessageViewModel.swift)
- **Views**: 17 files (including all subdirectories)
- **Sheets**: 2 files
- **Utils**: 3 files
- **Extensions**: 7 files
- **App**: 1 file (AppUpdater.swift)

### By Responsibility
| Responsibility | Files | Lines (approx) |
|---------------|-------|--------------|
| Data Models | 2 | ~120 |
| ViewModels | 2 | ~360 |
| Main Views | 4 | ~400 |
| Subviews | 11 | ~600 |
| Settings | 4 | ~150 |
| Sheets | 2 | ~130 |
| Extensions | 7 | ~80 |
| Utils | 3 | ~170 |
| App | 2 | ~130 |

## Naming Conventions

### Files
- **PascalCase**: All Swift files (e.g., `ChatViewModel.swift`)
- **Group by feature**: Views grouped in subdirectories (Chats/, Settings/, Sidebar/)
- **Suffix convention**: 
  - `View.swift`: SwiftUI views
  - `ViewModel.swift`: View models
  - `Sheet.swift`: Modal sheets
  - `+Extension.swift`: Extensions

### Types
- **Structs**: Default for views and value types
- **Classes**: Used when reference semantics needed (CodeHighlighter) or for @Model (Chat, Message)
- **Enums**: Used for error types and loading states
- **Protocols**: Minimal use (only CodeSyntaxHighlighter)

### SwiftUI Components
- Prefixed with view type: `UserMessageView`, `AssistantMessageView`, `SidebarListItemView`
- Helper components: `CircleButton`, `MessageButton`, `SectionFooter`, `Box`
- Container views: `AppView`, `ChatView`, `SettingsView`

## Module Boundaries

### Tight Coupling
- ChatView <-> ChatViewModel <-> MessageViewModel (mutual environment dependencies)
- ChatView <-> ChatField (external framework)
- MessageViewModel <-> OllamaKit (API dependency)
- Views <-> CodeHighlighter (environment dependency)

### Loose Coupling
- Models independent of views/viewmodels
- Extensions stateless and pure
- Sheets decoupled via callback closures
- Settings views use @Default for direct UserDefaults access

## Component Sizes

### Large Files (>200 lines)
| File | Lines | Responsibility |
|------|-------|----------------|
| MessageViewModel.swift | 226 | Message generation, streaming, regeneration |
| ChatPreferencesView.swift | 192 | Chat settings inspector |
| AssistantMessageView.swift | 114 | Assistant message rendering with markdown |

### Medium Files (100-200 lines)
| File | Lines | Responsibility |
|------|-------|----------------|
| ChatView.swift | 204 | Main chat view with scrolling |
| SidebarView.swift | 119 | Sidebar list with grouping |
| CodeHighlighter.swift | 82 | Syntax highlighting wrapper |
| ChatViewModel.swift | 135 | Chat management, model loading |
| CodeBlockView.swift | 89 | Custom code block rendering |

### Small Files (<100 lines)
- All other files are concise and focused
- Extensions are particularly small (10-30 lines)

## Import Structure

### Most Common Imports
| Import | Count | Purpose |
|--------|-------|---------|
| SwiftUI | 32+ | UI framework |
| Foundation | 15+ | Core types |
| OllamaKit | 8 | API client |
| Defaults | 8 | User defaults |
| SwiftData | 4 | Persistence |
| MarkdownUI | 4 | Markdown rendering |
| ViewCondition | 4 | Conditional views |

### View Layer Imports
```swift
import SwiftUI
import Defaults
import OllamaKit
import SwiftData
import MarkdownUI
import ViewCondition
```

### ViewModel Layer Imports
```swift
import Defaults
import OllamaKit
import SwiftData
import SwiftUI
```

### Model Layer Imports
```swift
import Defaults
import Foundation
import OllamaKit
import SwiftData
```

## Resource Files

### Assets
- **AppIcon.appiconset**: Full icon set for macOS
- **AccentColor.colorset**: App accent color
- **Preview Assets**: Empty (no preview assets)

### Configuration
- **Info.plist**: App metadata, Sparkle configuration
  - HELP_URL: GitHub issues
  - SUEnableInstallerLauncherService: true
  - SUFeedURL: GitHub appcast
  - SUPublicEDKey: Sparkle signing key

## Build Configuration

### Targets
- Single target: Ollamac
- macOS deployment target: 14.0

### Frameworks (Embedded)
| Framework | Embed | Purpose |
|-----------|-------|---------|
| Sparkle | Dynamic | Auto-updates |
| Defaults | Dynamic | User defaults |
| ChatField | Dynamic | Input component |
| OllamaKit | Dynamic | Ollama API |
| Highlightr | Dynamic | Syntax highlighting |
| MarkdownUI | Dynamic | Markdown rendering |
| ViewState | Dynamic | State management |
| ViewCondition | Dynamic | Conditional views |
| SwiftUIIntrospect | Dynamic | Runtime introspection |
| AppInfo | Dynamic | Bundle info |

### No Tests Target
- No unit tests configured
- No UI tests configured
- No test plans

## Access Control
- **Public**: Minimal (only Theme extensions)
- **Internal**: Default (all files)
- **File-private**: Not used
- **Private**: Used for computed properties and helper methods

## Visibility Patterns
- ViewModels expose public properties for views
- Models use internal access
- Extensions use internal access
- No access control keywords used (Swift defaults to internal)
