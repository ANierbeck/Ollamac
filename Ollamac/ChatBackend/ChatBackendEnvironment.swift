//
//  ChatBackendEnvironment.swift
//  Ollamac
//
//  Created for MCP Architecture Foundation - Phase 1
//  Updated for Phase 4: Plugin Architecture Foundation
//

import Defaults
import SwiftUI

private struct ChatBackendEnvironmentKey: EnvironmentKey {
    static let defaultValue: any ChatBackend = {
        // Fallback to OllamaBackend with default host
        // Note: This is a nonisolated context, so we cannot access PluginRegistry.shared here
        let baseURL = URL(string: Defaults[.defaultHost])!
        return OllamaBackend(baseURL: baseURL)
    }()
}

extension EnvironmentValues {
    var chatBackend: any ChatBackend {
        get { self[ChatBackendEnvironmentKey.self] }
        set { self[ChatBackendEnvironmentKey.self] = newValue }
    }
}
