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
    let fileURL: URL
    
    init(fileURL: URL) throws(SendBookCommandError) {
        guard BookAttachment.supportedFileTypes.contains(fileURL.pathExtension.lowercased()) else {
            throw .unsupportedBookFileFormat
        }
        self.fileURL = fileURL
        self.title = fileURL.lastPathComponent
    }
    
    static let supportedFileTypes: Set<String> = [
        "pdf", "doc", "docx", "txt", "rtf", "htm", "html", "png", "gif", "jpg", "jpeg", "bmp", "epub"
    ]
    
    static let maximumAttachmentsSize = 50 * 1024 * 1024
    static let maximumAttachmentsCount = 25
}
