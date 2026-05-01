# Technical Concerns & Risks

## Overview
Ollamac is a well-structured, functional macOS app for Ollama. The main concern for **MCP integration** is the **tight coupling** between components, which prevents clean extension. The codebase shows signs of rapid development with pragmatic trade-offs that now need to be addressed for MCP support.

---

## Architecture Concerns

### Tight Coupling (CRITICAL for MCP)
**Severity**: High | **Impact**: MCP Integration

1. **ViewModels <-> Views <-> Environment**
   - ChatViewModel and MessageViewModel passed via `@Environment`
   - Creates circular dependencies
   - **Blocks MCP**: Cannot inject MCP client without refactoring

2. **Direct OllamaKit Instantiation**
   - ChatView creates OllamaKit directly: `OllamaKit(baseURL: baseURL)`
   - No dependency injection
   - **Blocks MCP**: Cannot swap in MCP client

3. **ViewModels Coupled to OllamaKit**
   - MessageViewModel directly uses OllamaKit methods
   - ChatViewModel directly uses OllamaKit methods
   - **Blocks MCP**: No abstraction layer for MCP

**Mitigation**: Introduce protocol-based abstraction for OllamaKit, inject dependencies into ViewModels. This is **required for MCP integration**.

---

## Code Quality Concerns

### Massive View Controllers
**Severity**: Medium | **Impact**: Maintainability

1. **MessageViewModel.swift** (226 lines)
   - Handles: message generation, streaming, regeneration, title generation
   - Multiple responsibilities: API calls, state management, business logic
   - Contains duplicate code for streaming (generate vs regenerate)

2. **ChatPreferencesView.swift** (192 lines)
   - Handles: model selection, host config, system prompt, temperature, topP, topK
   - Mixes UI with business logic

**Mitigation**: Split into smaller components, extract business logic from views. **Not critical for MCP but recommended**.

### Duplicated Code
**Severity**: Medium | **Impact**: Maintainability

1. **Streaming Logic**
   - `generate()` and `regenerate()` methods contain ~80% identical code
   - Same chunk processing, error handling, cancellation logic

2. **Think Tag Handling**
   - Logic duplicated in `AssistantMessageView` and `Message.responseText`

**Mitigation**: Extract common streaming logic, unify think tag handling. **Low priority for MCP**.

---

## Performance Concerns

### Memory Usage
**Severity**: Low | **Impact**: User Experience

1. **All Chats Loaded**
   - SidebarView loads ALL chats on appear
   - No pagination or lazy loading
   - Could be slow with 1000+ chats

2. **Stream Accumulation**
   - tempResponse accumulated on main actor
   - Could block UI with very long responses

**Mitigation**: Implement pagination, offload to background. **Not critical for MCP**.

---

## **REMOVED: Security Concerns (HTTPS)**

### ~~No HTTPS~~ ❌ **NOT APPLICABLE**
**Reason**: Ollamac connects to **localhost** (or LAN) for Ollama.
- localhost is trustworthy - no MITM risk on local machine
- Ollama uses HTTP by default
- HTTPS is not needed for local development tools
- **MCP servers** (if remote) would need their own security, but that's the MCP server's responsibility

**→ R-020 (HTTPS Support) and R-021 (Certificate Pinning) are REMOVED from requirements**

---

## Maintainability Concerns

### No Tests
**Severity**: High | **Impact**: MCP Integration

1. **Zero Test Coverage**
   - No unit tests
   - No UI tests
   - No integration tests
   - **Blocks MCP**: Cannot verify MCP integration works correctly

2. **No Test Infrastructure**
   - No test target
   - No test dependencies
   - No CI pipeline

3. **Unfriendly Architecture**
   - @Observable ViewModels hard to test
   - No dependency injection
   - Tight coupling

**Mitigation**: Add test target, introduce dependency injection, implement CI pipeline. **CRITICAL for MCP**.

### No Documentation
**Severity**: Medium | **Impact**: Maintainability

1. **No API Documentation**
   - No documentation comments
   - No README for developers
   - No contribution guide

2. **No Architecture Documentation**
   - No architecture diagrams
   - No design decisions documented

**Mitigation**: Add documentation, create architecture docs. **Recommended for MCP**.

---

## Technical Debt for MCP Integration

### Critical (Must Fix for MCP)
| Issue | Location | Effort | Impact | MCP Relevance |
|-------|----------|--------|--------|----------------|
| No dependency injection | ChatView, ViewModels | Medium | High | **BLOCKS MCP** |
| No network abstraction | ViewModels | Medium | High | **BLOCKS MCP** |
| No tests | Entire project | High | High | **BLOCKS MCP** |

### High Priority (Should Fix)
| Issue | Location | Effort | Impact | MCP Relevance |
|-------|----------|--------|--------|----------------|
| Streaming code duplication | MessageViewModel | Low | Medium | Improves maintainability |
| Magic strings/numbers | Defaults+Keys, Models | Low | Medium | Cleaner code |
| No error recovery | ViewModels | Medium | Medium | Better UX |

### Low Priority
| Issue | Location | Effort | Impact | MCP Relevance |
|-------|----------|--------|--------|----------------|
| No debouncing | Various | Low | Low | Not critical |
| No pagination | SidebarView | Low | Low | Performance only |
| No code review process | Entire project | Medium | Low | Quality only |

---

## MCP-Specific Concerns

### Current Architecture Limitations
1. **No Plugin System**
   - Cannot add MCP as a plugin/extension
   - Would require significant refactoring
   - **Mitigation**: Start with direct MCP integration, extract to plugin later

2. **No Tool Execution Framework**
   - No infrastructure for executing external tools
   - **Mitigation**: Build MCP client with tool execution support

3. **No Multi-Backend Support**
   - Currently only Ollama supported
   - **Mitigation**: Abstract chat backend to support Ollama + MCP

4. **Streaming + Tool Calls**
   - Current streaming assumes pure text responses
   - **Need**: Support for tool calls within streaming responses
   - **Mitigation**: Extend streaming to handle MCP tool execution

---

## Recommendations for MCP Integration

### Critical (Address Immediately)
1. ✅ **Add dependency injection** - Enable MCP client injection (R-001)
2. ✅ **Create network abstraction** - Support Ollama + MCP (R-002)
3. ✅ **Add test infrastructure** - Verify MCP integration (R-010-R-017)

### High Priority (Next)
1. ✅ **Implement MCP client** - Core MCP functionality
2. ✅ **Integrate MCP in chat flow** - Tool calls during chat
3. ✅ **Add MCP server management** - Configure MCP servers

### Medium Priority
1. ✅ **Add tool execution framework** - Generic tool support
2. ✅ **Handle tool results in streaming** - Seamless UX
3. ✅ **Add comprehensive tests** - Ensure reliability

---

## Risk Assessment

| Risk Category | Severity | Likelihood | Overall Risk | MCP Impact |
|--------------|----------|------------|-------------|------------|
| Architecture (Tight Coupling) | High | High | **Critical** | **BLOCKS MCP** |
| Maintainability (No tests) | High | High | **Critical** | **BLOCKS MCP** |
| Code Quality (Duplication) | Medium | Medium | Medium | Minor |
| Performance (No caching) | Medium | Medium | Medium | Minor |

**Overall MCP Integration Risk: HIGH** (due to architecture issues)

The combination of tight coupling and no tests creates significant risk for MCP integration. Addressing the critical architecture items (DI, abstraction, tests) would enable MCP integration.

**Good News**: The user already has a working MCP integration for emails with Vibe/Claude, so we only need to:
1. Make Ollamac architecture support MCP
2. Integrate the existing MCP server for emails
3. Test the integration

The MCP server itself doesn't need to be built - just the client-side integration in Ollamac.
