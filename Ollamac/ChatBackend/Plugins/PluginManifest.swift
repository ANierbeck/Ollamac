//
//  PluginManifest.swift
//  Ollamac
//
//  Created for Phase 4: Plugin Architecture Foundation
//

import Foundation

/// Represents a plugin manifest parsed from Info.plist
public struct PluginManifest: Codable, Sendable {
    public let pluginID: String
    public let displayName: String
    public let description: String
    public let iconName: String
    public let version: String
    public let author: String?
    public let mainClass: String
    public let isBuiltIn: Bool

    public init(
        pluginID: String,
        displayName: String,
        description: String,
        iconName: String,
        version: String,
        author: String? = nil,
        mainClass: String,
        isBuiltIn: Bool = false
    ) {
        self.pluginID = pluginID
        self.displayName = displayName
        self.description = description
        self.iconName = iconName
        self.version = version
        self.author = author
        self.mainClass = mainClass
        self.isBuiltIn = isBuiltIn
    }

    /// Parse from Info.plist dictionary
    public static func fromDictionary(_ dict: [String: Any]) -> PluginManifest? {
        guard
            let pluginID = dict["PluginID"] as? String,
            let displayName = dict["DisplayName"] as? String,
            let description = dict["Description"] as? String,
            let iconName = dict["IconName"] as? String,
            let version = dict["Version"] as? String,
            let mainClass = dict["MainClass"] as? String
        else {
            return nil
        }

        let author = dict["Author"] as? String
        let isBuiltIn = dict["IsBuiltIn"] as? Bool ?? false

        return PluginManifest(
            pluginID: pluginID,
            displayName: displayName,
            description: description,
            iconName: iconName,
            version: version,
            author: author,
            mainClass: mainClass,
            isBuiltIn: isBuiltIn
        )
    }

    /// Convert to dictionary for Info.plist
    public func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "PluginID": pluginID,
            "DisplayName": displayName,
            "Description": description,
            "IconName": iconName,
            "Version": version,
            "MainClass": mainClass,
            "IsBuiltIn": isBuiltIn
        ]
        if let author = author {
            dict["Author"] = author
        }
        return dict
    }
}
