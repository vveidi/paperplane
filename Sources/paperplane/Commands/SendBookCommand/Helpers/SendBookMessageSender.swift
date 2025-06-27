//
//  File.swift
//  paperplane
//
//  Created by Vadim on 26.06.2025.
//

import Foundation
import SwiftSMTP

struct SendBookMessageSender {
    
    static func send(configuration: SendBookConfig, attachments: [BookAttachment], completion: @escaping ((Error)?) -> Void) {
        let sender = Mail.User(email: configuration.sender)
        let receiver = Mail.User(email: configuration.receiver)
        let attachments = attachments.map({ Attachment(filePath: $0.fileURL.absoluteString) })
        let mail = Mail(
            from: sender,
            to: [receiver],
            text: "This mail was sent via Swift",
            attachments: attachments
        )
        guard let dict = NSDictionary(contentsOfFile: "Sources/paperplane/Secrets.plist"),
              let hostname = dict["hostname"] as? String,
              let email = dict["email"] as? String,
              let password = dict["password"] as? String,
              let port = dict["port"] as? Int32 else {
            completion(SendBookCommandError.failedToParseSecretsFile)
            return
        }
        let smtp = SMTP(
            hostname: hostname,
            email: email,
            password: password,
            port: port
        )
        smtp.send(mail, completion: completion)
    }
}
