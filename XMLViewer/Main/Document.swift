//
//  Document.swift
//  XMLViewer
//
//  Created by JH on 2023/12/7.
//

import AppKit
import UIFoundation
import ZIPFoundation
import UniformTypeIdentifiers

enum DocumentError: Error {
    case unsupportedFileType
}

class Document: NSDocument {
    override class var readableTypes: [String] {
        ([UTType.xml] + [UTType.OpenXML.wordprocessing, UTType.OpenXML.spreadsheet, UTType.OpenXML.presentation].compactMap { $0 }).map(\.identifier)
    }

    var data: Data?

    let windowController = MainWindowController()

    let store = XMLDocumentItemStore()

    override init() {
        super.init()
    }

    override func makeWindowControllers() {
        addWindowController(windowController)
        if let fileURL {
            windowController.window?.setFrameAutosaveName(fileURL.path)
        }
    }

    override func read(from url: URL, ofType typeName: String) throws {
        let data = try Data(contentsOf: url)
        self.data = data

        DispatchQueue.global().async {
            do {
                switch UTType(typeName) {
                case .xml?:
                    let documentItem = try XMLDocumentItem(name: url.lastPathComponent, data: data)
                    self.store.addItem(documentItem)
                case .OpenXML.wordprocessing,
                     .OpenXML.spreadsheet,
                     .OpenXML.presentation:
                    let archive = try Archive(data: data, accessMode: .read, pathEncoding: nil)
                    for entry in archive {
                        var entryData = Data()
                        _ = try archive.extract(entry) { data in
                            entryData += data
                        }
                        guard let documentItem = try? XMLDocumentItem(name: (entry.path as NSString).lastPathComponent, data: entryData) else { continue }
                        self.store.addItem(documentItem)
                    }
                default:
                    throw DocumentError.unsupportedFileType
                }

                DispatchQueue.main.async {
                    self.windowController.splitViewController.documentItems = self.store.items
                }
            } catch {
                DispatchQueue.main.async {
                    // Presents error(s) and close the document window.
                    self.presentError(error)
                    self.close()
                }
            }
        }
    }

    override class var autosavesDrafts: Bool { false }

    override var isDocumentEdited: Bool { false }
}

extension UTType {
    enum OpenXML {
        static let spreadsheet = UTType("org.openxmlformats.spreadsheetml.sheet")
        static let wordprocessing = UTType("org.openxmlformats.wordprocessingml.document")
        static let presentation = UTType("org.openxmlformats.presentationml.presentation")
    }
}
