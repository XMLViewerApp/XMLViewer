//
//  Document.swift
//  XMLViewer
//
//  Created by JH on 2023/12/7.
//

import AppKit
import XMLViewerUI
import ZIPFoundation
import UniformTypeIdentifiers

enum DocumentError: Error {
    case unsupportedFileType
}

class Document: NSDocument {
    override class var readableTypes: [String] {
        ([UTType.xml] + [UTType.OpenXML.wordprocessing, UTType.OpenXML.spreadsheet, UTType.OpenXML.presentation].compactMap { $0 }).map(\.identifier)
    }

    lazy var windowController = MainWindowController()

    let store = XMLDocumentItemStore()

    let concurrentQueue = DispatchQueue(label: "com.JH.XMLViewer.Document.concurrentQueue", attributes: .concurrent)

    let group = DispatchGroup()

    var archive: Archive?

    override init() {
        super.init()
    }

    override func makeWindowControllers() {
        windowController.delegate = self
        addWindowController(windowController)
        if let fileURL {
            windowController.window?.setFrameAutosaveName(fileURL.path)
        }
    }

    func loadData(from url: URL, ofType typeName: String) {
        concurrentQueue.async(group: group) {
            do {
                let data = try Data(contentsOf: url)
                switch UTType(typeName) {
                case .xml?:
                    let documentItem = try XMLDocumentItem(path: .fileSystem(url), data: data)
                    self.store.addItem(documentItem)
                case .OpenXML.wordprocessing,
                     .OpenXML.spreadsheet,
                     .OpenXML.presentation:
                    let archive = try Archive(data: data, accessMode: .read, pathEncoding: nil)
                    for entry in archive {
                        do {
                            var entryData = Data()
                            _ = try archive.extract(entry) { data in
                                entryData += data
                            }
                            let documentItem = try XMLDocumentItem(path: .archiveEntry(entry.path), data: entryData)
                            self.store.addItem(documentItem)
                        } catch {
                            Swift.print(error, entry.path)
                        }
                    }
                default:
                    throw DocumentError.unsupportedFileType
                }
            } catch {
                DispatchQueue.main.async {
                    self.presentError(error)
                    self.close()
                }
            }
        }
        group.notify(queue: .main) {
            self.windowController.splitViewController.documentItems = self.store.items
        }
    }

    func exportFile(for xmlDocumentItem: XMLDocumentItem) {}

    override func read(from url: URL, ofType typeName: String) throws {
        loadData(from: url, ofType: typeName)
    }

    override class var autosavesDrafts: Bool { false }

    override var isDocumentEdited: Bool { false }
}

extension Document: MainWindowControllerDelegate {
    func mainWindowControllerRequestReloadDocumentData(_ controller: MainWindowController) {
        if let fileURL, let fileType {
            store.clearItems()
            loadData(from: fileURL, ofType: fileType)
        }
    }
}

extension UTType {
    enum OpenXML {
        static let spreadsheet = UTType("org.openxmlformats.spreadsheetml.sheet")
        static let wordprocessing = UTType("org.openxmlformats.wordprocessingml.document")
        static let presentation = UTType("org.openxmlformats.presentationml.presentation")
    }
}
