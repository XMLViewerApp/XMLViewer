//
//  TabViewController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/8.
//

import AppKit
import MagicLoading

class ContentViewController: NSTabViewController {
    @MagicViewLoading
    @IBOutlet var outlineSplitViewControllerItem: NSTabViewItem

    @MagicViewLoading
    @IBOutlet var textSplitViewControllerItem: NSTabViewItem
    
    var outlineSplitViewController: OutlineSplitViewController {
        outlineSplitViewControllerItem.viewController as! OutlineSplitViewController
    }

    var textSplitViewController: TextSplitViewController {
        textSplitViewControllerItem.viewController as! TextSplitViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
