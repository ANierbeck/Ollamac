//
//  MCPBackend.swift
//  Ollamac
//
//  Created for MCP Architecture Foundation - Phase 1
//

import Foundation

/// MCP backend implementation conforming to ChatBackend protocol
/// Uses an MCPClient internally to communicate with MCP servers
public struct MCPBackend: ChatBackend {
    public let baseURL: URL
    public let backendType: String = "MCP"

    private let client: any MCPClient

    public init(baseURL: URL, client: any MCPClient) {
        self.baseURL = baseURL
        self.client = client
    }

    public init(baseURL: URL) {
        let httpClient = HTTPMCPClient(baseURL: baseURL)
        self.init(baseURL: baseURL, client: httpClient)
    }

    public func reachable() async -> Bool {
        await client.connect()
    }

    public func listModels() async throws -> [String] {
        let tools = try await client.listTools()
        return tools.map { $0.name }
    }

    public func chat(request: ChatRequest) async throws -> AsyncThrowingStream<ChatResponseChunk, Error> {
        // Phase 1: Basic implementation - return model response without tool detection
        // Tool call detection will be implemented in Phase 2

        return AsyncThrowingStream { continuation in
            Task {
                do {
                    // For Phase 1, we'll simulate a basic chat response
                    // In Phase 2, this will detect tool calls and invoke them via client.callTool()
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
