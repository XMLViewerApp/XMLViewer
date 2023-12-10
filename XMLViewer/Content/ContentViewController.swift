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
    @IBOutlet var treeViewControllerItem: NSTabViewItem

    @MagicViewLoading
    @IBOutlet var textViewControllerItem: NSTabViewItem
    
    var treeViewController: TreeViewController {
        treeViewControllerItem.viewController as! TreeViewController
    }

    var textViewController: TextViewController {
        textViewControllerItem.viewController as! TextViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
