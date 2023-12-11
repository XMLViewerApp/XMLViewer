//
//  SidebarViewController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/6.
//

import AppKit
import UniformTypeIdentifiers
import MagicLoading
import SFSymbol

protocol SidebarViewControllerDelegate: AnyObject {
    func sidebarViewController(_ controller: SidebarViewController, didSelectRow row: Int)
    func sidebarViewController(_ controller: SidebarViewController, didPressOptionKeySelectRow row: Int)
}

class SidebarViewController: NSViewController {
    weak var delegate: SidebarViewControllerDelegate?

    var items: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var isPressOptionKey: Bool = false
    
    @MagicViewLoading
    @IBOutlet var tableView: NSTableView

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.do {
            $0.backgroundColor = .clear
            $0.dataSource = self
            $0.delegate = self
            $0.rowHeight = 30
        }
    }
    override func flagsChanged(with event: NSEvent) {
        isPressOptionKey = event.modifierFlags.contains(.option)
        super.flagsChanged(with: event)
    }
}

extension SidebarViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        items.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cellView = tableView.makeView(withIdentifier: SidebarCellView.box.typeNameIdentifier, owner: self) as? SidebarCellView else { return nil }
        let item = items[row]
        cellView.imageView?.image = SFSymbol(systemName: .chevronLeftForwardslashChevronRight).nsImage
        cellView.textField?.stringValue = item
        return cellView
    }
    
    func tableViewSelectionIsChanging(_ notification: Notification) {
        delegate?.sidebarViewController(self, didSelectRow: tableView.selectedRow)
        if isPressOptionKey {
            delegate?.sidebarViewController(self, didPressOptionKeySelectRow: tableView.selectedRow)
        }
    }
}
