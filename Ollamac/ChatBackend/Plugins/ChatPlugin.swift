//
//  ChatPlugin.swift
//  Ollamac
//
//  Created for Phase 4: Plugin Architecture Foundation
//

import Foundation

/// Protocol for chat plugins that can be dynamically loaded and managed
/// Extends ChatBackend to add plugin-specific capabilities
public protocol ChatPlugin: ChatBackend {
    // MARK: - Plugin Metadata

    /// Unique identifier for this plugin type
    static var pluginID: String { get }

    /// Human-readable display name for UI
    static var displayName: String { get }

    /// Description of what this plugin does
    static var description: String { get }

    /// SF Symbol name for plugin icon in UI
    static var iconName: String { get }

    // MARK: - Plugin Lifecycle

    /// Creates a new instance with the given configuration
    static func createInstance(config: PluginConfig) -> Self

    // MARK: - Instance Configuration

    /// Current configuration for this plugin instance
    /// Note: Must be `let` for Sendable conformance (immutable after initialization)
    var config: PluginConfig { get }
}

public extension ChatPlugin {
    var backendType: String {
        return Self.pluginID
    }
}
