//
//  TreeViewController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/6.
//

import AppKit
import XMLViewerUI

protocol OutlineViewControllerDelegate: AnyObject {
    func outlineViewController(_ treeViewController: OutlineViewController, didSelectXMLNodeItem item: XMLNodeItem?)
}

class OutlineViewController: SplitContainerViewController {
    enum TableColumnIdentifer: String, CaseIterable {
        case name = "Name"
        case index = "Index"
        case value = "Value"
        var identifier: NSUserInterfaceItemIdentifier {
            return .init(rawValue: rawValue)
        }
        
        var width: CGFloat {
            switch self {
            case .name:
                174
            case .index:
                46
            case .value:
                200
            }
        }
        
        var minWidth: CGFloat {
            switch self {
            case .name:
                174
            case .index:
                46
            case .value:
                200
            }
        }
    }

    let (scrollView, outlineView) = OutlineView.scrollableOutlineView()
    
    
    var rootNode: XMLNodeItem? {
        didSet {
            
            outlineView.reloadData()
        }
    }

    weak var delegate: OutlineViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        containerView.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.do {
            $0.hasHorizontalScroller = true
            $0.hasVerticalScroller = true
        }
        
        outlineView.then {
            $0.dataSource = self
            $0.delegate = self
            $0.rowHeight = 25
            $0.style = .inset
            $0.usesAlternatingRowBackgroundColors = true
        }
        
        TableColumnIdentifer.allCases.forEach { column in
            let tableColumn = NSTableColumn(identifier: column.identifier)
            tableColumn.title = column.rawValue
            tableColumn.width = column.width
            tableColumn.minWidth = column.minWidth
            outlineView.addTableColumn(tableColumn)
        }
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
            let nameCellView = outlineView.box.makeView(withType: OutlineNodeNameCellView.self, onwer: self)
            nameCellView.imageView?.image = item.node.kind.ideIcon?.image
            nameCellView.textField?.stringValue = item.node.name ?? "N/A"
            cellView = nameCellView
        case .value:
            let valueCellView = outlineView.box.makeView(withType: OutlineNodeTextCellView.self, onwer: self)
            valueCellView.textField?.stringValue = item.hasChildren ? "" : item.node.stringValue ?? ""
            cellView = valueCellView
        case .index:
            let indexCellView = outlineView.box.makeView(withType: OutlineNodeTextCellView.self, onwer: self)
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
