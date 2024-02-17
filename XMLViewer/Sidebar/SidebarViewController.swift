//
//  SidebarViewController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/6.
//

import AppKit
import UniformTypeIdentifiers
import SFSymbol
import XMLViewerUI

protocol SidebarViewControllerDelegate: AnyObject {
    func sidebarViewController(_ controller: SidebarViewController, didSelectRow row: Int)
    func sidebarViewController(_ controller: SidebarViewController, didPressOptionKeySelectRow row: Int)
}

class SidebarViewController: VisualEffectScrollViewController<SingleColumnTableView> {
    weak var delegate: SidebarViewControllerDelegate?

    var items: [String] = [] {
        didSet {
            contentView.reloadData()
        }
    }
    
    var isPressOptionKey: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.do {
            $0.drawsBackground = false
            $0.backgroundColor = .clear
//            $0.autohidesScrollers = true
            $0.hasVerticalScroller = true
            $0.verticalScroller?.alphaValue = 0
        }
        
        contentView.do {
            $0.backgroundColor = .clear
            $0.dataSource = self
            $0.delegate = self
            $0.rowHeight = 30
        }
        
        view.addTrackingArea(NSTrackingArea(rect: .zero, options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect], owner: self, userInfo: nil))
    }
    
    override func flagsChanged(with event: NSEvent) {
        isPressOptionKey = event.modifierFlags.contains(.option)
    }
    
    override func mouseEntered(with event: NSEvent) {
        scrollView.verticalScroller?.alphaValue = 1
    }
    
    override func mouseExited(with event: NSEvent) {
        scrollView.verticalScroller?.alphaValue = 0
    }
}

extension SidebarViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        items.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView = tableView.box.makeView(withType: SidebarCellView.self, onwer: self)
        let item = items[row]
        cellView.imageView?.image = SFSymbol(systemName: .chevronLeftForwardslashChevronRight).nsImage
        cellView.textField?.stringValue = item
        return cellView
    }
    
    func tableViewSelectionIsChanging(_ notification: Notification) {
        delegate?.sidebarViewController(self, didSelectRow: contentView.selectedRow)
        if isPressOptionKey {
            delegate?.sidebarViewController(self, didPressOptionKeySelectRow: contentView.selectedRow)
        }
    }
}
