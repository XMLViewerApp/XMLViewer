//
//  MainWindowController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/7.
//

import AppKit
import XMLViewerUI

protocol MainWindowControllerDelegate: AnyObject {
    func mainWindowControllerRequestReloadDocumentData(_ controller: MainWindowController)
}

class MainWindowController: NSWindowController {

    weak var delegate: MainWindowControllerDelegate?
    
    override var windowNibName: NSNib.Name? { "" }
    
    lazy var splitViewController = MainSplitViewController()

    lazy var contentWindow = NSWindow(contentRect: .zero, styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView], backing: .buffered, defer: false)

    lazy var toolbarController = ToolbarController(delegate: self)

    override func loadWindow() {
        window = contentWindow
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        contentViewController = splitViewController
        contentWindow.animationBehavior = .documentWindow
        contentWindow.center()
        contentWindow.toolbar = toolbarController.toolbar
    }
    
    @IBAction override func performTextFinderAction(_ sender: Any?) {
        guard let viewMode = XMLViewMode(rawValue: splitViewController.contentViewController.selectedTabViewItemIndex) else { return }
        switch viewMode {
        case .outline:
            splitViewController.contentViewController.outlineSplitViewController.activeOutlineViewController.performTextFinderAction(sender)
        case .text:
//            splitViewController.contentViewController.textSplitViewController.activeTextViewController.performTextFinderAction(sender)
            break
        }
    }
    
    @IBAction func reloadDocument(_ sender: Any?) {
        delegate?.mainWindowControllerRequestReloadDocumentData(self)
    }
}

extension MainWindowController: ToolbarControllerDelegate {
    var splitView: NSSplitView {
        splitViewController.splitView
    }

    func toolbarController(_ toolbarController: ToolbarController, didSelectViewMode viewMode: XMLViewMode) {
        splitViewController.contentViewController.selectedTabViewItemIndex = viewMode.rawValue
    }
    
    func toolbarControllerDidClickReload(_ toolbarController: ToolbarController) {
        delegate?.mainWindowControllerRequestReloadDocumentData(self)
    }
}
