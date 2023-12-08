//
//  MainWindowController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/7.
//

import AppKit
import UIFoundation

class MainWindowController: NSWindowController, StoryboardWindowController {
    static var storyboard: NSStoryboard { .main }
    
    static var storyboardIdentifier: String { .init(describing: self) }
    
    var mainSplitViewController: MainSplitViewController {
        contentViewController as! MainSplitViewController
    }
    
    let toolbarController = ToolbarController()
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.animationBehavior = .documentWindow
        window?.center()
        window?.toolbar = toolbarController.toolbar
    }
}


extension NSStoryboard {
    static let main = NSStoryboard(name: "Main", bundle: .main)
}
