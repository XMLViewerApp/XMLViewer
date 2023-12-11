//
//  OutlineSplitViewController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/11.
//

import AppKit

class OutlineSplitViewController: FocusObservationSplitViewController {
    var activeOutlineViewController: OutlineViewController {
        splitViewItems[activeIndex].viewController as! OutlineViewController
    }
}

