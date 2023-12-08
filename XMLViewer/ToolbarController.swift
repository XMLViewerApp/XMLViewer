//
//  ToolbarController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/7.
//

import AppKit
import SFSymbol

protocol ToolbarControllerDelegate: AnyObject {}

class ToolbarController: NSObject, NSToolbarDelegate {
    public let toolbar = NSToolbar()

    public weak var delegate: ToolbarControllerDelegate?

    private var toolbarItems: [NSToolbarItem.Identifier: NSToolbarItem] = [:]
    
    var pathToolbarItem: PathToolbarItem? {
        toolbarItems[.path] as? PathToolbarItem
    }
    
    override init() {
        super.init()
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly
        makeToolbarItems()
    }

    private func makeToolbarItems() {
        toolbarItems = [
            .export: NSToolbarItem(itemIdentifier: .export),
            .format: NSToolbarItem(itemIdentifier: .format),
            .sidebar: SidebarToolbarItem(itemIdentifier: .sidebar),
            .path: PathToolbarItem(itemIdentifier: .path),
        ]
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        toolbarItems[itemIdentifier]
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarItems.keys.map { $0 }
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.sidebar, .sidebarTrackingSeparator, .export, .format, .path]
    }
}

extension NSToolbarItem.Identifier {
    static let export = NSToolbarItem.Identifier("export")
    static let sidebar = NSToolbarItem.Identifier("sidebar")
    static let format = NSToolbarItem.Identifier("format")
    static let path = NSToolbarItem.Identifier("path")
}

class SidebarToolbarItem: NSToolbarItem {
    override init(itemIdentifier: NSToolbarItem.Identifier) {
        super.init(itemIdentifier: itemIdentifier)
        action = #selector(NSSplitViewController.toggleSidebar(_:))
        image = SFSymbol(systemName: .sidebarLeft).nsImage
    }
}

class PathToolbarItem: NSToolbarItem {
    let pathControl = NSPathControl()

    var url: URL? {
        didSet {
            pathControl.url = url
        }
    }

    override init(itemIdentifier: NSToolbarItem.Identifier) {
        super.init(itemIdentifier: itemIdentifier)
        view = pathControl
        target = self
        action = #selector(action(_:))
        pathControl.isEditable = false
        
    }

    @objc func action(_ toolbarItem: NSToolbarItem) {}
}
