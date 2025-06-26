//
//  SendBookConfigHandler.swift
//  paperplane
//
//  Created by Vadim on 24.06.2025.
//

import Foundation

struct SendBookConfigHandler {
    
    static let configURLPath = ".paperplane/paperplane.json"
    
    static func create(sender: String?, receiver: String?, path: String?) throws(SendBookCommandError) -> SendBookConfig {
        let configuration = SendBookConfigHandler.load()
        guard let sender = sender ?? configuration?.sender,
              let receiver = receiver ?? configuration?.receiver,
              let path = path ?? configuration?.fileURL.path else {
            throw .parameterValidationFailed
        }
        guard !sender.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, sender.contains("@"),
              !receiver.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, receiver.contains("@") else {
            throw .invalidEmailAddress
        }
        guard !path.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              FileManager.default.fileExists(atPath: path) else {
            throw .parameterValidationFailed
        }
        return SendBookConfig(sender: sender, receiver: receiver, path: path)
    }
    
    static func load() -> SendBookConfig? {
        let configURL = FileManager.default.homeDirectoryForCurrentUser.appending(path: configURLPath)
        guard let data = try? Data(contentsOf: configURL) else {
            return nil
        }
        return try? JSONDecoder().decode(SendBookConfig.self, from: data)
    }
    
    static func save(_ config: SendBookConfig) {
        let configURL = FileManager.default.homeDirectoryForCurrentUser.appending(path: configURLPath)
        guard let data = try? JSONEncoder().encode(config) else {
            return
        }
        try? data.write(to: configURL)
    }
}
