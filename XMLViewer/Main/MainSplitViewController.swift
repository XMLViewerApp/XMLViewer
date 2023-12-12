//
//  ViewController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/6.
//

import AppKit
import XMLViewerUI

class MainSplitViewController: NSSplitViewController {
    let sidebarViewController = SidebarViewController()

    let contentViewController = ContentViewController()

    let inspectorViewController = InspectorViewController()

    var documentItems: [XMLDocumentItem] = [] {
        didSet {
            sidebarViewController.items = documentItems.map(\.name)
            guard let documentItem = documentItems.first else { return }
            setDataForDocumentItem(documentItem)
        }
    }

    override var acceptsFirstResponder: Bool { true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sidebarViewController.delegate = self
        contentViewController.outlineSplitViewController.activeOutlineViewController.delegate = self

        addSplitViewItem(NSSplitViewItem(sidebarWithViewController: sidebarViewController))
        addSplitViewItem(NSSplitViewItem(contentListWithViewController: contentViewController))
        addSplitViewItem(NSSplitViewItem(inspectorWithViewController: inspectorViewController))
        
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

extension MainSplitViewController: OutlineViewControllerDelegate {
    func outlineViewController(_ treeViewController: OutlineViewController, didSelectXMLNodeItem item: XMLNodeItem?) {
        inspectorViewController.xmlNode = item?.node
    }
}

extension MainSplitViewController: SidebarViewControllerDelegate {
    func sidebarViewController(_ controller: SidebarViewController, didSelectRow row: Int) {
        guard row >= 0, row < documentItems.count else { return }
        let documentItem = documentItems[row]
        setDataForDocumentItem(documentItem)
    }
    
    func setDataForDocumentItem(_ documentItem: XMLDocumentItem) {
        contentViewController.outlineSplitViewController.activeOutlineViewController.rootNode = documentItem.rootNode
        contentViewController.outlineSplitViewController.activeOutlineViewController.bottomBarView.filePath = documentItem.path
        contentViewController.textSplitViewController.activeTextViewController.text = documentItem.text
        contentViewController.textSplitViewController.activeTextViewController.bottomBarView.filePath = documentItem.path
    }
    
    func sidebarViewController(_ controller: SidebarViewController, didPressOptionKeySelectRow row: Int) {
        guard let viewMode = XMLViewMode(rawValue: contentViewController.selectedTabViewItemIndex) else { return }
        let documentItem = documentItems[row]
        let containerViewController: SplitContainerViewController
        switch viewMode {
        case .outline:
            let outlineViewController = OutlineViewController()
            outlineViewController.rootNode = documentItem.rootNode
            contentViewController.outlineSplitViewController.addSplitViewItem(NSSplitViewItem(viewController: outlineViewController))
            contentViewController.outlineSplitViewController.setEqualWidthSplitViewItems()
            containerViewController = outlineViewController
        case .text:
            let textViewController = TextViewController()
            textViewController.text = documentItem.text
            contentViewController.textSplitViewController.addSplitViewItem(NSSplitViewItem(viewController: textViewController))
            contentViewController.textSplitViewController.setEqualWidthSplitViewItems()
            containerViewController = textViewController
        }
        containerViewController.bottomBarView.filePath = documentItem.path
        
    }
}
