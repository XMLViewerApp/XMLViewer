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
        makeToolbarItems()
    }

    private func makeToolbarItems() {
        guard let delegate else { return }
        toolbarItems = [
            .sidebar: SidebarToolbarItem(itemIdentifier: .sidebar),
            .inspector: InspectorToolbarItem(itemIdentifier: .inspector),
            .path: PathToolbarItem(itemIdentifier: .path),
            .viewMode: XMLViewModeToolbarItem(itemIdentifier: .viewMode).then {
                $0.didSelectMode = { [weak self] viewMode in
                    guard let self else { return }
                    delegate.toolbarController(self, didSelectViewMode: viewMode)
                }
            },
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
        return [.sidebar, .sidebarTrackingSeparator, .viewMode, ._inspectorTrackingSeparator, .flexibleSpace, .inspector]
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
}

class SidebarToolbarItem: NSToolbarItem {
    override init(itemIdentifier: NSToolbarItem.Identifier) {
        super.init(itemIdentifier: itemIdentifier)
        action = #selector(NSSplitViewController.toggleSidebar(_:))
        image = SFSymbol(systemName: .sidebarLeft).nsImage
    }
}

class InspectorToolbarItem: NSToolbarItem {
    override init(itemIdentifier: NSToolbarItem.Identifier) {
        super.init(itemIdentifier: itemIdentifier)
        action = #selector(MainSplitViewController._toggleInspector(_:))
        image = SFSymbol(systemName: .sidebarRight).nsImage
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
