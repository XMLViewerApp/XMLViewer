//
//  ViewController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/6.
//

import AppKit
import UIFoundation

class MainSplitViewController: NSSplitViewController {
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
            contentViewController.outlineSplitViewController.activeOutlineViewController.rootNode = documentItems.first?.rootNode
            contentViewController.textSplitViewController.activeTextViewController.text = documentItems.first?.text
        }
    }

    override var acceptsFirstResponder: Bool { true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sidebarViewController.delegate = self
        contentViewController.outlineSplitViewController.activeOutlineViewController.delegate = self

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

    override func flagsChanged(with event: NSEvent) {
        print(String(describing: Self.self), event.modifierFlags.contains(.option))
        super.flagsChanged(with: event)
    }
}

extension MainSplitViewController: OutlineViewControllerDelegate {
    func outlineViewController(_ treeViewController: OutlineViewController, didSelectXMLNodeItem item: XMLNodeItem?) {
        inspectorViewController.xmlNode = item?.node
    }
}

extension MainSplitViewController: SidebarViewControllerDelegate {
    func sidebarViewController(_ controller: SidebarViewController, didSelectRow row: Int) {
        guard row >= 0, row < documentItems.count else { return }
        let documentItem = documentItems[row]
        contentViewController.outlineSplitViewController.activeOutlineViewController.rootNode = documentItem.rootNode
        contentViewController.textSplitViewController.activeTextViewController.text = documentItem.text
    }
    
    func sidebarViewController(_ controller: SidebarViewController, didPressOptionKeySelectRow row: Int) {
        guard let viewMode = XMLViewMode(rawValue: contentViewController.selectedTabViewItemIndex) else { return }
        let documentItem = documentItems[row]
        switch viewMode {
        case .outline:
            let outlineViewController = OutlineViewController.create()
            outlineViewController.rootNode = documentItem.rootNode
            contentViewController.outlineSplitViewController.addSplitViewItem(NSSplitViewItem(viewController: outlineViewController))
            contentViewController.outlineSplitViewController.setEqualWidthSplitViewItems()
        case .text:
            let textViewController = TextViewController.create()
            textViewController.text = documentItem.text
            contentViewController.textSplitViewController.addSplitViewItem(NSSplitViewItem(viewController: textViewController))
            contentViewController.textSplitViewController.setEqualWidthSplitViewItems()
        }
        
    }
}
