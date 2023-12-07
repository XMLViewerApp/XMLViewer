//
//  Document.swift
//  XMLViewer
//
//  Created by JH on 2023/12/7.
//

import AppKit
import UIFoundation

@objc(XMLViewerDocument)
class XMLViewerDocument: NSDocument, TreeViewControllerDataSource {
    var xmlData: Data?
    
    var rootNode: XMLNodeItem? {
        didSet {
            windowController.mainSplitViewController.treeViewController.reloadData()
        }
    }
    
    let windowController = MainWindowController.create()

    override init() {
        super.init()
    }

//    override class var autosavesInPlace: Bool {
//        return true
//    }

    override func makeWindowControllers() {
        addWindowController(windowController)
        windowController.mainSplitViewController.treeViewController.dataSource = self
    }

    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override read(from:ofType:) instead.
        // If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
        xmlData = data
        Task {
            let document = try await XMLDocument.create(data: data)
            await MainActor.run {
                if let rootElement = document.rootElement() {
                    rootNode = XMLNodeItem(xmlNode: rootElement)
                }
            }
        }
    }
}
