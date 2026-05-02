//
//  PluginRegistry.swift
//  Ollamac
//
//  Created for Phase 4: Plugin Architecture Foundation
//

import Foundation

/// Registry for managing available plugins
/// Singleton that maintains the list of registered plugins
public final class PluginRegistry {
    @MainActor public static let shared = PluginRegistry()

    private var plugins: [ObjectIdentifier: any ChatPlugin] = [:]
    private var pluginConfigs: [String: PluginConfig] = [:]
    private let queue = DispatchQueue(label: "com.ollamac.PluginRegistry", attributes: .concurrent)

    private init() {}

    // MARK: - Registration

    /// Register a plugin type with the registry
    /// - Parameter pluginType: The plugin type to register
    public func register<P: ChatPlugin>(pluginType: P.Type) {
        queue.async(flags: .barrier) {
            let identifier = ObjectIdentifier(pluginType)
            if self.plugins[identifier] == nil {
                // Create a default config for this plugin type
                let defaultConfig = PluginConfig(
                    id: pluginType.pluginID,
                    isEnabled: false,
                    baseURLString: "http://localhost:8080"
                )
                let instance = pluginType.createInstance(config: defaultConfig)
                self.plugins[identifier] = instance
            }
        }
    }

    /// Register a plugin instance with configuration
    /// - Parameters:
    ///   - plugin: The plugin instance
    ///   - config: Configuration for the plugin
    public func registerPlugin(_ plugin: any ChatPlugin, config: PluginConfig) {
        queue.async(flags: .barrier) {
            let identifier = ObjectIdentifier(type(of: plugin))
            self.plugins[identifier] = plugin
            self.pluginConfigs[config.id] = config
        }
    }

    // MARK: - Unregistration

    /// Unregister a plugin type
    /// - Parameter pluginType: The plugin type to unregister
    public func unregister<P: ChatPlugin>(pluginType: P.Type) {
        queue.async(flags: .barrier) {
            let identifier = ObjectIdentifier(pluginType)
            self.plugins.removeValue(forKey: identifier)
        }
    }

    /// Unregister a plugin by ID
    /// - Parameter pluginID: The plugin ID to unregister
    public func unregister(pluginID: String) {
        queue.async(flags: .barrier) {
            self.pluginConfigs.removeValue(forKey: pluginID)
            if let index = self.plugins.first(where: { $0.value.config.id == pluginID }) {
                self.plugins.removeValue(forKey: index.key)
            }
        }
    }

    // MARK: - Retrieval

    /// Get all registered plugin types
    /// - Returns: Array of plugin types
    public func getAllPluginTypes() -> [any ChatPlugin.Type] {
        queue.sync {
            return plugins.values.map { type(of: $0) }
        }
    }

    /// Get a plugin instance by ID
    /// - Parameter pluginID: The plugin ID
    /// - Returns: The plugin instance or nil
    public func getPlugin(byID pluginID: String) -> (any ChatPlugin)? {
        queue.sync {
            return plugins.values.first { $0.config.id == pluginID }
        }
    }

    /// Get a plugin instance by type
    /// - Returns: The plugin instance or nil
    public func getPlugin<P: ChatPlugin>(_ pluginType: P.Type) -> P? {
        queue.sync {
            let identifier = ObjectIdentifier(pluginType)
            return plugins[identifier] as? P
        }
    }

    /// Get all registered plugin instances
    /// - Returns: Array of all plugin instances
    public func getAllPlugins() -> [any ChatPlugin] {
        queue.sync {
            return Array(plugins.values)
        }
    }

    /// Get all enabled plugins
    /// - Returns: Array of enabled plugin instances
    public func getEnabledPlugins() -> [any ChatPlugin] {
        queue.sync {
            return plugins.values.filter { plugin in
                pluginConfigs[plugin.config.id]?.isEnabled ?? false
            }
        }
    }

    // MARK: - Configuration

    /// Get configuration for a plugin
    /// - Parameter pluginID: The plugin ID
    /// - Returns: Configuration or nil
    public func getConfig(for pluginID: String) -> PluginConfig? {
        queue.sync {
            return pluginConfigs[pluginID]
        }
    }

    /// Update configuration for a plugin
    /// - Parameters:
    ///   - pluginID: The plugin ID
    ///   - config: New configuration
    public func updateConfig(for pluginID: String, _ config: PluginConfig) {
        queue.async(flags: .barrier) {
            self.pluginConfigs[pluginID] = config
        }
    }

    /// Enable or disable a plugin
    /// - Parameters:
    ///   - pluginID: The plugin ID
    ///   - isEnabled: Whether to enable the plugin
    public func setPluginEnabled(_ pluginID: String, _ isEnabled: Bool) {
        queue.async(flags: .barrier) {
            if var config = self.pluginConfigs[pluginID] {
                config.isEnabled = isEnabled
                self.pluginConfigs[pluginID] = config
            }
        }
    }

    // MARK: - Utility

    /// Check if a plugin is registered
    /// - Parameter pluginID: The plugin ID
    /// - Returns: True if registered
    public func isRegistered(pluginID: String) -> Bool {
        queue.sync {
            return pluginConfigs[pluginID] != nil
        }
    }
}
