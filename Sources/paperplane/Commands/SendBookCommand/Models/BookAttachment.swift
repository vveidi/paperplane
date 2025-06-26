//
//  BookAttachment.swift
//  paperplane
//
//  Created by Vadim on 20.06.2025.
//

import Foundation
import UniformTypeIdentifiers

struct BookAttachment {
    let title: String
    let data: String
    let mimeType: String
    let fileURL: URL
    
    init(fileURL: URL) throws(SendBookCommandError) {
        guard BookAttachment.supportedFileTypes.contains(fileURL.pathExtension.lowercased()) else {
            throw .unsupportedBookFileFormat
        }
        self.fileURL = fileURL
        self.title = fileURL.lastPathComponent
        self.data = try BookAttachment.parsedData(from: fileURL).base64EncodedString(options: [.lineLength76Characters])
        self.mimeType = BookAttachment.mimeType(for: fileURL.lastPathComponent)
    }
    
    static let supportedFileTypes: Set<String> = [
        "pdf", "doc", "docx", "txt", "rtf", "htm", "html", "png", "gif", "jpg", "jpeg", "bmp", "epub"
    ]
    
    static let maximumAttachmentsSize = 50 * 1024 * 1024
    static let maximumAttachmentsCount = 25
    
    private static func parsedData(from url: URL) throws(SendBookCommandError) -> Data {
        do {
          return try Data(contentsOf: url)
        } catch {
            throw .bookFileReadFailed(error: error)
        }
    }
    
    private static func mimeType(for filename: String) -> String {
        let ext = URL(fileURLWithPath: filename).pathExtension
        if let utType = UTType(filenameExtension: ext),
           let mime = utType.preferredMIMEType {
            return mime
        }
        return "application/octet-stream"
    }
}
