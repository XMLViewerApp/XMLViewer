//
//  TabViewController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/8.
//

import AppKit

class ContentViewController: NSTabViewController {
    
    let outlineSplitViewController = OutlineSplitViewController()

    let textSplitViewController = TextSplitViewController()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTabViewItem(NSTabViewItem(viewController: outlineSplitViewController))
        addTabViewItem(NSTabViewItem(viewController: textSplitViewController))
    }
    
    
}
