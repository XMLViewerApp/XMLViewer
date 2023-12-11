//
//  TreeViewController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/6.
//

import AppKit
import UIFoundation
import MagicLoading

protocol OutlineViewControllerDelegate: AnyObject {
    func outlineViewController(_ treeViewController: OutlineViewController, didSelectXMLNodeItem item: XMLNodeItem?)
}

@IBDesignable
class OutlineViewController: EmbedViewController, StoryboardViewController {
    
    static var storyboard: _NSUIStoryboard { .main }
    
    static var storyboardIdentifier: String { .init(describing: self) }
    
    
    enum TableColumnIdentifer: String {
        case name = "Name"
        case value = "Value"
        case index = "Index"
    }

    @MagicViewLoading
    @IBOutlet var outlineView: NSOutlineView

    var rootNode: XMLNodeItem? {
        didSet {
            outlineView.reloadData()
        }
    }

    weak var delegate: OutlineViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        outlineView.dataSource = self
        outlineView.delegate = self
        outlineView.rowHeight = 25

        outlineView.style = .inset
        outlineView.usesAlternatingRowBackgroundColors = true
    }
}

extension OutlineViewController: NSOutlineViewDataSource, NSOutlineViewDelegate {
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

    /// 为 NSOutlineView 提供显示内容
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let item = item as? XMLNodeItem,
              let tableColumn, let tableColumnIdentifer = TableColumnIdentifer(rawValue: tableColumn.identifier.rawValue)
        else { return nil }
        let cellView: NSTableCellView
        switch tableColumnIdentifer {
        case .name:
            guard let nameCellView = outlineView.makeView(withIdentifier: TreeNodeNameCellView.box.typeNameIdentifier, owner: self) as? TreeNodeNameCellView else { return nil }
            nameCellView.imageView?.image = item.node.kind.ideIcon?.image
            nameCellView.textField?.stringValue = item.node.name ?? "N/A"
            cellView = nameCellView
        case .value:
            guard let valueCellView = outlineView.makeView(withIdentifier: TreeNodeTextCellView.box.typeNameIdentifier, owner: self) as? TreeNodeTextCellView else { return nil }
            valueCellView.textField?.stringValue = item.hasChildren ? "" : item.node.stringValue ?? ""
            cellView = valueCellView
        case .index:
            guard let indexCellView = outlineView.makeView(withIdentifier: TreeNodeTextCellView.box.typeNameIdentifier, owner: self) as? TreeNodeTextCellView else { return nil }
            indexCellView.textField?.stringValue = item.isDisplayIndex ? item.siblingIndex.formatted() : ""
            indexCellView.textField?.alignment = .center
            cellView = indexCellView
        }
        cellView.textField?.font = .monospacedSystemFont(ofSize: 12, weight: .regular)

        return cellView
    }

    func outlineViewSelectionIsChanging(_ notification: Notification) {
        let item = outlineView.item(atRow: outlineView.selectedRow) as? XMLNodeItem
        delegate?.outlineViewController(self, didSelectXMLNodeItem: item)
    }
}
