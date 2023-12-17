//
//  TreeViewController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/6.
//

import AppKit
import Combine
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

    @Published
    var rootNode: XMLNodeItem? {
        didSet {
            outlineView.reloadData()
            if XMLViewerDefaults[.Settings.autoExpand] {
                outlineView.expandItem(rootNode, expandChildren: true)
            }
        }
    }

    weak var delegate: OutlineViewControllerDelegate?

    lazy var textFinderController = OutlineTextFinderClient(outlineView: outlineView, initialValue: rootNode, publisher: $rootNode)

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
            $0.menu = NSMenu {
                MenuItem("Copy Name")
                    .onSelect(target: self, action: #selector(copyOutlineNodeNameAction(_:)))
                MenuItem("Copy Value")
                    .onSelect(target: self, action: #selector(copyOutlineNodeValueAction(_:)))
            }.then {
                $0.delegate = self
            }
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

    override var acceptsFirstResponder: Bool { true }

    @objc override func performTextFinderAction(_ sender: Any?) {
        guard let menuItem = sender as? NSMenuItem, let action = NSTextFinder.Action(rawValue: menuItem.tag) else { return }
        textFinderController.textFinder.performAction(action)
    }

    @objc func performFindPanelAction(_ sender: Any?) {
        performTextFinderAction(sender)
    }
}

extension NSOutlineView {
    func itemAtSelectedRow() -> Any? {
        item(atRow: selectedRow)
    }
}

extension OutlineViewController: NSMenuDelegate, NSMenuItemValidation {
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        guard let selectedNodeItem = outlineView.itemAtSelectedRow() as? XMLNodeItem else { return true }
        switch menuItem.action {
        case #selector(copyOutlineNodeNameAction(_:)):
            return selectedNodeItem.hasValidName
        case #selector(copyOutlineNodeValueAction(_:)):
            return selectedNodeItem.hasValidValue
        default:
            return true
        }
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.update()
    }
}

extension OutlineViewController: NSOutlineViewDataSource, NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item as? XMLNodeItem {
            return item.children.count
        }
        return 1
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? XMLNodeItem {
            return item.children[index]
        }
        return rootNode as Any
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
              let tableColumn,
              let tableColumnIdentifer = OutlineViewColumn(rawValue: outlineView.column(withIdentifier: tableColumn.identifier))
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
        let item = outlineView.itemAtSelectedRow() as? XMLNodeItem
        delegate?.outlineViewController(self, didSelectXMLNodeItem: item)
    }
}
