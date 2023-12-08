//
//  ViewController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/6.
//

import AppKit

class MainSplitViewController: NSSplitViewController {

    var sidebarViewController: SidebarViewController {
        splitViewItems[0].viewController as! SidebarViewController
    }

    var tabViewController: TabViewController {
        splitViewItems[1].viewController as! TabViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}


