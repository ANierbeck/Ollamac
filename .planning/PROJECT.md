# Ollamac - Project Context

## Overview
**Project**: Ollamac - Native macOS GUI client for Ollama
**Type**: Existing brownfield project (codebase mapping complete)
**Status**: Active, version 3.0.3
**Maintainer**: Kevin Hermawan (kevinhermawan)
**Repository**: https://github.com/ANierbeck/Ollamac (fork)
**Original**: https://github.com/kevinhermawan/Ollamac

## Purpose
Ollamac provides a native, user-friendly macOS application for interacting with Ollama's local large language models. It aims to offer a seamless chat experience with local AI models, combining the power of Ollama with the polish of a native Mac application.

## Project Status
- **Current Version**: 3.0.3
- **License**: Apache License 2.0
- **Platform**: macOS 14.0+ (Sonoma)
- **Distribution**: Homebrew Cask, GitHub Releases
- **Users**: Growing open-source community

## Codebase State
- **Total Files**: 40 files (36 Swift, 4 JSON)
- **Lines of Code**: ~4,500+ Swift LOC
- **Architecture**: MVVM with SwiftUI
- **Persistence**: SwiftData (SQLite)
- **Test Coverage**: 0% (no tests, no test target)
- **Plugin Support**: None (to be added in current milestone)
- **MCP Support**: None (main goal of current milestone)

## Business Context
- **Target Audience**: macOS users running Ollama locally
- **Value Proposition**: Native GUI alternative to CLI for Ollama
- **Competitive Edge**: Native performance, Apple ecosystem integration, free/open-source
- **Revenue Model**: None (free, open-source)
- **Funding**: Community support, GitHub Sponsors

## Success Metrics
- Homebrew downloads
- GitHub stars
- User satisfaction (issues, discussions)
- Community contributions
- MCP integration success (for current milestone)

## Stakeholders
| Role | Name | Responsibility |
|------|------|----------------|
| Creator/Maintainer | Kevin Hermawan | Original architecture, development, releases |
| Fork Maintainer | ANierbeck | MCP integration, architecture adaptation |
| Users | Community | Feedback, bug reports, feature requests |
| Contributors | Open Source | Pull requests, issues, discussions |

## Constraints
| Type | Constraint | Impact |
|------|------------|--------|
| Platform | macOS 14.0+ only | Limits user base |
| Dependency | Ollama server required | Must be installed separately |
| Technical | Swift 5.9+ required | Xcode 15+ needed |
| Legal | Apache License 2.0 | Must comply with terms |
| Resources | Solo/small team | Development pace |
| Backward Compatibility | Must maintain | Existing users not broken |

## Risks
| Risk | Severity | Mitigation |
|------|----------|------------|
| Single maintainer | High | Grow contributor base, documentation |
| No tests | High | Add test infrastructure, CI pipeline (Phase 3) |
| Tight coupling | High | Refactor with DI, protocols (Phase 1-2) |
| No plugin system | High | Establish plugin architecture (Phase 4) |
| MCP spec changes | Medium | Follow MCP specification updates |

## Current Milestone: MCP Architecture Foundation
**Objective**: Adapt architecture to support MCP, introduce tests, and establish plugin architecture fundamentals.  
**Duration**: ~6 weeks  
**Status**: Not started  
**Phases**: 4 phases (ChatBackend Abstraction, Dependency Injection, Test Infrastructure, Plugin Architecture)  
**Requirements**: 16 (all P0)  

### Milestone Goals
1. **Adapt Architecture**: Decouple ChatViewModel and MessageViewModel from direct OllamaKit usage
2. **Introduce Tests**: Create test infrastructure and first unit tests
3. **Plugin Architecture**: Establish foundation for MCP as a plugin/extension

### Key Deliverables
- ChatBackend protocol with OllamaBackend and MCPBackend implementations
- Dependency injection throughout the chat system
- Unit test target with first tests
- CI pipeline for automated testing
- Plugin protocol and registry
- MCPBackend as first plugin

## Non-Goals
- Windows/Linux support (macOS-only focus)
- Mobile apps (iOS/iPadOS)
- Web version
- Cloud hosting service
- Commercial monetization
- Full MCP specification implementation (only what's needed for Ollamac)

## Decision Log
- **v1.0**: Initial release with basic chat functionality
- **v2.0**: Added model selection, custom hosts
- **v3.0**: SwiftData migration, improved UI
- **MCP Milestone**: Architecture adaptation, test introduction, plugin foundation

## Links
- **Fork Repository**: https://github.com/ANierbeck/Ollamac
- **Original Repository**: https://github.com/kevinhermawan/Ollamac
- **Releases**: https://github.com/kevinhermawan/Ollamac/releases
- **Issues**: https://github.com/ANierbeck/Ollamac/issues
- **Homebrew**: `brew install --cask ollamac` (points to original)
- **MCP Specification**: https://modelcontextprotocol.io

---
*Generated: 2024-05-01*
*Source: GSD new-milestone workflow*
*Current milestone: MCP Architecture Foundation*
