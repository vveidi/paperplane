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
    
    init(fileURL: URL, data: Data) throws(SendBookCommandError) {
        guard BookAttachment.allowedExtensions.contains(fileURL.pathExtension.lowercased()) else {
            throw .unsupportedBookFileFormat
        }
        self.title = fileURL.lastPathComponent
        self.data = data.base64EncodedString(options: [.lineLength76Characters])
        self.mimeType = BookAttachment.mimeType(for: fileURL.lastPathComponent)
    }
    
    static let allowedExtensions: Set<String> = [
        "mobi", "azw", "azw3", "epub", "pdf", "txt", "rtf", "doc", "docx", "html", "htm"
    ]
    
    private static func mimeType(for filename: String) -> String {
        let ext = URL(fileURLWithPath: filename).pathExtension
        if let utType = UTType(filenameExtension: ext),
           let mime = utType.preferredMIMEType {
            return mime
        }
        return "application/octet-stream"
    }
}
