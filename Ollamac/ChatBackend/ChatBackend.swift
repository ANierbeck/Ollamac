//
//  ChatBackend.swift
//  Ollamac
//
//  Created for MCP Architecture Foundation - Phase 1
//

import Foundation

/// Protocol for all chat backends (Ollama, MCP, etc.)
/// Provides a unified interface for chat operations.
public protocol ChatBackend: Sendable {
    /// Base URL of the backend server (for display/diagnostic purposes)
    var baseURL: URL { get }

    /// Type of backend for UI display
    /// - Example: "Ollama", "MCP", "OpenAI", etc.
    var backendType: String { get }

    /// Check if the backend server is reachable
    /// - Returns: `true` if the server responds to health checks, `false` otherwise
    func reachable() async -> Bool

    /// Get list of available models
    /// - Returns: Array of model name strings
    /// - Throws: Error if models cannot be fetched
    func listModels() async throws -> [String]

    /// Send a chat message and receive streaming response
    /// - Parameter request: The chat request containing model, messages, and options
    /// - Returns: Async stream of response chunks
    /// - Throws: Error if chat cannot be initiated
    func chat(request: ChatRequest) async throws -> AsyncThrowingStream<ChatResponseChunk, Error>
}

// MARK: - Supporting Types

/// Role of a participant in a chat conversation
public enum ChatRole: String, Codable, Sendable {
    /// User message (from the human)
    case user
    /// Assistant message (from the AI)
    case assistant
    /// System message (instructions/prompt)
    case system
}

/// Individual message in a chat conversation
public struct ChatMessage: Codable, Sendable {
    /// Role of the message sender
    public let role: ChatRole
    /// Content of the message
    public let content: String

    public init(role: ChatRole, content: String) {
        self.role = role
        self.content = content
    }
}

/// Options for chat completion
public struct ChatOptions: Codable, Sendable {
    /// Sampling temperature (0.0 - 1.0)
    /// Lower = more deterministic, Higher = more creative
    public var temperature: Double?
    /// Top-K sampling (number of highest probability vocabulary tokens to keep)
    public var topK: Int?
    /// Top-p sampling (cumulative probability threshold)
    public var topP: Double?

    public init(temperature: Double? = nil, topK: Int? = nil, topP: Double? = nil) {
        self.temperature = temperature
        self.topK = topK
        self.topP = topP
    }
}

/// Complete chat request to send to a backend
public struct ChatRequest: Codable, Sendable {
    /// Model to use for completion
    public let model: String
    /// List of messages in the conversation
    public let messages: [ChatMessage]
    /// Completion options (optional)
    public let options: ChatOptions?

    public init(model: String, messages: [ChatMessage], options: ChatOptions? = nil) {
        self.model = model
        self.messages = messages
        self.options = options
    }
}

/// A single chunk of a streaming chat response
public struct ChatResponseChunk: Codable {
    /// Model that generated this response
    public let model: String
    /// Message content (may be nil for non-content chunks like done signals)
    public let message: ChatMessage?
    /// Whether this is the final chunk in the stream
    public let done: Bool

    public init(model: String, message: ChatMessage?, done: Bool) {
        self.model = model
        self.message = message
        self.done = done
    }
}
