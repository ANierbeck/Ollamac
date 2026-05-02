//
//  PluginSettingsView.swift
//  Ollamac
//
//  Created for Phase 4: Plugin Architecture Foundation
//

import SwiftUI

/// View for managing plugin configurations
public struct PluginSettingsView: View {
    @State private var plugins: [any ChatPlugin] = []
    @State private var configs: [PluginConfig] = []
    @State private var isLoading = true

    private let pluginManager: PluginManager

    public init(pluginManager: PluginManager = .shared) {
        self.pluginManager = pluginManager
    }

    public var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading plugins...")
                    .padding()
            } else {
                pluginList
            }
        }
        .navigationTitle("Plugins")
        .onAppear {
            loadPlugins()
        }
    }

    private var pluginList: some View {
        Group {
            if plugins.isEmpty {
                VStack {
                    Image(systemName: "puzzlepiece")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                        .padding()
                    Text("No plugins available")
                        .foregroundColor(.secondary)
                    Text("Plugins will appear here once registered")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(configs, id: \.id) { config in
                        if let plugin = pluginManager.getPlugin(byID: config.id) {
                            PluginRowView(
                                plugin: plugin,
                                config: config,
                                onToggle: { isEnabled in
                                    updatePluginEnabled(config.id, isEnabled)
                                },
                                onUpdateURL: { newURL in
                                    updatePluginURL(config.id, newURL)
                                }
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Data Loading

    private func loadPlugins() {
        Task {
            await MainActor.run {
                isLoading = true
            }

            // Get all plugins from registry
            let allPlugins = pluginManager.getAllPlugins()
            
            // Get configs from store
            let configStore = PluginConfigStore.shared
            let allConfigs = configStore.loadConfigs()

            await MainActor.run {
                plugins = allPlugins
                configs = allConfigs
                isLoading = false
            }
        }
    }

    // MARK: - Update Handlers

    private func updatePluginEnabled(_ pluginID: String, _ isEnabled: Bool) {
        Task {
            let configStore = PluginConfigStore.shared
            configStore.togglePlugin(pluginID)
            
            // Update in registry
            PluginRegistry.shared.setPluginEnabled(pluginID, isEnabled)
            
            // Refresh the list
            loadPlugins()
        }
    }

    private func updatePluginURL(_ pluginID: String, _ newURL: URL) {
        Task {
            let configStore = PluginConfigStore.shared
            configStore.updateBaseURL(for: pluginID, newURL)
            
            // Update in registry
            if var config = PluginRegistry.shared.getConfig(for: pluginID) {
                config.baseURLString = newURL.absoluteString
                PluginRegistry.shared.updateConfig(for: pluginID, config)
            }
            
            // Refresh the list
            loadPlugins()
        }
    }
}

// MARK: - Plugin Row View

private struct PluginRowView: View {
    let plugin: any ChatPlugin
    let config: PluginConfig
    let onToggle: (Bool) -> Void
    let onUpdateURL: (URL) -> Void

    @State private var urlString: String
    @State private var isEditing = false

    init(plugin: any ChatPlugin, config: PluginConfig, onToggle: @escaping (Bool) -> Void, onUpdateURL: @escaping (URL) -> Void) {
        self.plugin = plugin
        self.config = config
        self.onToggle = onToggle
        self.onUpdateURL = onUpdateURL
        self._urlString = State(initialValue: config.baseURL.absoluteString)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: type(of: plugin).iconName)
                    .foregroundColor(.accentColor)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(config.displayName)
                        .font(.headline)

                    Text(type(of: plugin).description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Toggle("", isOn: Binding(
                    get: { config.isEnabled },
                    set: { isEnabled in
                        onToggle(isEnabled)
                    }
                ))
                .labelsHidden()
            }

            if isEditing {
                HStack {
                    TextField("Base URL", text: $urlString)
                        .textFieldStyle(.roundedBorder)

                    Button("Save") {
                        if let newURL = URL(string: urlString) {
                            onUpdateURL(newURL)
                            isEditing = false
                        }
                    }
                    .disabled(URL(string: urlString) == nil)

                    Button("Cancel") {
                        urlString = config.baseURL.absoluteString
                        isEditing = false
                    }
                }
            } else {
                HStack {
                    Text(config.baseURL.absoluteString)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Button("Edit") {
                        isEditing = true
                    }
                    .font(.caption)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

#Preview {
    PluginSettingsView()
}
