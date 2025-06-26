//
//  SendBookCommand.swift
//  paperplane
//
//  Created by Vadim on 18.06.2025.
//

import ArgumentParser
import Foundation

// TODO: Show errors if VPN is enabled
// TODO: Remove msmtp dependency
// TODO: Add command parameters validation

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
        let configuration = try createConfiguration()
        let attachments = try createAttachments(path: configuration.fileURL)
        let message = buildMessage(with: attachments, from: configuration.sender, to: configuration.receiver)
        try sendMessage(message, to: configuration.receiver)
        print("✈️ The mail has been sent successfully")
        SendBookConfigManager.save(configuration)
        if removeAfterSend {
            try removeAttachmentsAfterSend(attachments)
        }
    }
    
    private func createConfiguration() throws(SendBookCommandError) -> SendBookConfig {
        let configuration = SendBookConfigManager.load()
        guard let sender = sender ?? configuration?.sender,
              let receiver = receiver ?? configuration?.receiver,
              let path = path ?? configuration?.fileURL.path else {
            throw .parameterValidationFailed
        }
        return SendBookConfig(sender: sender, receiver: receiver, path: path)
    }
    
    private func createAttachments(path: URL) throws (SendBookCommandError) -> [BookAttachment] {
        let attachments = try generateFileURLs(for: path).map { (fileURL) throws(SendBookCommandError) in
            return try BookAttachment(fileURL: fileURL)
        }
        guard attachments.count <= BookAttachment.maximumAttachmentsCount else {
            throw .exceededMaxAttachmentCount
        }
        let base64Length = attachments.reduce(into: 0) { partialResult, attachment in
            partialResult += ((attachment.data.count + 2) / 3) * 4
        }
        guard base64Length <= BookAttachment.maximumAttachmentsSize else {
            throw .exceededMaxAttachmentSize
        }
        return attachments
    }
    
    private func generateFileURLs(for path: URL) -> [URL] {
        if path.hasDirectoryPath, let contents = try? FileManager.default.contentsOfDirectory(
            at: path,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) {
            return contents
        } else {
            return [path]
        }
    }
    
    private func buildMessage(with attachments: [BookAttachment], from sender: String, to receiver: String) -> String {
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
    
    private func sendMessage(_ message: String, to receiver: String) throws(SendBookCommandError) {
        guard let messageData = message.data(using: .utf8) else {
            throw .messageEncodingFailed
        }
        let process = Process()
        let inputPipe = Pipe()
        let errorPipe = Pipe()
        process.executableURL = URL(filePath: "/opt/homebrew/bin/msmtp")
        process.arguments = ["--", receiver]
        process.standardInput = inputPipe
        process.standardError = errorPipe
        
        do {
            try process.run()
            try inputPipe.fileHandleForWriting.write(contentsOf: messageData)
            try inputPipe.fileHandleForWriting.close()
        } catch {
            throw .processFailedToStart(error: error)
        }
        process.waitUntilExit()
        
        let stderr = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        
        if process.terminationStatus != 0 || !stderr.isEmpty {
            throw SendBookCommandError.processTerminated(code: Int(process.terminationStatus), description: stderr)
        }
    }
    
    private func removeAttachmentsAfterSend(_ attachments: [BookAttachment]) throws(SendBookCommandError) {
        do {
            try attachments.forEach { attachment in
                try FileManager.default.removeItem(at: attachment.fileURL)
            }
        } catch {
            throw .fileRemovalFailed(error: error)
        }
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
