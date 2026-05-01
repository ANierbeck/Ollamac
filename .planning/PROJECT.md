# Ollamac - Project Context

## Overview
**Project**: Ollamac - Native macOS GUI client for Ollama
**Type**: Existing brownfield project (codebase mapping complete)
**Status**: Active, version 3.0.3
**Maintainer**: Kevin Hermawan (kevinhermawan)
**Repository**: https://github.com/kevinhermawan/Ollamac

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
- **Test Coverage**: 0% (no tests)

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
- App Store ratings (if distributed there)
- Community contributions

## Stakeholders
| Role | Name | Responsibility |
|------|------|----------------|
| Creator/Maintainer | Kevin Hermawan | Architecture, development, releases |
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

## Risks
| Risk | Severity | Mitigation |
|------|----------|------------|
| Single maintainer | High | Grow contributor base, documentation |
| No tests | High | Add test infrastructure, CI pipeline |
| Tight coupling | Medium | Refactor with DI, protocols |
| Security (HTTP only) | Critical | Add HTTPS support |
| No backup/export | Medium | Add export functionality |

## Project Goals (Next 6 Months)
1. Improve code quality and maintainability
2. Add comprehensive test coverage
3. Address security concerns (HTTPS support)
4. Enhance user experience (performance, features)
5. Grow contributor community

## Non-Goals
- Windows/Linux support (macOS-only focus)
- Mobile apps (iOS/iPadOS)
- Web version
- Cloud hosting service
- Commercial monetization

## Decision Log
- **v1.0**: Initial release with basic chat functionality
- **v2.0**: Added model selection, custom hosts
- **v3.0**: SwiftData migration, improved UI
- **Future**: Testing, DI, HTTPS, export

## Links
- **Repository**: https://github.com/kevinhermawan/Ollamac
- **Releases**: https://github.com/kevinhermawan/Ollamac/releases
- **Issues**: https://github.com/kevinhermawan/Ollamac/issues
- **Homebrew**: `brew install --cask ollamac`
- **Funding**: https://github.com/kevinhermawan/Ollamac/blob/main/.github/FUNDING.yml

---
*Generated: $(date)*
*Source: GSD codebase mapping workflow*
