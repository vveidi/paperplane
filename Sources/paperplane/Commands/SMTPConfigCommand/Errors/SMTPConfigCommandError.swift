//
//  SMTPConfigCommandError.swift
//  paperplane
//
//  Created by Vadim on 28.06.2025.
//

import Foundation

enum SMTPConfigCommandError: LocalizedError {
    case failedToCreateConfig(error: Error)
    
    var errorDescription: String? {
        switch self {
        case .failedToCreateConfig(let error):
            return "Failed to create config: \(error)"
        }
    }
}
