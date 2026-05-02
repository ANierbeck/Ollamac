# Phase 5: OllamaKit Local Integration - PLAN

## Overview
**Phase**: 5 of 6 (MCP Architecture Milestone)
**Name**: OllamaKit Local Integration
**Duration**: 1-2 weeks
**Goal**: Remove external OllamaKit package dependency and ensure local Sources/OllamaKit/Sources is used. Fix Swift concurrency build errors.
**Status**: COMPLETED

---

## Context

### Current State
- Phase 1-4 completed successfully
- OllamaKit defined as local target in Package.swift with path: "Sources/OllamaKit/Sources"
- Xcode project (Ollamac.xcodeproj) has OllamaKit as XCRemoteSwiftPackageReference
- Build fails with data race errors because external OllamaKit @ 5.0.8 uses non-concurrent-safe code
- `-strict-concurrency=minimal` flag exists for local OllamaKit target but not applied to external

### Problem Statement
Xcode project and Package.swift are out of sync regarding OllamaKit:
- Package.swift: OllamaKit is a local target (path: "Sources/OllamaKit/Sources")
- Xcode project: OllamaKit is an external package (https://github.com/kevinhermawan/OllamaKit @ 5.0.8)
- Build uses Xcode project settings, which pulls external version causing concurrency errors

### Dependencies
- Phase 4 (Plugin Architecture Foundation): COMPLETE
- Sources/OllamaKit/Sources exists locally

---

## Requirements

| ID | Task | Effort | Priority | Dependencies | Status | Wave |
|----|------|--------|----------|--------------|--------|-------|
| O-001 | Remove OllamaKit XCRemoteSwiftPackageReference from Xcode project | Medium | P0 | None | Not Started | 1 |
| O-002 | Add local Sources/OllamaKit/Sources to Xcode project as target | Medium | P0 | O-001 | Not Started | 1 |
| O-003 | Apply -strict-concurrency=minimal flag to all OllamaKit related targets | Small | P0 | O-002 | Not Started | 1 |
| O-004 | Verify build succeeds without data race errors | Small | P0 | O-003 | Not Started | 2 |

---

## Architecture Design

### Current Issue
```
Xcode Project Structure:
├── XCRemoteSwiftPackageReference "OllamaKit" 
│   └── repositoryURL = "https://github.com/kevinhermawan/OllamaKit"
│   └── version: 5.0.8
│
Package.swift Structure:
├── .target(name: "OllamaKit", path: "Sources/OllamaKit/Sources")
```

### Target Structure
```
Project Structure:
├── Ollamac.xcodeproj
│   └── (remove) XCRemoteSwiftPackageReference to OllamaKit
│   └── (add) Local target for Sources/OllamaKit/Sources
│
├── Sources/
│   └── OllamaKit/
│       └── Sources/ (existing local source)
│
├── Package.swift (already correct)
```

---

## Wave Breakdown

### Wave 1: Remove External Dependency & Add Local Target
**wave: 1**
**Goal**: Remove external OllamaKit package and add local source target

| Task | ID | Effort | Owner | Dependencies | Status |
|------|-----|--------|-------|--------------|--------|
| Remove XCRemoteSwiftPackageReference "OllamaKit" from project.pbxproj | O-001 | 2h | - | None | Not Started |
| Remove OllamaKit product reference from Frameworks build phase | O-001 | 1h | - | O-001 | Not Started |
| Add local Sources/OllamaKit/Sources as target in Xcode | O-002 | 3h | - | O-001 | Not Started |
| Add OllamaKit target to Ollamac target dependencies | O-002 | 1h | - | O-002 | Not Started |
| Apply -strict-concurrency=minimal to OllamaKit target | O-003 | 1h | - | O-002 | Not Started |

**Deliverables**:
- Modified Ollamac.xcodeproj/project.pbxproj without external OllamaKit
- Local OllamaKit target properly configured
- Swift concurrency flags applied

**Verification**:
- [ ] xcodebuild resolves OllamaKit from Sources/OllamaKit/Sources
- [ ] No XCRemoteSwiftPackageReference to OllamaKit
- [ ] Local source files visible in Xcode

---

### Wave 2: Build Verification
**wave: 2**
**Goal**: Verify build succeeds without errors

| Task | ID | Effort | Owner | Dependencies | Status |
|------|-----|--------|-------|--------------|--------|
| Run clean build with xcodebuild | O-004 | 2h | - | O-003 | Not Started |
| Verify no data race warnings | O-004 | 1h | - | O-004 | Not Started |
| Run tests to ensure no regressions | O-004 | 2h | - | O-004 | Not Started |

**Deliverables**:
- Successful build log
- No Swift concurrency warnings
- All tests passing

**Verification**:
- [ ] xcodebuild -scheme Ollamac succeeds
- [ ] No "sending risks causing data races" errors
- [ ] All existing tests pass

---

## File Changes

### Modified Files
```
Ollamac.xcodeproj/project.pbxproj
├── Remove: XCRemoteSwiftPackageReference "OllamaKit" 
├── Remove: PBXContainerItemProxy for OllamaKit
├── Remove: PBXBuildFile references to external OllamaKit
├── Add: Local target for Sources/OllamaKit/Sources
└── Add: Dependency from Ollamac target to local OllamaKit target

Ollamac.xcodeproj/project.xcworkspace/xcshareddata/xcschemes/Ollamac.xcscheme
└── Ensure local OllamaKit is included in build
```

### No New Files Required
- All source files already exist in Sources/OllamaKit/Sources

---

## Success Measures

### Functional Requirements
- [ ] External OllamaKit package dependency completely removed
- [ ] Local Sources/OllamaKit/Sources integrated as target
- [ ] -strict-concurrency=minimal flag applied
- [ ] Build completes successfully

### Quality Requirements
- [ ] No data race warnings during build
- [ ] No compiler errors
- [ ] Xcode project opens without errors
- [ ] All existing functionality preserved

### Performance Requirements
- [ ] Build time not significantly increased
- [ ] No additional warnings introduced

---

## Verification Criteria

### Build Tests
| Test | Description | Expected |
|------|-------------|----------|
| Clean Build | Full build from scratch | SUCCESS |
| Incremental Build | Build after minor changes | SUCCESS |
| Scheme Build | xcodebuild -scheme Ollamac | SUCCESS |

### Code Quality Tests
| Test | Description | Expected |
|------|-------------|----------|
| No External Package | Check project.pbxproj | No OllamaKit URL |
| Local Source | Verify source location | Sources/OllamaKit/Sources |
| Flag Applied | Check swiftSettings | -strict-concurrency=minimal |

---

## Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| Xcode project corruption | High | Backup project.pbxproj before changes |
| Build configuration issues | Medium | Test incrementally after each change |
| Missing source files | Medium | Verify Sources/OllamaKit/Sources exists and is complete |
| Merge conflicts | Low | Use git for tracking changes |

---

## Acceptance Criteria

- [ ] OllamaKit external package dependency removed from Xcode project
- [ ] Local Sources/OllamaKit/Sources properly integrated as target
- [ ] -strict-concurrency=minimal flag applied to OllamaKit target
- [ ] Build completes successfully without concurrency warnings
- [ ] All existing tests pass with local OllamaKit source
- [ ] No external network calls to fetch OllamaKit during build
- [ ] Xcode project opens and builds without errors

---

## Estimates

| Component | Hours | Complexity |
|-----------|-------|------------|
| Remove external dependency | 3 | Medium |
| Add local target | 4 | Medium |
| Apply concurrency flags | 1 | Low |
| Build verification | 2 | Low |
| **Total** | **10** | - |

---

## Notes

- This phase is critical for the MCP milestone as it resolves the build blocker
- Must ensure Sources/OllamaKit/Sources contains complete OllamaKit source code
- The local integration will allow us to modify OllamaKit if needed for MCP support
- After this phase, OllamaKit will be under our version control

---
*Generated by Mistral Vibe*
*Co-Authored-By: Mistral Vibe <vibe@mistral.ai>*
*Phase: 5 - OllamaKit Local Integration*
*Milestone: MCP Architecture Foundation*
