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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        addSplitViewItem(NSSplitViewItem(viewController: OutlineViewController()))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func addSplitViewItem(_ splitViewItem: NSSplitViewItem) {
        super.addSplitViewItem(splitViewItem)
        
        showOrHideTopBar()

        guard let splitContainerViewController = splitViewItem.viewController as? SplitContainerViewController else { return }
        splitContainerViewController.topBarView.didClickCloseButton = { [weak self, weak splitViewItem] in
            guard let self, let splitViewItem else { return }
            removeSplitViewItem(splitViewItem)
        }
    }
    
    override func removeSplitViewItem(_ splitViewItem: NSSplitViewItem) {
        super.removeSplitViewItem(splitViewItem)
        showOrHideTopBar()
    }
    
    override func insertSplitViewItem(_ splitViewItem: NSSplitViewItem, at index: Int) {
        super.insertSplitViewItem(splitViewItem, at: index)
        showOrHideTopBar()
    }

    func showOrHideTopBar() {
        let numberOfSplitViewItems = splitViewItems.count
        splitViewItems.forEach { item in
            let outlineViewController = item.viewController as! OutlineViewController
            outlineViewController.showTopBar = numberOfSplitViewItems > 1
        }
    }
}
