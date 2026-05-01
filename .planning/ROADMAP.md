# Roadmap

## Overview
This roadmap defines the phased approach for evolving Ollamac from its current state (v3.0.3) to a more maintainable, testable, and feature-rich application. Each phase focuses on specific outcomes with clear acceptance criteria.

## Current State
- **Version**: 3.0.3
- **Status**: Functional, actively used
- **Architecture**: MVVM with SwiftUI
- **Test Coverage**: 0%
- **Technical Debt**: High (see CONCERNS.md)

---

## Phase Structure

### Phase 0: Foundation (Current - Complete)
**Duration**: Already complete
**Goal**: Establish project, codebase mapping
**Status**: ✅ Complete

| Task | Status | Owner | Notes |
|------|--------|-------|-------|
| Analyze existing codebase | ✅ Done | GSD | 7 codebase docs created |
| Document architecture | ✅ Done | GSD | ARCHITECTURE.md, STRUCTURE.md |
| Identify technical debt | ✅ Done | GSD | CONCERNS.md created |
| Define requirements | ✅ Done | GSD | REQUIREMENTS.md created |

---

## Milestone 1: Architecture & Testing Foundation
**Duration**: 2-3 weeks
**Goal**: Establish foundation for quality and maintainability
**Success**: All P0 architecture and testing requirements met

### Phase 1.1: Dependency Injection & Architecture
**Outcome**: Decoupled architecture enabling testing

| Task | ID | Effort | Priority | Dependencies |
|------|-----|--------|----------|--------------|
| Create OllamaKit protocol abstraction | R-001 | Medium | P0 | None |
| Implement dependency injection in ChatView | R-001 | Medium | P0 | R-001 |
| Implement dependency injection in MessageViewModel | R-001 | Medium | P0 | R-001 |
| Extract business logic from views | R-003 | Medium | P0 | R-001 |
| Add architecture documentation | R-004 | Small | P0 | None |

**Acceptance Criteria**:
- [ ] OllamaKit can be mocked for testing
- [ ] ViewModels accept dependencies via constructor
- [ ] No direct OllamaKit instantiation in views
- [ ] Architecture docs updated

### Phase 1.2: Test Infrastructure
**Outcome**: Foundation for automated testing

| Task | ID | Effort | Priority | Dependencies |
|------|-----|--------|----------|--------------|
| Add unit test target to Xcode project | R-010 | Small | P0 | None |
| Create MockOllamaKit implementation | R-011 | Medium | P0 | R-001 |
| Add first unit tests for MessageViewModel | R-012 | Medium | P0 | R-010, R-011 |
| Add tests for Chat persistence | R-014 | Medium | P0 | R-010 |
| Setup GitHub Actions CI pipeline | R-016 | Medium | P0 | R-010 |

**Acceptance Criteria**:
- [ ] Test target compiles and runs
- [ ] MockOllamaKit can simulate all API responses
- [ ] Critical paths have unit tests
- [ ] CI runs tests on every PR

### Phase 1.3: Security Hardening
**Outcome**: Address critical security concerns

| Task | ID | Effort | Priority | Dependencies |
|------|-----|--------|----------|--------------|
| Add HTTPS support for Ollama connections | R-020 | Medium | P0 | None |
| Implement certificate validation | R-021 | Medium | P0 | R-020 |
| Add input validation for host URLs | R-022 | Medium | P0 | None |
| Sanitize markdown content | R-023 | Medium | P0 | None |

**Acceptance Criteria**:
- [ ] Can configure HTTPS endpoints
- [ ] Certificate validation prevents MITM
- [ ] Invalid URLs rejected with clear errors
- [ ] Markdown rendering is safe

---

## Milestone 2: Code Quality & Performance
**Duration**: 2 weeks
**Goal**: Improve code quality and address performance concerns
**Success**: All P1 requirements met, improved user experience

### Phase 2.1: Code Refactoring
**Outcome**: Cleaner, more maintainable code

| Task | ID | Effort | Priority | Dependencies |
|------|-----|--------|----------|--------------|
| Extract common streaming logic | R-040 | Small | P1 | None |
| Unify think tag handling | R-041 | Small | P1 | None |
| Centralize configuration constants | R-042 | Small | P1 | None |
| Add code documentation | R-043 | Medium | P1 | None |
| Add SwiftLint for style enforcement | R-044 | Small | P1 | None |

**Acceptance Criteria**:
- [ ] No duplicate streaming code
- [ ] Consistent think tag handling
- [ ] All configuration in one place
- [ ] Public APIs documented
- [ ] Linting passes on CI

### Phase 2.2: Performance Optimizations
**Outcome**: Improved performance for large datasets

| Task | ID | Effort | Priority | Dependencies |
|------|-----|--------|----------|--------------|
| Implement pagination for chat list | R-030 | Medium | P1 | None |
| Add model caching | R-031 | Small | P1 | None |
| Lazy load messages | R-032 | Medium | P1 | None |
| Add debouncing for rapid actions | R-034 | Small | P1 | None |

**Acceptance Criteria**:
- [ ] Only visible chats loaded
- [ ] Models fetched once per session
- [ ] Messages loaded on-demand
- [ ] No network thrashing on rapid actions

### Phase 2.3: Error Handling & Reliability
**Outcome**: More robust error handling and recovery

| Task | ID | Effort | Priority | Dependencies |
|------|-----|--------|----------|--------------|
| Add automatic retry with backoff | R-052 | Medium | P1 | None |
| Implement error recovery flows | R-051 | Medium | P1 | None |
| Add partial state handling | R-051 | Medium | P1 | None |
| Clear errors automatically | R-052 | Small | P1 | None |

**Acceptance Criteria**:
- [ ] Network failures auto-retry
- [ ] Partial responses saved
- [ ] Errors auto-clear after resolution

---

## Milestone 3: User Experience Enhancements
**Duration**: 2 weeks
**Goal**: Enhance user experience and expand use cases
**Success**: All P1 UX requirements met

### Phase 3.1: Export & Data Management
**Outcome**: Users can export and backup their data

| Task | ID | Effort | Priority | Dependencies |
|------|-----|--------|----------|--------------|
| Add export functionality for chats | R-050 | Medium | P1 | None |
| Auto-save partial responses | R-051 | Medium | P1 | None |
| Add backup mechanism | R-050 | Medium | P1 | R-050 |

**Acceptance Criteria**:
- [ ] Can export individual chats
- [ ] Partial responses preserved
- [ ] Backup option available

### Phase 3.2: Accessibility & Localization
**Outcome**: Expand user base with accessibility and localization

| Task | ID | Effort | Priority | Dependencies |
|------|-----|--------|----------|--------------|
| Add VoiceOver support | R-053 | Medium | P1 | None |
| Add dynamic type support | R-053 | Medium | P1 | None |
| Add keyboard navigation | R-055 | Medium | P1 | None |
| Add localization framework | R-054 | Large | P1 | None |

**Acceptance Criteria**:
- [ ] VoiceOver compatible
- [ ] Respects system font size
- [ ] Full keyboard access
- [ ] At least 2 languages supported

---

## Milestone 4: Developer Experience
**Duration**: 1 week
**Goal**: Improve contributor experience
**Success**: Easier for new contributors to join

### Phase 4.1: Documentation & Processes
**Outcome**: Clear contribution guidelines

| Task | ID | Effort | Priority | Dependencies |
|------|-----|--------|----------|--------------|
| Create CONTRIBUTING.md | R-060 | Small | P2 | None |
| Add PR template | R-061 | Small | P2 | None |
| Add issue templates | R-062 | Small | P2 | None |
| Add development setup guide | R-063 | Small | P2 | None |
| Setup Swift Format | R-045 | Small | P2 | None |
| Add code coverage reporting | R-017 | Small | P2 | R-010 |

**Acceptance Criteria**:
- [ ] Clear contribution guidelines
- [ ] PR template in use
- [ ] Issue templates in use
- [ ] Development guide complete
- [ ] Auto-formatting on CI
- [ ] Coverage visible in PRs

---

## Milestone 5: Future Enhancements
**Duration**: Ongoing
**Goal**: Expand functionality and explore new features
**Success**: Enhanced feature set based on user feedback

### Phase 5.1: Advanced Features
**Outcome**: New capabilities for power users

| Task | ID | Effort | Priority | Dependencies |
|------|-----|--------|----------|--------------|
| Add chat search | R-072 | Medium | P2 | Milestone 2 |
| Add multi-window support | R-071 | Medium | P2 | Milestone 1 |
| Add model fine-tuning UI | R-073 | Medium | P2 | Milestone 1 |

### Phase 5.2: Experimental Features
**Outcome**: Explore new possibilities

| Task | ID | Effort | Priority | Dependencies |
|------|-----|--------|----------|--------------|
| Add plugins/extensions architecture | R-070 | Large | P2 | Milestone 2 |
| Add team/collaboration features | R-074 | Large | P2 | Milestone 3 |
| Add cloud sync | R-075 | Large | P2 | Milestone 3 |

---

## Phase Summary

| Milestone | Phases | Duration | Primary Focus | Success Metric |
|-----------|--------|----------|----------------|----------------|
| M1 | 1.1-1.3 | 2-3 weeks | Architecture & Testing | P0 complete, testable |
| M2 | 2.1-2.3 | 2 weeks | Code Quality & Performance | P1 complete, 70%+ coverage |
| M3 | 3.1-3.2 | 2 weeks | User Experience | P1 complete, satisfied users |
| M4 | 4.1 | 1 week | Developer Experience | Contribution-ready |
| M5 | 5.1-5.2 | Ongoing | Future Features | Feature-rich |

---

## Total Estimates
- **Total Phases**: 9+ phases across 5 milestones
- **Total Duration**: 7-8 weeks for M1-M4
- **Total Requirements**: 24 P0/P1 requirements
- **Total Effort**: ~40-50 person-days

---

## Release Plan

| Version | Milestone | Date | Notes |
|---------|-----------|------|-------|
| 3.0.3 | Current | Released | Baseline |
| 3.1.0 | M1 Complete | TBD | Architecture & Testing |
| 3.2.0 | M2 Complete | TBD | Code Quality |
| 3.3.0 | M3 Complete | TBD | User Experience |
| 4.0.0 | M4 Complete | TBD | Developer Experience |

---

## Dependencies

### External Dependencies
- Ollama server (for integration testing)
- Xcode 15+ (Swift 5.9+)
- macOS 14.0+ (for builds)
- GitHub (for CI/CD)

### Internal Dependencies
- Each phase builds on previous phase
- M1 must be complete before M2 can start
- Testing infrastructure required for all development

---

## Risk Mitigation

| Risk | Phase | Mitigation |
|------|-------|------------|
| Architecture changes break existing code | M1 | Comprehensive testing, backward compatibility |
| Testing infrastructure incomplete | M1 | Prioritize, pair programming |
| Performance regressions | M2 | Benchmark before/after, user testing |
| Scope creep | All | Strict requirement prioritization |

---

## Tracking
- **Project Board**: GitHub Projects (recommended)
- **Issues**: GitHub Issues with labels
- **PRs**: GitHub Pull Requests with templates
- **Progress**: Manual tracking in STATE.md

---

## Next Steps
1. Review and approve this roadmap
2. Run `/gsd-plan-phase 1.1` to start Phase 1.1
3. Or run `/gsd-plan-milestone-gaps` to identify additional gaps
4. Or run `/gsd-new-milestone` to restart with different scope

---
*Roadmap based on codebase analysis and project requirements*
*Phases can be adjusted based on priorities and constraints*
