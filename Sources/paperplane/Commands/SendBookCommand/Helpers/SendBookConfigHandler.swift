//
//  SendBookConfigHandler.swift
//  paperplane
//
//  Created by Vadim on 24.06.2025.
//

import Foundation

struct SendBookConfigHandler {
    
    static func merge(configuration: SendBookConfig?, userInput: SendBookUserInput) throws(SendBookCommandError) -> SendBookConfig {
        guard let sender = userInput.sender ?? configuration?.sender,
              let receiver = userInput.receiver ?? configuration?.receiver,
              let path = userInput.path ?? configuration?.fileURL.path else {
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
        guard let data = try? Data(contentsOf: SendBookConfig.path) else {
            return nil
        }
        return try? JSONDecoder().decode(SendBookConfig.self, from: data)
    }
    
    static func save(_ config: SendBookConfig) throws(SendBookCommandError) {
        do {
            try? FileManager.default.createDirectory(at: Path.settingsDirectory, withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(config)
            try data.write(to: SendBookConfig.path)
        } catch {
            throw .configSavingFailed(error: error)
        }
    }
}
