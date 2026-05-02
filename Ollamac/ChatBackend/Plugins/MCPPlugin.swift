//
//  MCPPlugin.swift
//  Ollamac
//
//  Created for Phase 4: Plugin Architecture Foundation
//

import Foundation

/// MCPBackend as a plugin
public final class MCPPlugin: ChatPlugin {
    public static let pluginID: String = "mcp"
    public static let displayName: String = "MCP"
    public static let description: String = "Model Context Protocol backend for connecting to MCP servers"
    public static let iconName: String = "server.rack"

    public let baseURL: URL
    public let backendType: String
    public let config: PluginConfig

    private let client: any MCPClient

    public static func createInstance(config: PluginConfig) -> MCPPlugin {
        let httpClient = HTTPMCPClient(baseURL: config.baseURL)
        return MCPPlugin(config: config, client: httpClient)
    }

    public init(config: PluginConfig, client: any MCPClient) {
        self.config = config
        self.baseURL = config.baseURL
        self.backendType = Self.pluginID
        self.client = client
    }

    public convenience init(config: PluginConfig) {
        let httpClient = HTTPMCPClient(baseURL: config.baseURL)
        self.init(config: config, client: httpClient)
    }

    // MARK: - ChatBackend Implementation

    public func reachable() async -> Bool {
        await client.connect()
    }

    public func listModels() async throws -> [String] {
        let tools = try await client.listTools()
        return tools.map { $0.name }
    }

    public func chat(request: ChatRequest) async throws -> AsyncThrowingStream<ChatResponseChunk, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    // For Phase 4, we'll simulate a basic chat response
                    // In the future, this will detect tool calls and invoke them via client.callTool()
                    let responseText = "Response from \(request.model)"

                    let message = ChatMessage(role: .assistant, content: responseText)
                    let chunk = ChatResponseChunk(
                        model: request.model,
                        message: message,
                        done: true
                    )
                    continuation.yield(chunk)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

// MARK: - Legacy MCPBackend compatibility

// Keep the original MCPBackend struct for backward compatibility
extension MCPBackend {
    /// Convert MCPBackend to a plugin configuration
    public func asPluginConfig() -> PluginConfig {
        PluginConfig(
            id: "mcp",
            isEnabled: true,
            baseURL: baseURL
        )
    }
}
