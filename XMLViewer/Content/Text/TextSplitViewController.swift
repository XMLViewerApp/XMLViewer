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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        addSplitViewItem(NSSplitViewItem(viewController: TextViewController()))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
