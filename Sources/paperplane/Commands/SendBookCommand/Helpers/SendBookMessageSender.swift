//
//  File.swift
//  paperplane
//
//  Created by Vadim on 26.06.2025.
//

import Foundation
import SwiftSMTP

struct SendBookMessageSender {
    
    static func send(
        configuration: SendBookConfig,
        attachments: [BookAttachment],
        completion: @escaping ((Error)?) -> Void
    ) {
        let sender = Mail.User(email: configuration.sender)
        let receiver = Mail.User(email: configuration.receiver)
        let attachments = attachments.map({ Attachment(filePath: $0.fileURL.path()) })
        let mail = Mail(
            from: sender,
            to: [receiver],
            text: "This mail was sent via Swift",
            attachments: attachments
        )
        do {
            let data = try Data(contentsOf: SMTPConfig.path)
            let config = try JSONDecoder().decode(SMTPConfig.self, from: data)
            let smtp = SMTP(
                hostname: config.hostname,
                email: config.mail,
                password: config.password,
                port: config.port
            )
            smtp.send(mail, completion: completion)
        } catch {
            completion(SendBookCommandError.failedToParseSMTPConfigFile)
        }
    }
}
