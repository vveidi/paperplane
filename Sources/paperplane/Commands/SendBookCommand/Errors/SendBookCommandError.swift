//
//  SendBookCommandError.swift
//  paperplane
//
//  Created by Vadim on 20.06.2025.
//

import Foundation

enum SendBookCommandError: LocalizedError {
    case messageEncodingFailed
    case bookFileReadFailed(error: Error)
    case invalidEmailAddress
    case processTerminated(code: Int, description: String)
    case processFailedToStart(error: Error)
    case unsupportedBookFileFormat
    case exceededMaxAttachmentSize
    case exceededMaxAttachmentCount
    case configNotFound(error: Error)
    case parameterValidationFailed
    case fileRemovalFailed(error: Error)
    
    var errorDescription: String? {
        switch self {
        case .messageEncodingFailed:
            return "Failed to encode or write the email message."
        case .bookFileReadFailed(let error):
            return "Failed to read file for attachment: \(error.localizedDescription)"
        case .invalidEmailAddress:
            return "Invalid sender or receiver email address. Please check both addresses."
        case .processTerminated(let code, let description):
            if !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "Failed: msmtp exited with code \(code). stderr: \(description)"
            } else {
                return "Failed: msmtp exited with code \(code) and no error output."
            }
        case .processFailedToStart(let error):
            return "Failed to start msmtp process: \(error.localizedDescription)"
        case .unsupportedBookFileFormat:
            let supportedFormats = BookAttachment.allowedExtensions.joined(separator: ", ")
            return "Failed: Unsupported book file format. Please, use one of the supported formats: \(supportedFormats)."
        case .exceededMaxAttachmentSize:
            return "Failed: exceeded maximum attachment size limit: \(BookAttachment.maximumAttachmentsSize)MB"
        case .exceededMaxAttachmentCount:
            return "Failed: exceeded maximum attachment count limit: \(BookAttachment.maximumAttachmentsCount) attachments"
        case .configNotFound(let error):
            return "Failed to read config file: \(error.localizedDescription)"
        case .parameterValidationFailed:
            return "Failed: validation failed. Please check all parameters."
        case .fileRemovalFailed(let error):
            return "Failed to remove book file: \(error.localizedDescription)"
        }
    }
}
