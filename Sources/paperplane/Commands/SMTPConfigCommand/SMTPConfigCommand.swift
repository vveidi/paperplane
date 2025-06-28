//
//  SMTPConfigCommand.swift
//  paperplane
//
//  Created by Vadim on 28.06.2025.
//

import ArgumentParser
import Foundation

struct SMTPConfigCommand: ParsableCommand {
    
    static var configuration: CommandConfiguration {
        CommandConfiguration(commandName: "config")
    }
    
    @Flag(help: "Create configuration file")
    var `init`: Bool = false
    
    func run() throws(SMTPConfigCommandError) {
        if `init` {
            try createSMTPConfigFile()
        }
    }
    
    private func createSMTPConfigFile() throws(SMTPConfigCommandError) {
        print("Enter hostname:")
        let hostname = readLine()
        guard let hostname, !hostname.isEmpty else {
            throw .invalidSMTPConfigParameter("hostname")
        }
        
        print("Enter mail:")
        let mail = readLine()
        guard let mail, !mail.isEmpty else {
            throw .invalidSMTPConfigParameter("mail")
        }
        
        print("Enter password:")
        let password = String(cString: getpass("Введите пароль: "))
        guard !password.isEmpty else {
            throw .invalidSMTPConfigParameter("password")
        }
        
        print("Enter SMTP port:")
        let rawPort = readLine()
        guard let rawPort, !rawPort.isEmpty, let port = Int32(rawPort) else {
            throw .invalidSMTPConfigParameter("SMTP port")
        }
        
        let config = SMTPConfig(hostname: hostname, mail: mail, password: password, port: port)
        
        do {
            if !FileManager.default.fileExists(atPath: Path.settingsDirectory.path()) {
                try FileManager.default.createDirectory(at: Path.settingsDirectory, withIntermediateDirectories: true)
            }
            let data = try JSONEncoder().encode(config)
            try data.write(to: SMTPConfig.path)
        } catch {
            throw .failedToCreateConfig(error: error)
        }
    }
}
