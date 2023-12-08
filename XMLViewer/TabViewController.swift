//
//  TabViewController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/8.
//

import AppKit

class TabViewController: NSTabViewController {
    @IBOutlet weak var treeViewControllerTabViewItem: NSTabViewItem!
    
    var treeViewController: TreeViewController {
        treeViewControllerTabViewItem.viewController as! TreeViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabStyle = .segmentedControlOnTop
    }
}
