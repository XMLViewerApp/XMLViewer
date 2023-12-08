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
    var data: Data?

    var rootNode: XMLNodeItem?

    let windowController = MainWindowController.create()

    override init() {
        super.init()
    }

    override func makeWindowControllers() {
        addWindowController(windowController)
        windowController.mainSplitViewController.tabViewController.treeViewController.dataSource = self
        windowController.toolbarController.pathToolbarItem?.url = fileURL
    }

    override func read(from data: Data, ofType typeName: String) throws {
        self.data = data
        Task {
            let document = try await XMLDocument.create(data: data)
            await MainActor.run {
                if let rootElement = document.rootElement() {
                    rootNode = XMLNodeItem(rootElement: rootElement)
                    windowController.mainSplitViewController.tabViewController.treeViewController.reloadData()
                }
            }
        }
    }
}
