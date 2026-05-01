//
//  ChatBackendEnvironment.swift
//  Ollamac
//
//  Created for MCP Architecture Foundation - Phase 1
//

import Defaults
import SwiftUI

private struct ChatBackendEnvironmentKey: EnvironmentKey {
    static let defaultValue: any ChatBackend = {
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
