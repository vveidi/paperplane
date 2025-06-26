//
//  File.swift
//  paperplane
//
//  Created by Vadim on 26.06.2025.
//

import Foundation

struct SendBookAttachmentsHandler {
    
    static func createAttachments(path: URL) throws (SendBookCommandError) -> [BookAttachment] {
        let attachments = try generateFileURLs(for: path).map { (fileURL) throws(SendBookCommandError) in
            return try BookAttachment(fileURL: fileURL)
        }
        guard attachments.count <= BookAttachment.maximumAttachmentsCount else {
            throw .exceededMaxAttachmentCount
        }
        let base64Length = attachments.reduce(into: 0) { partialResult, attachment in
            partialResult += ((attachment.data.count + 2) / 3) * 4
        }
        guard base64Length <= BookAttachment.maximumAttachmentsSize else {
            throw .exceededMaxAttachmentSize
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
