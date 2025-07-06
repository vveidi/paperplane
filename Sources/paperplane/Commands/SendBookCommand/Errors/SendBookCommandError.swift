//
//  SendBookCommandError.swift
//  paperplane
//
//  Created by Vadim on 20.06.2025.
//

import Foundation

enum SendBookCommandError: LocalizedError {
    case invalidEmailAddress
    case unsupportedBookFileFormat
    case parameterValidationFailed
    case fileRemovalFailed(error: Error)
    case configSavingFailed(error: Error)
    case failedToCreateAttachments
    case failedToSendEmail(error: Error)
    case failedToParseSMTPConfigFile
    case failedToParseSendBookConfigFile
    case sendingExplicitlyCancelled
    
    var errorDescription: String? {
        switch self {
        case .invalidEmailAddress:
            return "❌ Invalid sender or receiver email address. Please check both addresses."
        case .unsupportedBookFileFormat:
            let supportedFormats = BookAttachment.supportedFileTypes.joined(separator: ", ")
            return "❌ Unsupported book file format. Please, use one of the supported formats: \(supportedFormats)."
        case .parameterValidationFailed:
            return "❌ Validation failed. Please check all parameters."
        case .fileRemovalFailed(let error):
            return "❌ Failed to remove book file: \(error.localizedDescription)"
        case .configSavingFailed(let error):
            return "❌ Failed to save config file: \(error)"
        case .failedToCreateAttachments:
            return "❌ Failed to create attachments."
        case .failedToSendEmail(let error):
            return "❌ Failed to send email: \(error)"
        case .failedToParseSMTPConfigFile:
            return "❌ Failed to parse SMTP config file."
        case .failedToParseSendBookConfigFile:
            return "❌ Failed to parse send-book config file."
        case .sendingExplicitlyCancelled:
            return "❌ Sending was cancelled by the user."
        }
    }
}
