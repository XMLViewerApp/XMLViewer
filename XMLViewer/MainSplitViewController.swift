//
//  ViewController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/6.
//

import AppKit

class MainSplitViewController: NSSplitViewController {
    var currentParser: XMLParser? {
        didSet {
            if let currentParser {
                currentParser.delegate = parserDelegate
                DispatchQueue.global().async {
                    currentParser.parse()
                    // 使用这个函数来遍历树
                    DispatchQueue.main.async {
                        self.parserDelegate.traverseTree()
                    }
                }
            }
        }
    }

    @MainActor
    var currentDocument: XMLDocument? {
        didSet {
            if let currentDocument, let root = currentDocument.rootElement() {
                treeViewController.rootNode = .init(xmlNode: root)
                currentDocument.traverseXMLNode()
            }
        }
    }

    var parserDelegate = XMLParserDelegate()

    var sidebarViewController: SidebarViewController {
        splitViewItems[0].viewController as! SidebarViewController
    }

    var treeViewController: TreeViewController {
        splitViewItems[1].viewController as! TreeViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        sidebarViewController.delegate = self
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

extension MainSplitViewController: SidebarViewControllerDelegate {
    func sidebarViewController(_ controller: SidebarViewController, didSelectXMLFileData data: Data) {
//        currentParser = XMLParser(data: data)
//        currentDocument = try? XMLDocument(data: data)
        Task {
            currentDocument = try await XMLDocument.create(data: data)
        }
    }
}


extension XMLDocument: @unchecked Sendable {}
