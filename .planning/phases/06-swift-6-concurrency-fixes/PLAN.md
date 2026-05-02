# Phase 6: Swift 6 Concurrency Fixes - PLAN

## Overview
**Phase**: 6 of 6 (MCP Architecture Milestone)
**Name**: Swift 6 Concurrency Fixes
**Duration**: 1-2 weeks
**Goal**: Fix Sendable conformance errors and MainActor isolation issues discovered during Phase 5 OllamaKit local integration.
**Status**: Not Started

---

## Context

### Current State
- Phase 5 (OllamaKit Local Integration) completed successfully
- OllamaKit is now a local target in Package.swift
- Xcode project removed (Swift 6.3 no longer supports `generate-xcodeproj`)
- Build uses `xcodebuild -scmProvider system` approach
- OllamaKit local source compiles, but multiple concurrency errors remain

### Problem Statement
After integrating OllamaKit as a local target, Swift 6.0 strict concurrency checking reveals several issues:
1. Mutable stored properties in Sendable-conforming classes
2. MainActor-isolated static properties referenced from nonisolated contexts
3. Type mismatches between OllamaKit responses (OKModelResponse, OKGenerateResponse) and Chat plugin types ([String], ChatResponseChunk)
4. Non-final classes attempting to conform to Sendable protocol

These errors were hidden when using the external OllamaKit package with `-strict-concurrency=minimal` flag, but are now exposed with local integration.

### Dependencies
- Phase 5 (OllamaKit Local Integration): COMPLETE
- Swift 6.0+ compiler with strict concurrency checking

---

## Research Summary

**Based on codebase analysis of actual source files:**

### Files Requiring Changes
| File | Issue Count | Issue Types |
|------|-------------|-------------|
| `Ollamac/ChatBackend/Plugins/OllamaPlugin.swift` | 2 | S-001 (mutable property), S-003 (type conversion) |
| `Ollamac/ChatBackend/Plugins/MCPPlugin.swift` | 1 | S-001 (mutable property) |
| `Ollamac/ChatBackend/Clients/HTTPMCPClient.swift` | 2 | S-001 (mutable property), S-004 (non-final class) |
| `Ollamac/ChatBackend/Plugins/PluginManager.swift` | 1 | S-002 (static property isolation) |
| `Ollamac/ChatBackend/Plugins/PluginRegistry.swift` | 1 | S-002 (static property isolation) |
| `Ollamac/ChatBackend/Plugins/PluginConfigStore.swift` | 1 | S-002 (static property isolation) |
| `Ollamac/ChatBackend/Clients/MCPClient.swift` | 1 | S-004 (AnyCodable Sendable issue) |

### Key Findings
1. **ChatBackend protocol** is `Sendable`, flowing through to all ChatPlugin implementations
2. **Plugin classes** have `var config: PluginConfig` - mutable stored properties in Sendable types
3. **HTTPMCPClient** is non-final with mutable `isConnected` property, conforms to Sendable via MCPClient
4. **Singleton static properties** need MainActor isolation
5. **Type mismatches**: OllamaPlugin returns OllamaKit types but ChatBackend requires [String] and ChatResponseChunk
6. **AnyCodable** wraps non-Sendable `Any` type

---

## Requirements

| ID | Task | Effort | Priority | Dependencies | Status | Wave |
|----|------|--------|----------|--------------|--------|-------|
| S-001 | Fix mutable stored properties in Sendable classes (OllamaPlugin, MCPPlugin, HTTPMCPClient, PluginManager, PluginRegistry, PluginConfigStore) | Medium | P0 | None | Not Started | 1 |
| S-002 | Resolve MainActor-isolated static properties in plugin classes | Medium | P0 | S-001 | Not Started | 1 |
| S-003 | Implement type conversion between OKGenerateResponse/OKModelResponse and ChatResponseChunk/[String] in OllamaPlugin | Medium | P0 | S-001 | 1 |
| S-004 | Fix non-final classes conforming to Sendable (HTTPMCPClient, AnyCodable) | Medium | P0 | S-001 | Not Started | 2 |

---

## Phase Goals
1. **S-001**: Make all stored properties in Sendable classes immutable (`let`)
2. **S-002**: Add @MainActor isolation to static singleton properties
3. **S-003**: Implement type conversions between OllamaKit and ChatBackend types
4. **S-004**: Fix non-final Sendable classes and AnyCodable Sendable conformance

---

## Architecture Design

### Sendable Conformance Fixes
Classes conforming to Sendable must have all stored properties as `let` (immutable) or be marked as `@MainActor`:

```swift
// Before (error: mutable stored property in Sendable class)
public final class OllamaPlugin: ChatPlugin {
    public var config: PluginConfig
    public var backendType: String = Self.pluginID
}

// After (fixed)
public final class OllamaPlugin: ChatPlugin {
    public let config: PluginConfig
    public let backendType: String
}
```

### MainActor Isolation Fixes
Static properties accessed from nonisolated contexts need consistent actor isolation:

```swift
// Before (error: main actor-isolated static property cannot be referenced from nonisolated context)
public final class OllamaPlugin: ChatPlugin {
    public static var pluginID: String = "ollama"
}

// After (fixed)
public final class OllamaPlugin: ChatPlugin {
    @MainActor public static var pluginID: String = "ollama"
}
```

### Type Conversion
OllamaKit uses its own response types (OKModelResponse, OKGenerateResponse) which need to be converted to Chat plugin types:

```swift
// Conversion needed in OllamaPlugin
public func listModels() async throws -> [String] {
    let response = try await ollamaKit.models()
    return response.models.map { $0.name }
}

public func chat(request: ChatRequest) async throws -> AsyncThrowingStream<ChatResponseChunk, Error> {
    // Convert OKGenerateRequestData and map OKGenerateResponse to ChatResponseChunk
}
```

---

## Wave-Based Task Breakdown

**Wave Size**: 4 tasks
**Total Tasks**: 12 executable tasks
**Waves**: 3 waves

---

### Wave 1: Sendable Property Fixes (S-001)
**wave: 1**
**Duration**: 2-3 days
**Goal**: Resolve all mutable stored property errors

| Task | ID | File | Effort | Change |
|------|-----|------|--------|--------|
| Fix OllamaPlugin config | S-001.1 | `OllamaPlugin.swift:20` | 0.5h | `var config` → `let config` |
| Fix MCPPlugin config | S-001.2 | `MCPPlugin.swift:18` | 0.5h | `var config` → `let config` |
| Fix HTTPMCPClient isConnected | S-001.3 | `HTTPMCPClient.swift:14` | 1h | Add @MainActor to property + methods |
| Fix singleton shared properties | S-001.4 | PluginManager/Registry/ConfigStore | 0.5h | Add @MainActor to static `shared` |

**Acceptance**: No "mutable stored property of Sendable-conforming class" errors

---

### Wave 2: Type Conversion Implementation (S-003)
**wave: 2**
**Duration**: 2-3 days
**Goal**: Implement type conversions between OllamaKit and ChatBackend types

| Task | ID | File | Effort | Change |
|------|-----|------|--------|--------|
| listModels() conversion | S-003.1 | `OllamaPlugin.swift:38-40` | 1h | Map OKModelResponse.models to [String] |
| chat() conversion | S-003.2 | `OllamaPlugin.swift:42-64` | 2h | Convert OKGenerateResponse stream to ChatResponseChunk stream |

**Acceptance**: No "cannot convert return expression" errors

---

### Wave 3: Final Sendable Fixes (S-004)
**wave: 3**
**Duration**: 1-2 days
**Goal**: Resolve remaining Sendable conformance issues

| Task | ID | File | Effort | Change |
|------|-----|------|--------|--------|
| Make HTTPMCPClient final | S-004.1 | `HTTPMCPClient.swift:11` | 0.5h | `public class` → `public final class` |
| Fix AnyCodable Sendable | S-004.2 | `MCPClient.swift:130` | 2h | Remove Sendable from AnyCodable + MCPClient |
| Verify MCPPlugin | S-004.3 | `MCPPlugin.swift` | 0.5h | Confirm all properties Sendable |
| Final build verification | S-004.4 | All files | 0.5h | Full xcodebuild without errors |

**Acceptance**: Full project builds without concurrency-related errors

---

## File Changes

### Modified Files
```
Ollamac/ChatBackend/Plugins/OllamaPlugin.swift
├── S-001: var config → let config (line 20)
├── S-003: OKModelResponse → [String] in listModels() (lines 38-40)
└── S-003: OKGenerateResponse → ChatResponseChunk in chat() (lines 42-64)

Ollamac/ChatBackend/Plugins/MCPPlugin.swift
└── S-001: var config → let config (line 18)

Ollamac/ChatBackend/Clients/HTTPMCPClient.swift
├── S-001: @MainActor on isConnected + connect()/disconnect()
└── S-004: public class → public final class (line 11)

Ollamac/ChatBackend/Plugins/PluginManager.swift
└── S-002: @MainActor on shared static property (line 15)

Ollamac/ChatBackend/Plugins/PluginRegistry.swift
└── S-002: @MainActor on shared static property (line 15)

Ollamac/ChatBackend/Plugins/PluginConfigStore.swift
└── S-002: @MainActor on shared static property (line 14)

Ollamac/ChatBackend/Clients/MCPClient.swift
└── S-004: Remove Sendable from AnyCodable + MCPClient protocol
```

---

## Success Measures

### Functional Requirements
- [ ] All Sendable conformance errors resolved
- [ ] MainActor isolation issues fixed
- [ ] Type conversions between OllamaKit and Chat types working
- [ ] All non-final Sendable classes made final or refactored

### Quality Requirements
- [ ] No Swift concurrency warnings during build
- [ ] No compiler errors related to Sendable or MainActor
- [ ] Code remains maintainable and readable
- [ ] All existing functionality preserved

### Performance Requirements
- [ ] Build time not significantly increased
- [ ] No performance regressions introduced

---

## Verification Criteria

| Test | Command | Expected |
|------|---------|----------|
| Clean Build | `xcodebuild -scheme Ollamac-Package -configuration Debug clean build` | SUCCESS |
| No Sendable Errors | `xcodebuild 2>&1 \| grep -i sendable` | Empty |
| No MainActor Errors | `xcodebuild 2>&1 \| grep -i mainactor` | Empty |
| No Type Errors | `xcodebuild 2>&1 \| grep -i "cannot convert"` | Empty |

---

## Execution Flow

```
Phase 6 Start
    │
    ▼
Wave 1 (S-001) → Wave 2 (S-003) → Wave 3 (S-004)
    │               │               │
    ▼               ▼               ▼
Property Fixes   Type Conversions  Final Sendable Fixes
    │               │               │
    └───────────────┴───────────────┘
                    │
                    ▼
            Full Build Verification
                    │
                    ▼
              Phase 6 Complete
```

---

## Acceptance Criteria

- [ ] All Sendable conformance errors resolved
- [ ] All MainActor isolation issues fixed
- [ ] Type conversions between OKGenerateResponse/OKModelResponse and ChatResponseChunk/[String] implemented
- [ ] All non-final Sendable classes made final or refactored
- [ ] Build completes successfully without Swift concurrency warnings
- [ ] All existing tests pass with local OllamaKit source
- [ ] No new compiler warnings introduced

---

## Estimates

| Component | Hours | Complexity |
|-----------|-------|------------|
| Sendable property fixes | 3 | Low-Medium |
| MainActor isolation fixes | 1 | Low |
| Type conversions | 3 | Medium |
| Non-final class fixes | 4 | Medium |
| **Total** | **11** | - |

---

## Notes

- This phase is critical for Swift 6.0 compatibility
- Many errors were hidden by external package's `-strict-concurrency=minimal` flag
- Local integration exposes these issues which must be fixed for production
- After this phase, the codebase will be fully Swift 6 concurrency compliant

---
*Generated by Mistral Vibe*
*Co-Authored-By: Mistral Vibe <vibe@mistral.ai>*
*Phase: 6 - Swift 6 Concurrency Fixes*
*Milestone: MCP Architecture Foundation*
