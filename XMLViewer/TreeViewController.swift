//
//  TreeViewController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/6.
//

import AppKit

class TreeViewController: NSViewController {
    enum TableColumnIdentifer: String {
        case name = "Name"
        case value = "Value"
    }

    @IBOutlet var outlineView: NSOutlineView!

    var rootNode: XMLNodeItem? {
        didSet {
            outlineView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        outlineView.dataSource = self
        outlineView.delegate = self
        outlineView.rowHeight = 30
        outlineView.style = .inset
        outlineView.usesAlternatingRowBackgroundColors = true
    }
}

extension TreeViewController: NSOutlineViewDataSource, NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item as? XMLNodeItem {
            return item.children.count
        }
        return rootNode?.children.count ?? 0 // rootNode 是 XML 文档的根节点
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? XMLNodeItem {
            return item.children[index]
        }
        return rootNode?.children[index] as Any
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let item = item as? XMLNodeItem {
            return !item.children.isEmpty
        }
        return false
    }

    // 为 NSOutlineView 提供显示内容
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Cell"), owner: self) as? NSTableCellView,
              let item = item as? XMLNodeItem,
              let tableColumn, let tableColumnIdentifer = TableColumnIdentifer(rawValue: tableColumn.identifier.rawValue)
        else { return nil }
        switch tableColumnIdentifer {
        case .name:
            cell.textField?.stringValue = item.xmlNode.name ?? "N/A"
        case .value:
            cell.textField?.stringValue = item.xmlNode.stringValue ?? "N/A"
        }

        return cell
    }
}
