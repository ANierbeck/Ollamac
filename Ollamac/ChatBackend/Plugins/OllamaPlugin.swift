//
//  OllamaPlugin.swift
//  Ollamac
//
//  Created for Phase 4: Plugin Architecture Foundation
//

import Foundation
import OllamaKit

/// OllamaBackend as a plugin
/// Wraps the OllamaKit functionality in the ChatPlugin protocol
public final class OllamaPlugin: ChatPlugin {
    public static let pluginID: String = "ollama"
    public static let displayName: String = "Ollama"
    public static let description: String = "Ollama local LLM backend"
    public static let iconName: String = "flame"

    public let baseURL: URL
    public let backendType: String
    public let config: PluginConfig

    private let ollamaKit: OllamaKit

    public static func createInstance(config: PluginConfig) -> OllamaPlugin {
        return OllamaPlugin(config: config)
    }

    public init(config: PluginConfig) {
        self.config = config
        self.baseURL = config.baseURL
        self.backendType = Self.pluginID
        self.ollamaKit = OllamaKit(baseURL: config.baseURL)
    }

    // MARK: - ChatBackend Implementation

    public func reachable() async -> Bool {
        do {
            let reachable = try await ollamaKit.reachable()
            return reachable
        } catch {
            return false
        }
    }

    public func listModels() async throws -> [String] {
        let response = try await ollamaKit.models()
        return response.models.map { $0.name }
    }

    public func chat(request: ChatRequest) async throws -> AsyncThrowingStream<ChatResponseChunk, Error> {
        // Convert ChatRequest.messages to prompt and system for OllamaKit
        let systemMessage = request.messages.first { $0.role == .system }?.content
        let userMessages = request.messages.filter { $0.role == .user }
        let prompt = userMessages.map { $0.content }.joined(separator: "\n")
        
        // Create request data for OllamaKit
        var requestData = OKGenerateRequestData(
            model: request.model,
            prompt: prompt
        )
        requestData.system = systemMessage
        
        let ollamaStream = ollamaKit.generate(data: requestData)
        
        // Convert AsyncThrowingStream<OKGenerateResponse, Error> to AsyncThrowingStream<ChatResponseChunk, Error>
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await response in ollamaStream {
                        let message = ChatMessage(
                            role: .assistant,
                            content: response.response
                        )
                        let chunk = ChatResponseChunk(
                            model: response.model,
                            message: message,
                            done: response.done
                        )
                        continuation.yield(chunk)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
