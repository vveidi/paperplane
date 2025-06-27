//
//  File.swift
//  paperplane
//
//  Created by Vadim on 26.06.2025.
//

import Foundation

struct SendBookAttachmentsHandler {
    
    static func createAttachments(path: URL) throws (SendBookCommandError) -> [BookAttachment] {
        let attachments = generateFileURLs(for: path).compactMap { fileURL in
            return try? BookAttachment(fileURL: fileURL)
        }
        guard !attachments.isEmpty else {
            throw .failedToCreateAttachments
        }
        return attachments
    }
    
    static func removeAttachmentsAfterSend(_ attachments: [BookAttachment]) throws(SendBookCommandError) {
        do {
            try attachments.forEach { attachment in
                try FileManager.default.removeItem(at: attachment.fileURL)
            }
        } catch {
            throw .fileRemovalFailed(error: error)
        }
    }
    
    private static func generateFileURLs(for path: URL) -> [URL] {
        if path.hasDirectoryPath, let contents = try? FileManager.default.contentsOfDirectory(
            at: path,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) {
            return contents
        } else {
            return [path]
        }
    }
}
