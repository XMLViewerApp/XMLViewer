//
//  ViewController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/6.
//

import AppKit

class SplitViewController: NSSplitViewController {
    var sidebarViewController: SidebarViewController {
        splitViewItems[0].viewController as! SidebarViewController
    }

    var contentViewController: ContentViewController {
        splitViewItems[1].viewController as! ContentViewController
    }

    var inspectorViewController: InspectorViewController {
        splitViewItems[2].viewController as! InspectorViewController
    }
    
    var documentItems: [XMLDocumentItem] = [] {
        didSet {
            sidebarViewController.items = documentItems.map(\.name)
            contentViewController.treeViewController.rootNode = documentItems.first?.rootNode
            contentViewController.textViewController.text = documentItems.first?.text
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sidebarViewController.delegate = self
        contentViewController.treeViewController.delegate = self

        splitViewItems[0].do {
            $0.minimumThickness = 200
            $0.maximumThickness = 500
        }

        splitViewItems[2].do {
            $0.minimumThickness = 269
            $0.maximumThickness = 500
        }
    }

    @objc func _toggleInspector(_ sender: Any?) {
        guard let inspectorItem = splitViewItems.filter({ $0.behavior == .inspector }).first else { return }
        inspectorItem.animator().isCollapsed = !inspectorItem.isCollapsed
    }
    
}

extension SplitViewController: TreeViewControllerDelegate {
    func treeViewController(_ treeViewController: TreeViewController, didSelectXMLNodeItem item: XMLNodeItem?) {
        inspectorViewController.xmlNode = item?.node
    }
}

extension SplitViewController: SidebarViewControllerDelegate {
    func sidebarViewController(_ controller: SidebarViewController, didSelectRow row: Int) {
        guard row >= 0, row < documentItems.count else { return }
        let documentItem = documentItems[row]
        contentViewController.treeViewController.rootNode = documentItem.rootNode
        contentViewController.textViewController.text = documentItem.text
        
    }
}
