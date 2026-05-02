//
//  PluginConfigStore.swift
//  Ollamac
//
//  Created for Phase 4: Plugin Architecture Foundation
//

import Defaults
import Foundation

/// Stores plugin configurations in UserDefaults using the Defaults library
public final class PluginConfigStore {
    private static let configsKey = Defaults.Key<[PluginConfig]>("pluginConfigs", default: [])

    @MainActor public static let shared = PluginConfigStore()

    private init() {}

    // MARK: - Load/Save

    /// Load all plugin configurations
    public func loadConfigs() -> [PluginConfig] {
        Defaults[Self.configsKey]
    }

    /// Save all plugin configurations
    public func saveConfigs(_ configs: [PluginConfig]) {
        Defaults[Self.configsKey] = configs
    }

    // MARK: - Individual Configs

    /// Get configuration for a specific plugin
    public func getConfig(for pluginID: String) -> PluginConfig? {
        loadConfigs().first { $0.id == pluginID }
    }

    /// Save configuration for a specific plugin
    public func saveConfig(_ config: PluginConfig) {
        var configs = loadConfigs()
        if let index = configs.firstIndex(where: { $0.id == config.id }) {
            configs[index] = config
        } else {
            configs.append(config)
        }
        saveConfigs(configs)
    }

    /// Remove configuration for a plugin
    public func removeConfig(for pluginID: String) {
        var configs = loadConfigs()
        configs.removeAll { $0.id == pluginID }
        saveConfigs(configs)
    }

    // MARK: - Enable/Disable

    /// Enable a plugin
    public func enablePlugin(_ pluginID: String) {
        if var config = getConfig(for: pluginID) {
            config.isEnabled = true
            saveConfig(config)
        }
    }

    /// Disable a plugin
    public func disablePlugin(_ pluginID: String) {
        if var config = getConfig(for: pluginID) {
            config.isEnabled = false
            saveConfig(config)
        }
    }

    /// Toggle plugin enabled state
    public func togglePlugin(_ pluginID: String) {
        if var config = getConfig(for: pluginID) {
            config.isEnabled.toggle()
            saveConfig(config)
        }
    }

    // MARK: - Update Base URL

    /// Update the base URL for a plugin
    public func updateBaseURL(for pluginID: String, _ url: URL) {
        if var config = getConfig(for: pluginID) {
            config.baseURLString = url.absoluteString
            saveConfig(config)
        }
    }

    // MARK: - Default Configs

    /// Get default configurations for built-in plugins
    public static var defaultConfigs: [PluginConfig] {
        [.ollama, .mcp]
    }

    /// Initialize with default configurations if none exist
    public func initializeDefaults() {
        let existing = loadConfigs()
        if existing.isEmpty {
            saveConfigs(Self.defaultConfigs)
        }
    }

    /// Reset to default configurations
    public func resetToDefaults() {
        saveConfigs(Self.defaultConfigs)
    }
}
