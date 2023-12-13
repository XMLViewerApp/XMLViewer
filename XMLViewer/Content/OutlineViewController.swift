//
//  TreeViewController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/6.
//

import AppKit
import SnapKit
import KeyCodes
import XMLViewerUI
import MenuBuilder

protocol OutlineViewControllerDelegate: AnyObject {
    func outlineViewController(_ treeViewController: OutlineViewController, didSelectXMLNodeItem item: XMLNodeItem?)
}

enum OutlineViewColumn: Int, CaseIterable {
    case name = 0
    case index
    case value

    var identifier: NSUserInterfaceItemIdentifier {
        return .init(rawValue: "\(Self.self).\(rawValue)")
    }

    var title: String {
        switch self {
        case .name:
            "Name"
        case .index:
            "Index"
        case .value:
            "Value"
        }
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

class OutlineViewController: SplitContainerViewController {
    let (scrollView, outlineView) = OutlineView.scrollableOutlineView()

    let treeController = NSTreeController()

    var rootNode: XMLNodeItem? {
        set {
            treeController.content = newValue

            outlineView.reloadData()
        }
        get {
            treeController.content as? XMLNodeItem
        }
    }

    weak var delegate: OutlineViewControllerDelegate?

    lazy var textFinderController = OutlineTextFinderClient(outlineView: outlineView, treeController: treeController)

    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.addSubview(scrollView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        treeController.do {
            $0.objectClass = XMLNodeItem.self
            $0.childrenKeyPath = XMLNodeItem.keyPathString(\.children)
            $0.leafKeyPath = XMLNodeItem.keyPathString(\.isLeaf)
            $0.countKeyPath = XMLNodeItem.keyPathString(\.childrenCount)
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
            $0.menu = NSMenu {
                MenuItem("Copy Name")
                    .onSelect(target: self, action: #selector(copyOutlineNodeNameAction(_:)))
                MenuItem("Copy Value")
                    .onSelect(target: self, action: #selector(copyOutlineNodeValueAction(_:)))
            }.then {
                $0.delegate = self
                $0.autoenablesItems = false
            }
            $0.bind(.content, to: treeController, keyPath: \.arrangedObjects)
            $0.bind(.selectionIndexPaths, to: treeController, keyPath: \.selectionIndexPaths)
        }

        OutlineViewColumn.allCases.forEach { column in
            let tableColumn = NSTableColumn(identifier: column.identifier)
            tableColumn.title = column.title
            tableColumn.width = column.width
            tableColumn.minWidth = column.minWidth
            outlineView.addTableColumn(tableColumn)
        }
    }

    @objc func copyOutlineNodeNameAction(_ sender: NSMenuItem) {
        guard let item = outlineView.item(atRow: outlineView.selectedRow) as? XMLNodeItem, let name = item.node.name else { return }
        NSPasteboard.general.do {
            $0.clearContents()
            $0.setString(name, forType: .string)
        }
    }

    @objc func copyOutlineNodeValueAction(_ sender: NSMenuItem) {
        guard let item = outlineView.item(atRow: outlineView.selectedRow) as? XMLNodeItem, let value = item.node.stringValue else { return }
        NSPasteboard.general.do {
            $0.clearContents()
            $0.setString(value, forType: .string)
        }
    }

    @IBAction override func performTextFinderAction(_ sender: Any?) {
        textFinderController.textFinder.performAction(.showFindInterface)
    }
    
    
}

extension OutlineViewController: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        guard let nodeItem = outlineView.item(atRow: outlineView.selectedRow) as? XMLNodeItem else { return }
        menu.items.forEach { item in
            switch item.action {
            case #selector(copyOutlineNodeNameAction(_:)):
                item.isEnabled = nodeItem.hasValidName
            case #selector(copyOutlineNodeValueAction(_:)):
                item.isEnabled = nodeItem.hasValidValue
            default:
                break
            }
        }
    }
}

extension OutlineViewController: NSTextFinderClient {}

extension OutlineViewController: NSOutlineViewDataSource, NSOutlineViewDelegate {
//    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
//        if let item = item as? XMLNodeItem {
//            return item.children.count
//        }
//        return rootNode?.children.count ?? 0 // rootNode 是 XML 文档的根节点
//    }
//
//    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
//        if let item = item as? XMLNodeItem {
//            return item.children[index]
//        }
//        return rootNode?.children[index] as Any
//    }
//
//    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
//        if let item = item as? XMLNodeItem {
//            return !item.children.isEmpty
//        }
//        return false
//    }

    /// 为 NSOutlineView 提供显示内容
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let item = nodeItem(for: item),
              let tableColumn, let tableColumnIdentifer = OutlineViewColumn(rawValue: outlineView.column(withIdentifier: tableColumn.identifier))
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

    func nodeItem(for item: Any) -> XMLNodeItem? {
        guard let treeNode = item as? NSTreeNode, let nodeItem = treeNode.representedObject as? XMLNodeItem else { return nil }
        return nodeItem
    }
}
