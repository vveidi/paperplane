//
//  SendBookCommand.swift
//  paperplane
//
//  Created by Vadim on 18.06.2025.
//

import ArgumentParser
import Foundation

// TODO: Remove msmtp dependency

struct SendBookCommand: ParsableCommand {
    
    @Option(name: .shortAndLong, help: "Email address of the sender")
    var sender: String?
    
    @Option(name: .shortAndLong, help: "Email address of the receiver")
    var receiver: String?
    
    @Option(name: .shortAndLong, help: "Path to the book file or the folder")
    var path: String?
    
    @Flag(help: "Remove file or folder after sending")
    var removeAfterSend: Bool = false
    
    func run() throws(SendBookCommandError) {
        let configuration = try SendBookConfigHandler.create(sender: sender, receiver: receiver, path: path)
        let attachments = try SendBookAttachmentsHandler.createAttachments(path: configuration.fileURL)
        let message = SendBookMessageBuilder.buildMessage(with: attachments, from: configuration.sender, to: configuration.receiver)
        
        try SendBookMessageSender.send(message, to: configuration.receiver)
        print("✈️ The mail has been sent successfully")
        
        if removeAfterSend {
            try SendBookAttachmentsHandler.removeAttachmentsAfterSend(attachments)
        }
        SendBookConfigHandler.save(configuration)
    }
}
