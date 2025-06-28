//
//  File.swift
//  paperplane
//
//  Created by Vadim on 28.06.2025.
//

struct SMTPConfig: Codable {
    
    static let path = Path.settingsDirectory.appending(path: "smtp_config.json")
    
    let hostname: String
    let mail: String
    let password: String
    let port: Int32
}
