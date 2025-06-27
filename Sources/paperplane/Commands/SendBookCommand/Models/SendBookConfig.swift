//
//  SendBookConfig.swift
//  paperplane
//
//  Created by Vadim on 23.06.2025.
//

import Foundation

struct SendBookConfig: Codable, Equatable {
    let sender: String
    let receiver: String
    let fileURL: URL
}

extension SendBookConfig {
    init(sender: String, receiver: String, path: String) {
        self.sender = sender
        self.receiver = receiver
        self.fileURL = URL(filePath: path)
    }
}
