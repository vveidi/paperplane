//
//  File.swift
//  paperplane
//
//  Created by Vadim on 26.06.2025.
//

import Foundation

struct SendBookMessageBuilder {
    
    static func buildMessage(with attachments: [BookAttachment], from sender: String, to receiver: String) -> String {
        var builder = SMTPMessageBuilder()
        let boundary = UUID().uuidString
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "E, dd MMM yyyy HH:mm:ss Z"
        
        builder.add("From: \(sender)")
        builder.add("To: \(receiver)")
        builder.add("Date: \(dateFormatter.string(from: Date()))")
        builder.add("MIME-Version: 1.0")
        builder.add("Content-Type: multipart/mixed; boundary=\"\(boundary)\"")
        builder.addEmptyLine()
        
        builder.add("--\(boundary)")
        builder.add("Content-Type: text/plain; charset=UTF-8")
        builder.add("Content-Transfer-Encoding: 7bit")
        builder.addEmptyLine()
        builder.add("This email was sent via Swift.")
        builder.addEmptyLine()
        
        attachments.forEach { attachment in
            builder.add("--\(boundary)")
            builder.add("Content-Type: \(attachment.mimeType); name=\"\(attachment.title.rfc2047Encoded())\"")
            builder.add("Content-Disposition: attachment; filename=\"\(attachment.title.rfc2047Encoded())\"")
            builder.add("Content-Transfer-Encoding: base64")
            builder.addEmptyLine()
            builder.add(attachment.data)
            builder.addEmptyLine()
        }
        
        builder.add("--\(boundary)--")
        
        return builder.build()
    }
}

private extension String {
    func rfc2047Encoded() -> String {
        if canBeConverted(to: .ascii) {
            return self
        }
        guard let utf8Data = data(using: .utf8) else {
            return self
        }
        let base64EncodedString = utf8Data.base64EncodedString()
        return "=?UTF-8?B?\(base64EncodedString)?="
    }
}
