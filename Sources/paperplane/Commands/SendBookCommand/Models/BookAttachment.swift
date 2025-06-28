//
//  BookAttachment.swift
//  paperplane
//
//  Created by Vadim on 20.06.2025.
//

import Foundation
import PDFKit
import UniformTypeIdentifiers
import ZIPFoundation

struct BookAttachment {
    let title: String
    let fileURL: URL
    
    init(fileURL: URL) throws(SendBookCommandError) {
        guard BookAttachment.supportedFileTypes.contains(fileURL.pathExtension.lowercased()) else {
            throw .unsupportedBookFileFormat
        }
        let title = BookAttachment.extractTitle(from: fileURL)
        
        self.fileURL = fileURL
        self.title = title?.appending(".\(fileURL.pathExtension.lowercased())") ?? fileURL.lastPathComponent
    }
    
    static let supportedFileTypes: Set<String> = [
        "pdf", "doc", "docx", "txt", "rtf", "htm", "html", "png", "gif", "jpg", "jpeg", "bmp", "epub"
    ]
    
    private static func extractTitle(from fileURL: URL) -> String? {
        switch fileURL.pathExtension.lowercased() {
        case "pdf":
            return extractPDFTitle(from: fileURL)
        case "epub":
            return extractEpubTitle(from: fileURL)
        default:
            return nil
        }
    }
    
    private static func extractEpubTitle(from fileURL: URL) -> String? {
        do {
            let archive = try Archive(url: fileURL, accessMode: .read, pathEncoding: nil)
            guard let containerEntry = archive["META-INF/container.xml"] else {
                return nil
            }
            
            var containerData = Data()
            do {
                _ = try archive.extract(containerEntry, consumer: { containerData.append($0) })
            } catch {
                return nil
            }
            
            guard let containerXML = String(data: containerData, encoding: .utf8) else {
                return nil
            }
            let rootFilePath: String
            do {
                let xmlDoc = try XMLDocument(xmlString: containerXML, options: [])
                let nodes = try xmlDoc.nodes(forXPath: "//rootfile")
                guard let firstRootFilePath = nodes.compactMap({ ($0 as? XMLElement)?.attribute(forName: "full-path")?.stringValue }).first else {
                    return nil
                }
                rootFilePath = firstRootFilePath
            } catch {
                return nil
            }
            
            guard let opfEntry = archive[rootFilePath] else {
                return nil
            }
            var opfData = Data()
            do {
                _ = try archive.extract(opfEntry, consumer: { opfData.append($0) })
            } catch {
                return nil
            }
            
            guard let opfXML = String(data: opfData, encoding: .utf8) else {
                return nil
            }
            do {
                let xmlDoc = try XMLDocument(xmlString: opfXML, options: [])

                let strictTitleCandidates = try xmlDoc.nodes(forXPath: "//*[local-name()='title' and namespace-uri()='http://purl.org/dc/elements/1.1/']")
                let strictTitles = strictTitleCandidates.compactMap { ($0 as? XMLElement)?.stringValue }
                if let strictTitle = strictTitles.first(where: { !$0.isEmpty }) {
                    return strictTitle
                }
                let relaxedTitleCandidates = try xmlDoc.nodes(forXPath: "//*[local-name()='title']")
                let relaxedTitles = relaxedTitleCandidates.compactMap { ($0 as? XMLElement)?.stringValue }
                return relaxedTitles.first(where: { !$0.isEmpty })
            } catch {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    private static func extractPDFTitle(from fileURL: URL) -> String? {
        guard let document = PDFDocument(url: fileURL),
              let title = document.documentAttributes?[PDFDocumentAttribute.titleAttribute] as? String,
              !title.isEmpty else {
            return nil
        }
        return title
    }
}
