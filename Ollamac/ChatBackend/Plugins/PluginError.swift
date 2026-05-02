//
//  PluginError.swift
//  Ollamac
//
//  Created for Phase 4: Plugin Architecture Foundation
//

import Foundation

/// Errors that can occur during plugin operations
public enum PluginError: Error, LocalizedError {
    case pluginNotFound(String)
    case pluginAlreadyRegistered(String)
    case invalidPluginType
    case loadingFailed(String)
    case manifestInvalid(String)
    case initializationFailed(String)
    case configurationInvalid(String)

    public var errorDescription: String? {
        switch self {
        case .pluginNotFound(let id):
            return "Plugin '" + id + "' not found"
        case .pluginAlreadyRegistered(let id):
            return "Plugin '" + id + "' already registered"
        case .invalidPluginType:
            return "Invalid plugin type"
        case .loadingFailed(let reason):
            return "Plugin loading failed: " + reason
        case .manifestInvalid(let reason):
            return "Plugin manifest invalid: " + reason
        case .initializationFailed(let reason):
            return "Plugin initialization failed: " + reason
        case .configurationInvalid(let reason):
            return "Plugin configuration invalid: " + reason
        }
    }
}
