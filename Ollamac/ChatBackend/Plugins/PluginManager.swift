//
//  PluginManager.swift
//  Ollamac
//
//  Created for Phase 4: Plugin Architecture Foundation
//

import Foundation

/// Manages the lifecycle of plugins in the application
public final class PluginManager {
    private let registry: PluginRegistry
    private let discovery: PluginDiscovery

    @MainActor public static let shared = PluginManager(registry: .shared, discovery: .init(pluginRegistry: .shared))

    private init(registry: PluginRegistry, discovery: PluginDiscovery) {
        self.registry = registry
        self.discovery = discovery
    }

    // MARK: - Initialization

    /// Initialize the plugin system
    /// Should be called early in the app lifecycle (e.g., in App init)
    public func initialize() async {
        // Register built-in plugin types
        await registerBuiltInPluginTypes()

        // Discover and load plugins
        _ = await discovery.scanForPlugins()

        // Initialize plugins with default configs
        await discovery.initializePlugins()

        print("PluginManager: \(getAllPlugins().count) plugins loaded")
    }

    /// Register built-in plugin types
    private func registerBuiltInPluginTypes() async {
        // In a real implementation, these would be the concrete plugin types
        // For now, we rely on PluginDiscovery to handle registration
    }

    // MARK: - Plugin Access

    /// Get all loaded plugins
    public func getAllPlugins() -> [any ChatPlugin] {
        registry.getAllPlugins()
    }

    /// Get all enabled plugins
    public func getEnabledPlugins() -> [any ChatPlugin] {
        registry.getEnabledPlugins()
    }

    /// Get a specific plugin by ID
    public func getPlugin(byID id: String) -> (any ChatPlugin)? {
        registry.getPlugin(byID: id)
    }

    /// Get all plugin types
    public func getAllPluginTypes() -> [any ChatPlugin.Type] {
        registry.getAllPluginTypes()
    }

    // MARK: - Configuration

    /// Enable a plugin
    public func enablePlugin(_ pluginID: String) {
        registry.setPluginEnabled(pluginID, true)
    }

    /// Disable a plugin
    public func disablePlugin(_ pluginID: String) {
        registry.setPluginEnabled(pluginID, false)
    }

    /// Toggle plugin enabled state
    public func togglePlugin(_ pluginID: String) {
        if let config = registry.getConfig(for: pluginID) {
            registry.setPluginEnabled(pluginID, !config.isEnabled)
        }
    }

    /// Update plugin configuration
    public func updateConfig(for pluginID: String, _ config: PluginConfig) {
        registry.updateConfig(for: pluginID, config)
    }

    /// Get plugin configuration
    public func getConfig(for pluginID: String) -> PluginConfig? {
        registry.getConfig(for: pluginID)
    }

    // MARK: - Current Backend

    /// Get the current active backend
    /// In a full implementation, this would come from the ChatBackendEnvironment
    public func getCurrentBackend() -> (any ChatBackend)? {
        let enabledPlugins = getEnabledPlugins()
        // Return the first enabled plugin as the current backend
        // In practice, the user would select which backend to use
        return enabledPlugins.first as? any ChatBackend
    }

    // MARK: - Plugin Information

    /// Get manifest for a plugin type
    public func getManifest(for pluginType: any ChatPlugin.Type) -> PluginManifest? {
        discovery.getManifest(for: pluginType)
    }

    /// Get display name for a plugin
    public func getDisplayName(for pluginType: any ChatPlugin.Type) -> String {
        pluginType.displayName
    }

    /// Get description for a plugin
    public func getDescription(for pluginType: any ChatPlugin.Type) -> String {
        pluginType.description
    }

    /// Get icon name for a plugin
    public func getIconName(for pluginType: any ChatPlugin.Type) -> String {
        pluginType.iconName
    }
}
