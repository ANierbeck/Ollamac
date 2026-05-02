//
//  PluginConfig.swift
//  Ollamac
//
//  Created for Phase 4: Plugin Architecture Foundation
//

import Defaults
import Foundation

/// Configuration for a plugin instance
/// Persisted via UserDefaults
public struct PluginConfig: Codable, Sendable, Identifiable, Hashable, Defaults.Serializable {
    public let id: String
    public var isEnabled: Bool
    public var baseURLString: String
    public var customName: String?
    public var settings: [String: String]

    public var baseURL: URL {
        URL(string: baseURLString) ?? URL(string: "http://localhost")!
    }

    public init(
        id: String,
        isEnabled: Bool = true,
        baseURL: URL,
        customName: String? = nil,
        settings: [String: String] = [:]
    ) {
        self.id = id
        self.isEnabled = isEnabled
        self.baseURLString = baseURL.absoluteString
        self.customName = customName
        self.settings = settings
    }

    public init(
        id: String,
        isEnabled: Bool = true,
        baseURLString: String,
        customName: String? = nil,
        settings: [String: String] = [:]
    ) {
        self.id = id
        self.isEnabled = isEnabled
        self.baseURLString = baseURLString
        self.customName = customName
        self.settings = settings
    }

    public var displayName: String {
        customName ?? id
    }

    // MARK: - Default Configurations

    public static var ollama: PluginConfig {
        PluginConfig(
            id: "ollama",
            isEnabled: true,
            baseURL: URL(string: "http://localhost:11434")!
        )
    }

    public static var mcp: PluginConfig {
        PluginConfig(
            id: "mcp",
            isEnabled: true,
            baseURL: URL(string: "http://localhost:8080")!
        )
    }
}
