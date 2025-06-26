//
//  File.swift
//  paperplane
//
//  Created by Vadim on 26.06.2025.
//

import Foundation

struct SendBookMessageSender {
    
    static func send(_ message: String, to receiver: String) throws(SendBookCommandError) {
        let tempFile = try createTempFile(for: message)
        defer {
            try? FileManager.default.removeItem(at: tempFile)
        }
        guard let fileHandle = try? FileHandle(forReadingFrom: tempFile) else {
            throw .messageEncodingFailed
        }
        let process = Process()
        let errorPipe = Pipe()
        process.executableURL = URL(filePath: "/opt/homebrew/bin/msmtp")
        process.arguments = ["--", receiver]
        process.standardInput = fileHandle
        process.standardError = errorPipe
        
        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            throw .processFailedToStart(error: error)
        }
        
        let stderr = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        
        if process.terminationStatus != 0 || !stderr.isEmpty {
            throw SendBookCommandError.processTerminated(code: Int(process.terminationStatus), description: stderr)
        }
    }

    private static func createTempFile(for message: String) throws(SendBookCommandError) -> URL {
        guard let tempDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            throw .messageEncodingFailed
        }
        let tempFile = tempDir.appending(path: UUID().uuidString + ".eml")
        do {
            try message.write(to: tempFile, atomically: true, encoding: .utf8)
        } catch {
            throw .messageEncodingFailed
        }
        return tempFile
    }
}
