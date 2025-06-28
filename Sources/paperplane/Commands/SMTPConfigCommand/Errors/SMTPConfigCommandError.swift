//
//  SMTPConfigCommandError.swift
//  paperplane
//
//  Created by Vadim on 28.06.2025.
//

import Foundation

enum SMTPConfigCommandError: LocalizedError {
    case failedToCreateConfig(error: Error)
    case invalidSMTPConfigParameter(String)
    case failedToParseSMTPConfigFile
    
    var errorDescription: String? {
        switch self {
        case .failedToCreateConfig(let error):
            return "Failed to create config: \(error)"
        case .invalidSMTPConfigParameter(let parameter):
            return "Invalid SMTP config parameter: \(parameter)"
        case .failedToParseSMTPConfigFile:
            return "Failed to parse SMTP config file"
        }
    }
}
