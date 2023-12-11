//
//  MainWindowController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/7.
//

import AppKit
import UIFoundation

class WindowController: NSWindowController, StoryboardWindowController {
    static var storyboard: NSStoryboard { .main }

    static var storyboardIdentifier: String { .init(describing: self) }

    var splitViewController: MainSplitViewController {
        contentViewController as! MainSplitViewController
    }

    lazy var toolbarController = ToolbarController(delegate: self)

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.animationBehavior = .documentWindow
        window?.center()
        window?.toolbar = toolbarController.toolbar
    }
}

extension WindowController: ToolbarControllerDelegate {
    var splitView: NSSplitView {
        splitViewController.splitView
    }

    func toolbarController(_ toolbarController: ToolbarController, didSelectViewMode viewMode: XMLViewMode) {
        splitViewController.contentViewController.selectedTabViewItemIndex = viewMode.rawValue
    }
}
