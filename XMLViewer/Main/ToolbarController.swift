//
//  ToolbarController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/7.
//

import AppKit
import SFSymbol

protocol ToolbarControllerDelegate: AnyObject {
    var splitView: NSSplitView { get }

    func toolbarController(_ toolbarController: ToolbarController, didSelectViewMode: XMLViewMode)
    func toolbarControllerDidClickReload(_ toolbarController: ToolbarController)
}

class ToolbarController: NSObject, NSToolbarDelegate {
    public let toolbar = NSToolbar()

    public weak var delegate: ToolbarControllerDelegate?

    private var toolbarItems: [NSToolbarItem.Identifier: NSToolbarItem] = [:]

    var pathToolbarItem: PathToolbarItem? {
        toolbarItems[.path] as? PathToolbarItem
    }

    init(delegate: ToolbarControllerDelegate) {
        super.init()
        self.delegate = delegate
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly
        toolbar.showsBaselineSeparator = false
        
        makeToolbarItems()
    }

    private func makeToolbarItems() {
        guard let delegate else { return }
        toolbarItems = [
            .sidebar: SidebarToolbarItem(itemIdentifier: .sidebar),
            .inspector: InspectorToolbarItem(itemIdentifier: .inspector),
            .path: PathToolbarItem(itemIdentifier: .path),
            .reload: NSToolbarItem(itemIdentifier: .reload).then {
                $0.image = SFSymbol(systemName: .arrowClockwise).scale(.large).nsImage
                $0.isBordered = true
                $0.toolTip = "Reload Document"
                $0.actionBlock = { [weak self] _ in
                    guard let self else { return }
                    delegate.toolbarControllerDidClickReload(self)
                }
            },
//            .viewMode: XMLViewModeToolbarItem(itemIdentifier: .viewMode).then {
//                $0.didSelectMode = { [weak self] viewMode in
//                    guard let self else { return }
//                    delegate.toolbarController(self, didSelectViewMode: viewMode)
//                }
//            },
            ._inspectorTrackingSeparator: NSTrackingSeparatorToolbarItem(identifier: ._inspectorTrackingSeparator, splitView: delegate.splitView, dividerIndex: 1),
        ]
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        toolbarItems[itemIdentifier]
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarItems.keys.map { $0 }
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .sidebar,
            .sidebarTrackingSeparator,
            .reload,
            ._inspectorTrackingSeparator,
            .flexibleSpace,
            .inspector,
        ]
    }
}

extension NSToolbarItem.Identifier {
    static let export = NSToolbarItem.Identifier("export")
    static let sidebar = NSToolbarItem.Identifier("sidebar")
    static let format = NSToolbarItem.Identifier("format")
    static let path = NSToolbarItem.Identifier("path")
    static let inspector = NSToolbarItem.Identifier("inspector")
    static let _inspectorTrackingSeparator = NSToolbarItem.Identifier("_inspectorTrackingSeparator")
    static let viewMode = NSToolbarItem.Identifier("viewMode")
    static let reload = NSToolbarItem.Identifier("reload")
}

class SidebarToolbarItem: NSToolbarItem {
    override init(itemIdentifier: NSToolbarItem.Identifier) {
        super.init(itemIdentifier: itemIdentifier)
        label = "Navigator Sidebar"
        paletteLabel = " Navigator Sidebar"
        toolTip = "Hide or show the Navigator"
        action = #selector(NSSplitViewController.toggleSidebar(_:))
        image = SFSymbol(systemName: .sidebarLeft).scale(.large).nsImage
        isBordered = true
    }
}

class InspectorToolbarItem: NSToolbarItem {
    override init(itemIdentifier: NSToolbarItem.Identifier) {
        super.init(itemIdentifier: itemIdentifier)
        label = "Inspector Sidebar"
        paletteLabel = "Inspector Sidebar"
        toolTip = "Hide or show the Inspectors"
        isBordered = true
        action = #selector(MainSplitViewController._toggleInspector(_:))
        image = SFSymbol(systemName: .sidebarRight).scale(.large).nsImage
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
        self.action = #selector(action(_:))
        pathControl.isEditable = false
    }

    @objc func action(_ toolbarItem: NSToolbarItem) {}
}

class XMLViewModeToolbarItem: NSToolbarItem {
    let segmentedControl = NSSegmentedControl()

    var didSelectMode: (XMLViewMode) -> Void = { _ in }

    override init(itemIdentifier: NSToolbarItem.Identifier) {
        super.init(itemIdentifier: itemIdentifier)
        view = segmentedControl
        segmentedControl.target = self
        segmentedControl.action = #selector(segmentedControlAction(_:))
        segmentedControl.segmentCount = XMLViewMode.allCases.count
        XMLViewMode.allCases.forEach { mode in
            segmentedControl.setLabel(mode.label, forSegment: mode.rawValue)
            segmentedControl.setImage(mode.image, forSegment: mode.rawValue)
            segmentedControl.setWidth(80, forSegment: mode.rawValue)
        }
        segmentedControl.setSelected(true, forSegment: 0)
    }

    @objc func segmentedControlAction(_ segmentedControl: NSSegmentedControl) {
        didSelectMode(XMLViewMode.allCases[segmentedControl.selectedSegment])
    }
}
