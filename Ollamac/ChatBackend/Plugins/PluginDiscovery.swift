//
//  PluginDiscovery.swift
//  Ollamac
//
//  Created for Phase 4: Plugin Architecture Foundation
//

import Foundation

/// Discovers and loads plugins from bundles
public final class PluginDiscovery {
    private let pluginRegistry: PluginRegistry
    private let builtInPlugins: [any ChatPlugin.Type]

    public init(pluginRegistry: PluginRegistry, builtInPlugins: [any ChatPlugin.Type] = []) {
        self.pluginRegistry = pluginRegistry
        self.builtInPlugins = builtInPlugins
    }

    // MARK: - Discovery

    /// Scan for all available plugins (both built-in and bundled)
    /// - Returns: Array of discovered plugin types
    public func scanForPlugins() async -> [any ChatPlugin.Type] {
        // First, register built-in plugins
        let builtIn = await registerBuiltInPlugins()

        // Then, scan for bundled plugins
        let bundled = await scanForBundledPlugins()

        return builtIn + bundled
    }

    /// Register built-in plugins (Ollama, MCP, etc.)
    private func registerBuiltInPlugins() async -> [any ChatPlugin.Type] {
        for pluginType in builtInPlugins {
            pluginRegistry.register(pluginType: pluginType)
        }
        return builtInPlugins
    }

    /// Scan for plugins in .plugin bundles
    private func scanForBundledPlugins() async -> [any ChatPlugin.Type] {
        var discoveredPlugins: [any ChatPlugin.Type] = []

        do {
            // Get all plugin bundles
            let pluginBundles = getPluginBundles()

            for bundle in pluginBundles {
                if let pluginType = try await loadPlugin(from: bundle) {
                    pluginRegistry.register(pluginType: pluginType)
                    discoveredPlugins.append(pluginType)
                }
            }
        } catch {
            print("Plugin discovery error: \(error)")
        }

        return discoveredPlugins
    }

    /// Get all .plugin bundles in the application
    private func getPluginBundles() -> [Bundle] {
        // Main application bundle
        var bundles: [Bundle] = [.main]

        // Get all loaded bundles (including plugins)
        // Note: This is a simplified approach. In production, you would:
        // 1. Look for .plugin directories in Application Support
        // 2. Load bundles dynamically
        // 3. Handle sandboxing on macOS

        // For now, we return the main bundle
        // Plugin loading will be implemented more fully in a future update
        return bundles
    }

    /// Load a plugin from a bundle
    private func loadPlugin(from bundle: Bundle) async throws -> (any ChatPlugin.Type)? {
        // Get the bundle's Info.plist
        guard let infoDict = bundle.infoDictionary else {
            return nil
        }

        // Parse the manifest
        guard let manifest = PluginManifest.fromDictionary(infoDict) else {
            return nil
        }

        // Check if the main class exists and conforms to ChatPlugin
        guard let mainClassName = infoDict["NSPrincipalClass"] as? String ?? manifest.mainClass as? String else {
            return nil
        }

        guard let principalClass = bundle.principalClass as? any ChatPlugin.Type else {
            return nil
        }

        return principalClass
    }

    // MARK: - Manifest Parsing

    /// Parse manifest from Info.plist in a bundle
    public func parseManifest(from bundle: Bundle) -> PluginManifest? {
        guard let infoDict = bundle.infoDictionary else {
            return nil
        }
        return PluginManifest.fromDictionary(infoDict)
    }

    /// Get manifest for a registered plugin type
    public func getManifest(for pluginType: any ChatPlugin.Type) -> PluginManifest? {
        // For built-in plugins, we create the manifest from the static properties
        return PluginManifest(
            pluginID: pluginType.pluginID,
            displayName: pluginType.displayName,
            description: pluginType.description,
            iconName: pluginType.iconName,
            version: "1.0.0",
            mainClass: String(describing: pluginType),
            isBuiltIn: true
        )
    }

    // MARK: - Plugin Loading

    /// Load and register a plugin by its manifest
    /// - Parameter manifest: The plugin manifest
    /// - Returns: The loaded plugin instance or nil
    public func loadPlugin(with manifest: PluginManifest) async -> (any ChatPlugin)? {
        // This would be more complex in a real implementation
        // For now, we assume built-in plugins are already registered
        return nil
    }

    /// Initialize all registered plugins with their configurations
    public func initializePlugins() async {
        let pluginTypes = pluginRegistry.getAllPluginTypes()

        for pluginType in pluginTypes {
            await initializePlugin(pluginType)
        }
    }

    private func initializePlugin(_ pluginType: any ChatPlugin.Type) async {
        // Get default configuration for this plugin
        let defaultConfig = PluginConfig(
            id: pluginType.pluginID,
            isEnabled: true,
            baseURL: getDefaultBaseURL(for: pluginType)
        )

        // Create instance and register
        let instance = pluginType.createInstance(config: defaultConfig)
        pluginRegistry.registerPlugin(instance, config: defaultConfig)
    }

    private func getDefaultBaseURL(for pluginType: any ChatPlugin.Type) -> URL {
        switch pluginType.pluginID {
        case "ollama": return URL(string: "http://localhost:11434")!
        case "mcp": return URL(string: "http://localhost:8080")!
        default: return URL(string: "http://localhost:8080")!
        }
    }
}
