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
    
    init(title: String, data: Data) {
        self.title = title
        self.data = data.base64EncodedString(options: [.lineLength76Characters])
        self.mimeType = BookAttachment.mimeType(for: title)
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
