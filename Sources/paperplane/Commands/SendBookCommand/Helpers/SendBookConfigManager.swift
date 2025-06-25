//
//  SendBookConfigManager.swift
//  paperplane
//
//  Created by Vadim on 24.06.2025.
//

import Foundation

struct SendBookConfigManager {
    
    static func load() -> SendBookConfig? {
        let configURL = FileManager.default.homeDirectoryForCurrentUser.appending(path: ".paperplane.json")
        guard let data = try? Data(contentsOf: configURL) else {
            return nil
        }
        return try? JSONDecoder().decode(SendBookConfig.self, from: data)
    }
    
    static func save(_ config: SendBookConfig) {
        let configURL = FileManager.default.homeDirectoryForCurrentUser.appending(path: ".paperplane.json")
        guard let data = try? JSONEncoder().encode(config) else {
            return
        }
        try? data.write(to: configURL)
    }
}
