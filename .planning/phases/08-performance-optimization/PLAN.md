//
//  Phase 8: Performance Optimization
//  Ollamac
//
//  Created from Performance Bottleneck Analysis
//

## Phase 8: Performance Optimization
**Duration**: 1-2 weeks  
**Goal**: Address critical performance bottlenecks identified in the codebase audit

---

## Overview

This phase addresses performance issues that affect user experience, particularly with:
- Streaming response handling (string concatenation, scroll jank)
- Memory usage and allocation patterns
- Unnecessary computations and re-renders
- Disk I/O storms from excessive model saves

Based on comprehensive codebase analysis, 10 critical bottlenecks were identified across the chat backend, view models, and UI rendering layers.

---

## Tasks

| Task | ID | Effort | Priority | Dependencies | Status |
|------|-----|--------|----------|--------------|--------|
| Fix string concatenation in MessageViewModel (use array join) | P-001 | Small | P0 | None | ⬜ |
| Throttle scroll updates in ChatView | P-002 | Small | P0 | None | ⬜ |
| Cache ChatRequest conversion on Chat model | P-003 | Medium | P0 | None | ⬜ |
| Cache responseText computation in Message | P-004 | Small | P0 | None | ⬜ |
| Reduce SwiftData model context saves | P-005 | Small | P0 | None | ⬜ |
| Move think tag conversion to data layer | P-006 | Medium | P0 | None | ⬜ |
| Lazy-load plugins (background queue) | P-007 | Medium | P0 | None | ⬜ |
| Create dedicated URLSession for HTTPMCPClient | P-008 | Small | P1 | None | ⬜ |
| Debounce CodeHighlighter state updates | P-009 | Small | P1 | None | ⬜ |
| Deduplicate conversion methods in Message | P-010 | Small | P1 | None | ⬜ |

---

## Acceptance Criteria

- [ ] String concatenation in `MessageViewModel.generate()` uses array join pattern (O(n) → O(n))
- [ ] Scroll updates in `ChatView` are throttled to ≤20fps (no scroll on every chunk)
- [ ] `Chat` model caches `ChatRequest` conversion, invalidates on message changes
- [ ] `Message.responseText` computation cached, not recalculated on every view render
- [ ] `modifiedAt` only updated on generation complete/cancel, not on every chunk
- [ ] Think tag → markdown quote conversion happens once at data layer, not on render
- [ ] Plugin discovery uses background queue, doesn't block main thread
- [ ] `HTTPMCPClient` uses dedicated `URLSession` with custom timeout configuration
- [ ] `CodeHighlighter` state updates are debounced to prevent cascade renders
- [ ] Single canonical conversion method for Message → ChatMessage (no duplication)

---

## Success Criteria

| Metric | Target | Measurement |
|--------|--------|-------------|
| Memory usage (1000-token streaming) | ≤10MB | Instruments / Xcode Memory Graph |
| Scroll FPS during streaming | ≥50 | Visual observation / FPS meter |
| App startup time | <1.0s | Time from launch to interactive |
| CPU time for string ops (1000 tokens) | <10ms | Instruments Time Profiler |
| Disk writes per chat message | ≤2 | File system monitoring |

---

## Technical Details

### P0 Critical Fixes (Must Have)

#### 1. String Concatenation in Streaming (`MessageViewModel.swift`)
**Current**: 
```swift
tempResponse = tempResponse + (chunk.message?.content ?? "")
```
**Problem**: O(n²) complexity - each concatenation copies entire string
**Solution**: 
```swift
private var responseChunks: [String] = []
// On chunk: responseChunks.append(chunk.message?.content ?? "")
// On done: message.response = responseChunks.joined()
// On cancel: tempResponse = responseChunks.joined()
```

#### 2. Scroll Thrashing (`ChatView.swift`)
**Current**: Scroll on every `tempResponse` change
**Problem**: UI jank, ScrollView recalculates layout per character
**Solution**: Throttle to 50ms intervals:
```swift
private var lastScrollTime = Date.distantPast
.onChange(of: messageViewModel.tempResponse) {
    let now = Date()
    if now.timeIntervalSince(lastScrollTime) > 0.05, let proxy = scrollProxy {
        scrollToBottom(proxy: proxy)
        lastScrollTime = now
    }
}
```

#### 3. Excessive Model Saves (`MessageViewModel.swift`)
**Current**: `activeChat.modifiedAt = .now` on every chunk
**Problem**: SwiftData persists on every change, causing disk I/O storms
**Solution**: Only update on done/cancel:
```swift
// Remove from chunk loop
if chunk.done {
    lastMessage.response = tempResponse
    activeChat.modifiedAt = .now  // Only here
    tempResponse = ""
}
```

### P0 High Priority Fixes

#### 4. Cache ChatRequest Conversion (`Message.swift`, `Chat.swift`)
**Current**: Re-creates entire conversation history from scratch on every request
**Solution**: Add cached property on Chat model:
```swift
@Transient var cachedChatRequest: ChatRequest?
func invalidateCachedRequest() { cachedChatRequest = nil }
```

#### 5. Cache responseText Computation (`Message.swift`)
**Current**: Regex runs on every view render
**Solution**: Cache cleaned response:
```swift
private var _cachedResponseText: String?
var responseText: String {
    if let cached = _cachedResponseText { return cached }
    // ... cleanup logic
    _cachedResponseText = result
    return result
}
```

#### 6. Move Think Tag Conversion to Data Layer (`AssistantMessageView.swift`)
**Current**: `convertThinkTagsToMarkdownQuote` runs on every render
**Solution**: Apply conversion when message is received in `MessageViewModel`

### P1 Medium Priority Fixes

#### 7. Lazy-load Plugins (`PluginDiscovery.swift`)
**Current**: Blocks main thread during startup
**Solution**: Dispatch to background queue:
```swift
public func scanForPlugins() async -> [any ChatPlugin.Type] {
    await withTaskGroup(of: [any ChatPlugin.Type].self) { group in
        group.addTask { await self.registerBuiltInPlugins() }
        group.addTask { await self.scanForBundledPlugins() }
        return await group.reduce(into: []) { $0 + $1 }
    }
}
```

#### 8. Dedicated URLSession (`HTTPMCPClient.swift`)
**Current**: Uses `.shared` URLSession
**Solution**: Create dedicated ephemeral session:
```swift
private let urlSession: URLSession = {
    let config = URLSessionConfiguration.ephemeral
    config.timeoutIntervalForRequest = 300
    config.timeoutIntervalForResource = 300
    config.waitsForConnectivity = true
    return URLSession(configuration: config)
}()
```

#### 9. Debounce CodeHighlighter (`CodeHighlighter.swift`)
**Current**: Every setting change triggers immediate recalc + view rebuild
**Solution**: Debounce updates:
```swift
private var pendingRecalc = false
private func scheduleRecalc() {
    guard !pendingRecalc else { return }
    pendingRecalc = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        self.recalcState()
        self.pendingRecalc = false
    }
}
```

#### 10. Deduplicate Conversion Methods (`Message.swift`)
**Current**: `toOKChatRequestData` and `toChatRequest` duplicate logic
**Solution**: Create single canonical method:
```swift
extension Array where Element == Message {
    func toChatMessages() -> [ChatMessage] { ... }
}
```

---

## Expected Improvements

| Issue | Before | After | Improvement |
|-------|--------|-------|-------------|
| Memory (1000-token response) | ~50MB | ~8MB | 84% |
| CPU time (string ops) | ~200ms | ~5ms | 97% |
| Scroll FPS | ~30 | ~60 | 100% |
| App startup | ~1.2s | ~0.8s | 33% |
| Disk writes per chat | ~100 | ~2 | 98% |

---

## Verification Plan

1. **Manual Testing**: Verify scrolling is smooth during streaming
2. **Instruments**: Profile memory and CPU usage before/after
3. **Xcode Memory Graph**: Check for memory leaks and retain cycles
4. **Benchmark Tests**: Add performance tests for critical paths
5. **User Testing**: Validate subjective performance improvements

---

## Rollback Plan

All changes are additive and can be reverted individually. If any fix introduces regressions:
1. Identify the specific change causing the issue
2. Revert that individual commit
3. Continue with remaining optimizations

---

## Dependencies

- None (all changes are internal to Ollamac codebase)
- Requires Phase 1-7 to be complete (current architecture in place)

---

## Risks

| Risk | Mitigation |
|------|------------|
| Regression in chat functionality | Comprehensive manual testing before merge |
| Performance fix doesn't improve metrics | Profile before/after, have fallback approaches |
| Breaking changes to existing behavior | All changes maintain API compatibility |

---

## Notes

- Phase number: 8 (next after Phase 7: Plugin UI Visibility Fixes)
- This phase is based on the performance bottleneck analysis conducted on 2025-05-02
- All 10 issues identified in the analysis are addressed in this phase
- Priority ordering: P0 (Critical) first, then P1 (High), then P1 (Medium)
