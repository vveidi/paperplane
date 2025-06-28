//
//  InitSecretsCommand.swift
//  paperplane
//
//  Created by Vadim on 28.06.2025.
//

import ArgumentParser
import Foundation

struct InitSecretsCommand: ParsableCommand {
    
    static var configuration: CommandConfiguration {
        CommandConfiguration(commandName: "init-secrets")
    }
    
    func run() throws {
        print("Enter hostname:")
        let hostname = readLine()
        guard let hostname, !hostname.isEmpty else {
            print("Empty hostname")
            return
        }
        
        print("Enter mail:")
        let mail = readLine()
        guard let mail, !mail.isEmpty else {
            print("Empty mail")
            return
        }
        
        print("Enter password:")
        let password = String(cString: getpass("Введите пароль: "))
        guard !password.isEmpty else {
            print("Empty password")
            return
        }
        
        print("Enter SMTP port:")
        let port = readLine()
        guard let port, !port.isEmpty else {
            print("Empty SMTP port")
            return
        }
        
        let secrets: [String: Any] = [
            "hostname": hostname,
            "mail": mail,
            "password": password,
            "port": port
        ]
        
        let data = try? PropertyListSerialization.data(fromPropertyList: secrets, format: .xml, options: 0)
        FileManager.default.createFile(atPath: "Secrets.plist", contents: data)
    }
}
