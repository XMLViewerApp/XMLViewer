//
//  InspectorViewController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/9.
//

import AppKit
import XMLViewerUI

class InspectorViewController: VisualEffectScrollViewController<NSTableView> {
    enum TableColumnIdentifer: String, CaseIterable {
        case title = "Title"
        case detail = "Detail"
        var identifier: NSUserInterfaceItemIdentifier {
            .init(rawValue: rawValue)
        }
    }

    enum Row: Int, CaseIterable {
        case kind = 0
        case name
        case stringValue
        case index
        case level
        case childCount
        case xPath
        case localName
        case prefix
        case uri

        var title: String {
            switch self {
            case .kind:
                "Kind"
            case .name:
                "Name"
            case .stringValue:
                "Value"
            case .index:
                "Index"
            case .level:
                "Level"
            case .childCount:
                "Child count"
            case .xPath:
                "X Path"
            case .localName:
                "Local name"
            case .prefix:
                "Prefix"
            case .uri:
                "URI"
            }
        }

        func detail(for node: XMLNode) -> String {
            switch self {
            case .kind:
                node.kind.description
            case .name:
                node.name.unwrapOrDefaultValue
            case .stringValue:
                node.stringValue.unwrapOrDefaultValue
            case .index:
                node.index.formatted()
            case .level:
                node.level.formatted()
            case .childCount:
                node.childCount.formatted()
            case .xPath:
                node.xPath.unwrapOrDefaultValue
            case .localName:
                node.localName.unwrapOrDefaultValue
            case .prefix:
                node.prefix.unwrapOrDefaultValue
            case .uri:
                node.uri.unwrapOrDefaultValue
            }
        }
    }

    var xmlNode: XMLNode? {
        didSet {
            contentView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.do {
            $0.drawsBackground = false
            $0.backgroundColor = .clear
        }
        
        contentView.do {
            $0.headerView = nil
            $0.dataSource = self
            $0.delegate = self
            $0.backgroundColor = .clear
        }
        
        TableColumnIdentifer.allCases.forEach { column in
            contentView.addTableColumn(NSTableColumn(identifier: column.identifier))
        }
    }
}

extension InspectorViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        Row.allCases.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn,
              let tableColumnIdentifier = TableColumnIdentifer(rawValue: tableColumn.identifier.rawValue),
              let row = Row(rawValue: row)
        else { return nil }

        switch tableColumnIdentifier {
        case .title:
            let cellView = tableView.box.makeView(ofClass: InspectorTitleCellView.self, owner: self)
            cellView.textField?.stringValue = row.title
            cellView.textField?.font = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .semibold)
            return cellView
        case .detail:
            let cellView = tableView.box.makeView(ofClass: InspectorDetailCellView.self, owner: self)
            cellView.textField?.stringValue = xmlNode.map { row.detail(for: $0) }.unwrapOrDefaultValue
            cellView.textField?.font = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
            return cellView
        }
    }
}

extension String? {
    var unwrapOrDefaultValue: String {
        self ?? "N/A"
    }
}
