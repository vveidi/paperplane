//
//  Path.swift
//  paperplane
//
//  Created by Vadim on 28.06.2025.
//

import Foundation

enum Path {
    static let settingsDirectory = FileManager.default.homeDirectoryForCurrentUser.appending(path: ".paperplane")
}
