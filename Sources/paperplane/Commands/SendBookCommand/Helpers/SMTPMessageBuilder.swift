//
//  SMTPMessageBuilder.swift
//  paperplane
//
//  Created by Vadim on 20.06.2025.
//

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
