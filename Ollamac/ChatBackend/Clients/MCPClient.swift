//
//  MCPClient.swift
//  Ollamac
//
//  Created for MCP Architecture Foundation - Phase 1
//

import Foundation

// MARK: - MCPClient Protocol

/// Protocol for Model Context Protocol (MCP) clients
/// Defines the interface for connecting to and interacting with MCP servers
public protocol MCPClient: Sendable {
    /// Connect to the MCP server
    /// - Returns: `true` if connection succeeds, `false` otherwise
    func connect() async -> Bool

    /// Disconnect from the MCP server
    func disconnect() async

    /// List all available tools provided by the MCP server
    /// - Returns: Array of available tools
    /// - Throws: Error if tools cannot be fetched
    func listTools() async throws -> [MCPTool]

    /// Call a specific tool with arguments
    /// - Parameters:
    ///   - name: The name of the tool to call
    ///   - arguments: Dictionary of argument name to value
    /// - Returns: The result of the tool call
    /// - Throws: Error if tool call fails
    func callTool(name: String, arguments: [String: Any]) async throws -> MCPToolResult
}

// MARK: - Supporting Types

/// Represents an MCP tool (function/endpoint) provided by a server
public struct MCPTool: Codable, Sendable {
    /// Unique name of the tool
    public let name: String
    /// Human-readable description of the tool
    public let description: String?
    /// Input schema defining the parameters this tool accepts
    public let inputSchema: MCPToolInputSchema

    public init(name: String, description: String?, inputSchema: MCPToolInputSchema) {
        self.name = name
        self.description = description
        self.inputSchema = inputSchema
    }
}

/// Defines the input schema for an MCP tool
public struct MCPToolInputSchema: Codable, Sendable {
    /// Type of the input (default: "object")
    public let type: String
    /// Properties (parameters) of the input
    public let properties: [String: MCPPropertySchema]?
    /// Required property names
    public let required: [String]?

    public init(type: String = "object", properties: [String: MCPPropertySchema]? = nil, required: [String]? = nil) {
        self.type = type
        self.properties = properties
        self.required = required
    }
}

/// Defines the schema for a single property in an MCP tool input
public struct MCPPropertySchema: Codable, Sendable {
    /// Type of the property (string, number, boolean, array, object, etc.)
    public let type: String
    /// Human-readable description of the property
    public let description: String?
    /// Default value (if any)
    public let defaultValue: AnyCodable?
    /// For array types: type of items (simplified for Phase 1)
    public let itemsType: String?
    /// Enum values (if property is constrained to specific values)
    public let enumValues: [String]?

    public init(
        type: String,
        description: String? = nil,
        defaultValue: AnyCodable? = nil,
        itemsType: String? = nil,
        enumValues: [String]? = nil
    ) {
        self.type = type
        self.description = description
        self.defaultValue = defaultValue
        self.itemsType = itemsType
        self.enumValues = enumValues
    }
}

/// Result of calling an MCP tool
public struct MCPToolResult: Codable, Sendable {
    /// Content returned by the tool
    public let content: [MCPTextContent]
    /// Whether the tool call is complete
    public let isError: Bool?
    /// Error message if the tool call failed
    public let error: String?

    public init(content: [MCPTextContent], isError: Bool? = nil, error: String? = nil) {
        self.content = content
        self.isError = isError
        self.error = error
    }
}

/// Text content in MCP responses
public struct MCPTextContent: Codable, Sendable {
    /// Type of content (default: "text")
    public let type: String
    /// The actual text content
    public let text: String

    public init(type: String = "text", text: String) {
        self.type = type
        self.text = text
    }
}

// MARK: - AnyCodable for flexible property values

/// A type-erased Codable wrapper for handling arbitrary JSON values
public struct AnyCodable: Codable, Sendable {
    public let value: Any

    public init(_ value: Any) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let string = try? container.decode(String.self) {
            self.value = string
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            self.value = dict.mapValues { $0.value }
        } else if container.decodeNil() {
            self.value = Optional<Any>.none as Any
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Value cannot be decoded"
                )
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case let string as String:
            try container.encode(string)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let bool as Bool:
            try container.encode(bool)
        case let array as [Any]:
            let codableArray = array.map { AnyCodable($0) }
            try container.encode(codableArray)
        case let dict as [String: Any]:
            let codableDict = dict.mapValues { AnyCodable($0) }
            try container.encode(codableDict)
        case Optional<Any>.none:
            try container.encodeNil()
        default:
            throw EncodingError.invalidValue(
                value,
                EncodingError.Context(
                    codingPath: encoder.codingPath,
                    debugDescription: "Value cannot be encoded"
                )
            )
        }
    }
}
