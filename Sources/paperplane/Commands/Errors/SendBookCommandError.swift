//
//  SendBookCommandError.swift
//  paperplane
//
//  Created by Vadim on 20.06.2025.
//

import Foundation

enum SendBookCommandError: LocalizedError {
    case processFailedToStart(error: Error)
    case bookFileReadFailed(error: Error)
    case invalidEmailAddress
    case messageEncodingFailed
    case processTerminated(code: Int, description: String)
    case unsupportedBookFileFormat
    
    var errorDescription: String? {
        switch self {
        case .processFailedToStart(let error):
            return "Failed to launch msmtp process: \(error.localizedDescription)"
        case .bookFileReadFailed(let error):
            return "Failed to read file for attachment: \(error.localizedDescription)"
        case .invalidEmailAddress:
            return "Invalid sender or receiver email address. Please check both addresses."
        case .messageEncodingFailed:
            return "Failed to encode MIME message. There may be a problem with the message content."
        case .processTerminated(let code, let description):
            if !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "msmtp exited with code \(code). stderr: \(description)"
            } else {
                return "msmtp exited with code \(code) and no error output."
            }
        case .unsupportedBookFileFormat:
            let supportedFormats = BookAttachment.allowedExtensions.joined(separator: ", ")
            return "Unsupported book file format. Please, use one of the supported formats: \(supportedFormats)."
        }
    }
}
