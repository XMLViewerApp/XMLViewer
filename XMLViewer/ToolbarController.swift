//
//  ToolbarController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/7.
//

import AppKit

protocol ToolbarControllerDelegate: AnyObject {
    
}

class ToolbarController: NSObject, NSToolbarDelegate {
    
    
    enum ToolbarItem: String, CaseIterable {
        case export
        case sidebar
        case format
        
        var identifier: NSToolbarItem.Identifier {
            return .init(rawValue: rawValue)
        }
    }
    
    public let toolbar = NSToolbar()
    
    public weak var delegate: ToolbarControllerDelegate?
    
    private var toolbarItems: [NSToolbarItem.Identifier: NSToolbarItem] = [:]
    
    override init() {
        super.init()
        makeToolbarItems()
    }
    
    private func makeToolbarItems() {
        ToolbarItem.allCases.forEach { item in
            let toolbarItem = NSToolbarItem(itemIdentifier: item.identifier)
            switch item {
            case .export:
                break
            case .format:
                break
            case .sidebar:
                break
            }
            toolbarItems[item.identifier] = toolbarItem
        }
    }
    
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        toolbarItems[itemIdentifier]
    }
}
