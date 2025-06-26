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
    
    @Flag(help: "Verbose mode")
    var verbose: Bool = false
    
    func run() throws(SendBookCommandError) {
        let configuration = try SendBookConfigHandler.create(sender: sender, receiver: receiver, path: path)
        if verbose {
            print("🎯 Current configuration: \(configuration)")
        }
        
        let attachments = try SendBookAttachmentsHandler.createAttachments(path: configuration.fileURL)
        if verbose {
            print("🎯 Attachments files: \(attachments.map(\.title))")
        }
        
        let message = SendBookMessageBuilder.buildMessage(with: attachments, from: configuration.sender, to: configuration.receiver)
        try SendBookMessageSender.send(message, to: configuration.receiver)
        print("✈️ The mail has been sent successfully")
        
        if removeAfterSend {
            try SendBookAttachmentsHandler.removeAttachmentsAfterSend(attachments)
            if verbose {
                print("🎯 Attachments files have been removed")
            }
        }
        
        SendBookConfigHandler.save(configuration)
        if verbose {
            print("🎯 Configuration file has been saved to \(SendBookConfigHandler.configURLPath). New configuration: \(configuration)")
        }
    }
}
