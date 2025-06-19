//
//  SendBookCommand.swift
//  paperplane
//
//  Created by Vadim on 18.06.2025.
//

import ArgumentParser
import Foundation
import UniformTypeIdentifiers

struct BookAttachment {
    let title: String
    let data: String
    let mimeType: String
    
    init(title: String, data: Data) {
        // TODO: Escape and encode attachment title (e.g. RFC 2047) if it contains non-ASCII or special characters
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

struct SMTPMessageBuilder {
    private var lines: [String] = []
    
    mutating func add(_ line: String) {
        lines.append(line)
    }

    mutating func addEmptyLine() {
        lines.append("")
    }

    func build() -> String {
        lines.joined(separator: "\r\n")
    }
}

enum SendBookCommandError: LocalizedError {
    case failedToStart(error: Error)
    case invalidData
    case invalidMailAddress
    case terminated(code: Int, description: String)
    
    var errorDescription: String? {
        switch self {
        case .failedToStart(let error):
            "msmtp process failed to start: \(error)"
        case .invalidData:
            "Invalid data for message"
        case .invalidMailAddress:
            "Invalid sender or receiver address"
        case .terminated(let code, let description):
            "msmtp terminated with code \(code): \(description)"
        }
    }
}

struct SendBook: ParsableCommand {
    
    @Option(name: .shortAndLong, help: "Email address of the sender")
    var sender: String
    
    @Option(name: .shortAndLong, help: "Email address of the receiver")
    var receiver: String
    
    @Option(name: .shortAndLong, help: "Path to the book file")
    var file: String
    
    func validate() throws(SendBookCommandError) {
        guard !sender.isEmpty, sender.contains("@"),
              !receiver.isEmpty, receiver.contains("@") else {
            throw .invalidMailAddress
        }
    }
    
    func run() throws(SendBookCommandError) {
        let bookURL = URL(fileURLWithPath: file)
        let bookData = try parsedData(from: bookURL)
        let attachment = BookAttachment(title: bookURL.lastPathComponent, data: bookData)
        let message = buildMessage(with: attachment)
        try sendMessage(message)
    }
    
    private func parsedData(from url: URL) throws(SendBookCommandError) -> Data {
        do {
          return try Data(contentsOf: url)
        } catch {
            throw .invalidData
        }
    }
    
    private func buildMessage(with attachment: BookAttachment) -> String {
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
        
        builder.add("--\(boundary)")
        builder.add("Content-Type: \(attachment.mimeType); name=\"\(attachment.title)\"")
        builder.add("Content-Disposition: attachment; filename=\"\(attachment.title)\"")
        builder.add("Content-Transfer-Encoding: base64")
        builder.addEmptyLine()
        builder.add(attachment.data)
        builder.addEmptyLine()
        
        builder.add("--\(boundary)--")
        
        return builder.build()
    }
    
    private func sendMessage(_ message: String) throws(SendBookCommandError) {
        guard let messageData = message.data(using: .utf8) else {
            throw .invalidData
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
            throw .failedToStart(error: error)
        }
        process.waitUntilExit()
        
        let stderr = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        
        if process.terminationStatus != 0 || !stderr.isEmpty {
            throw SendBookCommandError.terminated(code: Int(process.terminationStatus), description: stderr)
        }
    }
}
