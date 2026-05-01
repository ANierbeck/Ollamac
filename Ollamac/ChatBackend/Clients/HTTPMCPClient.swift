//
//  HTTPMCPClient.swift
//  Ollamac
//
//  Created for MCP Architecture Foundation - Phase 1
//

import Foundation

/// HTTP-based MCP client implementation using JSON-RPC 2.0 transport
public struct HTTPMCPClient: MCPClient {
    public let baseURL: URL
    private let urlSession: URLSession
    private var isConnected: Bool = false

    public init(baseURL: URL, urlSession: URLSession = .shared) {
        self.baseURL = baseURL
        self.urlSession = urlSession
    }

    public func connect() async -> Bool {
        do {
            let response: MCPListToolsResponse = try await sendRequest(method: "tools/list", params: nil)
            isConnected = true
            return true
        } catch {
            isConnected = false
            return false
        }
    }

    public func disconnect() async {
        isConnected = false
    }

    public func listTools() async throws -> [MCPTool] {
        let response: MCPListToolsResponse = try await sendRequest(method: "tools/list", params: nil)
        return response.tools
    }

    public func callTool(name: String, arguments: [String: Any]) async throws -> MCPToolResult {
        let params: [String: Any] = ["name": name, "arguments": arguments]
        let response: MCPCallToolResponse = try await sendRequest(method: "tools/call", params: params)
        return response.result
    }

    // MARK: - Private Methods

    private func sendRequest<T: Decodable>(method: String, params: [String: Any]?) async throws -> T {
        let requestBody = JSONRPCRequest(
            jsonrpc: "2.0",
            method: method,
            params: params,
            id: UUID().uuidString
        )

        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MCPError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw MCPError.httpError(statusCode: httpResponse.statusCode)
        }

        let jsonResponse = try JSONDecoder().decode(JSONRPCResponse<T>.self, from: data)

        if let error = jsonResponse.error {
            throw MCPError.rpcError(error)
        }

        guard let result = jsonResponse.result else {
            throw MCPError.noResult
        }

        return result
    }
}

// MARK: - JSON-RPC 2.0 Types

private struct JSONRPCRequest: Codable {
    let jsonrpc: String
    let method: String
    let params: [String: Any]?
    let id: String
}

private struct JSONRPCResponse<T: Decodable>: Codable {
    let jsonrpc: String
    let result: T?
    let error: JSONRPCError?
    let id: String
}

private struct JSONRPCError: Codable {
    let code: Int
    let message: String
    let data: AnyCodable?
}

// MARK: - MCP Response Types

private struct MCPListToolsResponse: Codable {
    let tools: [MCPTool]
}

private struct MCPCallToolResponse: Codable {
    let result: MCPToolResult
}

// MARK: - Error Handling

public enum MCPError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case rpcError(JSONRPCError)
    case noResult
    case decodingError(Error)
}

extension MCPError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .rpcError(let error):
            return "RPC error: \(error.message) (code: \(error.code))"
        case .noResult:
            return "No result in response"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        }
    }
}
