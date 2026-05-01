# Requirements

## V1 Scope (Current State - Baseline)
Ollamac v3.0.3 provides core chat functionality with Ollama:

### ✅ Implemented
- [x] Native macOS SwiftUI application
- [x] Chat interface with streaming responses
- [x] Multiple chat sessions management
- [x] Model selection from Ollama server
- [x] Custom host configuration
- [x] System prompt customization
- [x] Temperature/TopP/TopK parameters
- [x] Auto-generated chat titles
- [x] Message regeneration
- [x] Copy messages/code blocks
- [x] Markdown rendering with code blocks
- [x] Experimental syntax highlighting
- [x] Auto-updates via Sparkle
- [x] Dark/Light mode support
- [x] Font size adjustment
- [x] Keyboard shortcuts (cmd+±, cmd+shift+R)
- [x] SwiftData persistence (SQLite)
- [x] UserDefaults for settings

### V1 Technical Stack
- Swift 5.9+, SwiftUI, SwiftData
- Xcode 15+ project
- 10 external frameworks (Sparkle, OllamaKit, ChatField, etc.)
- No tests, no CI/CD

---

## V2 Requirements (Next Major Version)

### 🎯 Core Objectives
1. **Improve Code Quality & Maintainability**
2. **Add Comprehensive Testing**
3. **Address Security Concerns**
4. **Enhance Performance & Scalability**

### Epic 1: Architecture Improvements
**Priority**: P0 (Critical)

| ID | Requirement | Description | Acceptance Criteria | Effort | Risk |
|----|-------------|-------------|---------------------|--------|------|
| R-001 | Introduce Dependency Injection | Decouple ViewModels from OllamaKit | ViewModels accept protocol-based dependencies | Medium | Low |
| R-002 | Extract Network Layer Abstraction | Create protocol for Ollama API | Mockable for testing, swappable implementations | Medium | Low |
| R-003 | Separate Business Logic from UI | Move logic out of views | ViewModels contain only state, not presentation logic | Medium | Low |
| R-004 | Add MVVM Data Flow Documentation | Document architecture patterns | Clear docs for contributors | Small | Low |

### Epic 2: Testing Infrastructure
**Priority**: P0 (Critical)

| ID | Requirement | Description | Acceptance Criteria | Effort | Risk |
|----|-------------|-------------|---------------------|--------|------|
| R-010 | Add Unit Test Target | Create OllamacTests target | Tests compile and run | Small | Low |
| R-011 | Mock OllamaKit for Testing | Create MockOllamaKit | Can simulate all API responses | Medium | Low |
| R-012 | Test Message Generation | Test streaming logic | 80% coverage of MessageViewModel.generate() | Medium | Medium |
| R-013 | Test Chat Persistence | Test SwiftData operations | All CRUD operations tested | Medium | Medium |
| R-014 | Test Error Handling | Test error paths | All error cases covered | Medium | Medium |
| R-015 | Add UI Tests | Test main user journeys | Critical paths: create chat, send message, switch chats | Medium | Medium |
| R-016 | Setup CI Pipeline | GitHub Actions for build & test | Tests run on every PR | Medium | Low |
| R-017 | Add Code Coverage Reporting | Enable coverage in CI | Coverage visible in PRs | Small | Low |

### Epic 3: Security Enhancements
**Priority**: P0 (Critical)

| ID | Requirement | Description | Acceptance Criteria | Effort | Risk |
|----|-------------|-------------|---------------------|--------|------|
| R-020 | Add HTTPS Support | Support encrypted connections to Ollama | Can configure HTTPS endpoints | Medium | Medium |
| R-021 | Implement Certificate Pinning | Validate server certificates | Prevents MITM attacks | Medium | Medium |
| R-022 | Add Input Validation | Validate host URLs and user input | All inputs validated before use | Medium | Low |
| R-023 | Sanitize Markdown Content | Prevent markdown injection | Safe rendering of AI responses | Medium | Low |
| R-024 | Add Host Validation | Validate URL schemes and formats | Only valid HTTP/HTTPS URLs accepted | Small | Low |

### Epic 4: Performance & Scalability
**Priority**: P1 (High)

| ID | Requirement | Description | Acceptance Criteria | Effort | Risk |
|----|-------------|-------------|---------------------|--------|------|
| R-030 | Implement Pagination | Load chats lazily | Only visible chats loaded | Medium | Low |
| R-031 | Add Model Caching | Cache available models | Models fetched once, refreshed periodically | Small | Low |
| R-032 | Lazy Load Messages | Load messages on-demand | Only visible messages loaded | Medium | Medium |
| R-033 | Optimize Syntax Highlighting | Improve performance | No lag with code highlighting enabled | Medium | Medium |
| R-034 | Add Debouncing | Prevent rapid state changes | No network thrashing on rapid actions | Small | Low |

### Epic 5: Code Quality
**Priority**: P1 (High)

| ID | Requirement | Description | Acceptance Criteria | Effort | Risk |
|----|-------------|-------------|---------------------|--------|------|
| R-040 | Extract Common Streaming Logic | Reduce duplication | Single source of truth for streaming | Small | Low |
| R-041 | Unify Think Tag Handling | Consistent approach | Same logic in all places | Small | Low |
| R-042 | Centralize Configuration | Single config file | All defaults in one place | Small | Low |
| R-043 | Add Documentation | Code and architecture docs | All public APIs documented | Medium | Low |
| R-044 | Add SwiftLint | Style enforcement | Linting passes on CI | Small | Low |
| R-045 | Add Swift Format | Consistent formatting | Auto-formatting on CI | Small | Low |

### Epic 6: User Experience
**Priority**: P1 (High)

| ID | Requirement | Description | Acceptance Criteria | Effort | Risk |
|----|-------------|-------------|---------------------|--------|------|
| R-050 | Add Export Functionality | Export chats as files | Can export individual chats | Medium | Low |
| R-051 | Add Auto-Save | Save partial responses | No data loss on interruptions | Medium | Medium |
| R-052 | Add Error Recovery | Auto-retry failed requests | Transparent recovery for user | Medium | Medium |
| R-053 | Add Accessibility | VoiceOver, dynamic type | WCAG compliance | Medium | Medium |
| R-054 | Add Localization | Multi-language support | At least 2 languages | Large | Medium |
| R-055 | Add Keyboard Navigation | Full keyboard support | All features accessible via keyboard | Medium | Medium |

### Epic 7: Developer Experience
**Priority**: P2 (Medium)

| ID | Requirement | Description | Acceptance Criteria | Effort | Risk |
|----|-------------|-------------|---------------------|--------|------|
| R-060 | Create CONTRIBUTING.md | Contribution guidelines | Clear instructions for contributors | Small | Low |
| R-061 | Add Code Review Process | PR template, checklist | Consistent review process | Small | Low |
| R-062 | Add Issue Templates | Bug report, feature request | Better issue quality | Small | Low |
| R-063 | Setup Development Docs | Getting started guide | New contributors can build/run | Small | Low |

### Epic 8: Future Enhancements
**Priority**: P2 (Medium) - Out of V2 Scope

| ID | Requirement | Description | Acceptance Criteria | Effort | Risk |
|----|-------------|-------------|---------------------|--------|------|
| R-070 | Add Plugins/Extensions | Extensible architecture | Third-party plugins possible | Large | High |
| R-071 | Add Multi-Window Support | Multiple chat windows | Each chat in separate window | Medium | Medium |
| R-072 | Add Chat Search | Search across chats | Full-text search of messages | Medium | Medium |
| R-073 | Add Model Fine-Tuning UI | Configure model parameters | All Ollama options exposed | Medium | Medium |
| R-074 | Add Team/Collaboration | Shared chats | Real-time collaboration | Large | High |
| R-075 | Add Cloud Sync | Sync chats across devices | Seamless cross-device experience | Large | High |

---

## Requirement Categories

### Must Have (P0)
- R-001 to R-004: Architecture improvements (DI, abstractions)
- R-010 to R-017: Testing infrastructure
- R-020 to R-024: Security enhancements

### Should Have (P1)
- R-030 to R-034: Performance & scalability
- R-040 to R-045: Code quality
- R-050 to R-055: User experience

### Nice to Have (P2)
- R-060 to R-063: Developer experience
- R-070 to R-075: Future enhancements

### Out of Scope (Current)
- Windows/Linux ports
- Mobile apps (iOS/iPadOS)
- Web version
- Commercial features
- Cloud hosting

---

## Dependencies

### Technical Dependencies
| Requirement | Depends On | Reason |
|-------------|------------|--------|
| R-011 | R-001 | Need DI to inject mocks |
| R-012, R-013, R-014 | R-010, R-011 | Need test infrastructure |
| R-015 | R-010 | Need test target |
| R-016, R-017 | R-010 | Need tests before CI |
| R-050 | R-001 | Need architecture cleanup |

### Resource Dependencies
- All development requires macOS 14.0+
- All development requires Xcode 15+
- Testing requires Ollama server for integration tests
- CI requires macOS runner

---

## Assumptions
1. Ollama API will remain stable (v1 compatibility)
2. Swift 5.9+ features will remain supported
3. Sparkle will continue to support macOS updates
4. External frameworks will maintain compatibility
5. Project will remain open-source

---

## Constraints
1. Must maintain backward compatibility with existing chats
2. Must maintain macOS 14.0+ support
3. Must maintain free/open-source license
4. Must pass App Store review (if submitted)
5. Must work with Homebrew distribution

---

## Success Criteria for V2
- [ ] All P0 requirements implemented
- [ ] Test coverage >= 70%
- [ ] All security critical issues addressed
- [ ] No breaking changes for existing users
- [ ] Documentation complete
- [ ] CI pipeline passing

---
*Requirements defined based on codebase analysis and project goals*
*V1 = Current state, V2 = Next major version*
