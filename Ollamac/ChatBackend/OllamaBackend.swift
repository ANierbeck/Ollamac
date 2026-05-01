//
//  OllamaBackend.swift
//  Ollamac
//
//  Created for MCP Architecture Foundation - Phase 1
//

import Foundation
import OllamaKit

/// Ollama backend implementation conforming to ChatBackend protocol
public struct OllamaBackend: ChatBackend {
    public let baseURL: URL
    public let backendType: String = "Ollama"

    private let ollamaKit: OllamaKit

    public init(baseURL: URL) {
        self.baseURL = baseURL
        self.ollamaKit = OllamaKit(baseURL: baseURL)
    }

    public func reachable() async -> Bool {
        await ollamaKit.reachable()
    }

    public func listModels() async throws -> [String] {
        let response = try await ollamaKit.models()
        return response.models.map { $0.name }
    }

    public func chat(request: ChatRequest) async throws -> AsyncThrowingStream<ChatResponseChunk, Error> {
        let okRequest = convertToOKChatRequestData(request)

        return AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await chunk in ollamaKit.chat(data: okRequest) {
                        let responseChunk = convertToChatResponseChunk(chunk, model: request.model)
                        continuation.yield(responseChunk)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    // MARK: - Conversion Methods

    private func convertToOKChatRequestData(_ request: ChatRequest) -> OKChatRequestData {
        let messages = request.messages.map { chatMessage in
            OKChatRequestData.Message(
                role: convertRole(chatMessage.role),
                content: chatMessage.content
            )
        }

        let options = OKCompletionOptions(
            temperature: request.options?.temperature,
            topK: request.options?.topK,
            topP: request.options?.topP
        )

        var okRequest = OKChatRequestData(model: request.model, messages: messages)
        okRequest.options = options

        return okRequest
    }

    private func convertRole(_ role: ChatRole) -> OKChatRequestData.Message.Role {
        switch role {
        case .user:
            return .user
        case .assistant:
            return .assistant
        case .system:
            return .system
        }
    }

    private func convertToChatResponseChunk(_ chunk: OKChatResponse, model: String) -> ChatResponseChunk {
        let message: ChatMessage? = if let content = chunk.message?.content {
            ChatMessage(role: .assistant, content: content)
        } else {
            nil
        }

        return ChatResponseChunk(
            model: model,
            message: message,
            done: chunk.done
        )
    }
}
