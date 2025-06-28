//
//  SendBookCommand.swift
//  paperplane
//
//  Created by Vadim on 18.06.2025.
//

import ArgumentParser
import Dispatch
import Foundation

struct SendBookCommand: ParsableCommand {
    
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "send-book",
            abstract: "Send a book file or folder as an email attachment.",
            discussion: """
            Options and flags:
              -s, --sender <sender>          Email address of the sender
              -r, --receiver <receiver>      Email address of the receiver
              -p, --path <path>              Path to the book file or the folder
                  --remove-after-send        Remove file or folder after sending
                  --verbose                  Verbose mode (detailed output)
                  --debug                    Debug mode (simulate sending, does NOT send real emails)
                  --config                   Show current configuration

            Examples:
              send-book -s you@email.com -r kindle@kindle.com -p /path/to/book.epub
              send-book --sender=me@mail.com --receiver=kindle@kindle.com --path=/book.mobi --remove-after-send
              send-book --config
            """
        )
    }
    
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
    
    @Flag(help: "Debug mode")
    var debug: Bool = false
    
    @Flag(help: "Show configuration")
    var config: Bool = false
    
    func run() throws(SendBookCommandError) {
        if config {
            if sender != nil || receiver != nil || path != nil || removeAfterSend || verbose || debug {
                print("Configuration options are not available in config mode")
            }
            try showConfig()
        } else {
            try sendBook()
        }
    }
    
    private func showConfig() throws(SendBookCommandError) {
        guard let data = try? Data(contentsOf: SendBookConfig.path),
              let jsonData = try? JSONSerialization.jsonObject(with: data),
              let jsonDataPrettyPrinted = try? JSONSerialization.data(
                withJSONObject: jsonData,
                options: [.prettyPrinted, .withoutEscapingSlashes]
              ),
              let config = String(data: jsonDataPrettyPrinted, encoding: .utf8)
        else {
            throw .failedToParseSendBookConfigFile
        }
        print(config)
    }
    
    private func sendBook() throws(SendBookCommandError) {
        let userInput = SendBookUserInput(sender: sender, receiver: receiver, path: path)
        let oldConfiguration = SendBookConfigHandler.load()
        if verbose, let oldConfiguration {
            print("🎯 Configuration loaded: \(oldConfiguration)")
        }
        
        let configuration = try SendBookConfigHandler.merge(configuration: oldConfiguration, userInput: userInput)
        if verbose {
            print("🎯 Configuration merged with user input: \(configuration)")
        }
        
        let attachments = try SendBookAttachmentsHandler.createAttachments(path: configuration.fileURL)
        if verbose {
            print("🎯 Attachments files: \(attachments.map(\.fileURL))")
        }
        
        if !debug {
            let semaphore = DispatchSemaphore(value: 0)
            var sendError: Error?
            
            SendBookMessageSender.send(configuration: configuration, attachments: attachments) { error in
                sendError = error
                semaphore.signal()
            }
            semaphore.wait()
            
            if let sendError {
                throw .failedToSendEmail(error: sendError)
            } else {
                print("🛫 The mail has been sent successfully")
            }
        } else {
            print("🛫 Debug mode is on. The mail would have been sent")
        }
        
        if removeAfterSend {
            try SendBookAttachmentsHandler.removeAttachmentsAfterSend(attachments)
            if verbose {
                print("🎯 Attachments files have been removed")
            }
        }
        
        try SendBookConfigHandler.save(configuration)
        if verbose {
            if oldConfiguration == configuration {
                print("🎯 No changes in the configuration. Skipped configuration file saving")
            } else {
                print("🎯 Configuration file has been saved to \(SendBookConfig.path). New configuration: \(configuration)")
            }
        }
    }
}
