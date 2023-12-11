//
//  TextSplitViewController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/11.
//

import AppKit

class TextSplitViewController: FocusObservationSplitViewController {
    var activeTextViewController: TextViewController {
        splitViewItems[activeIndex].viewController as! TextViewController
    }
}
