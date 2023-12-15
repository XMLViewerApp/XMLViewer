//
//  FocusObservationSplitViewController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/11.
//

import AppKit

class FocusObservationSplitViewController: NSSplitViewController {
    var localMonitor: Any?

    public var activeIndex: Int {
        if _activeIndex >= splitViewItems.count {
            _activeIndex = 0
        }
        return _activeIndex
    }

    private var _activeIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown]) { [weak self] theEvent -> NSEvent? in
            guard let self else { return theEvent }
            let eventLocation = theEvent.locationInWindow
            let numberOfSplitViews = splitViewItems.count
            var activeIndex: Int?

            for index in 0 ..< numberOfSplitViews {
                let view = splitViewItems[index].viewController.view
                let locationInView = view.convert(eventLocation, from: nil)
                if locationInView.x > 0, locationInView.x < view.bounds.maxX, locationInView.y > 0, locationInView.y < view.bounds.maxY {
                    activeIndex = index
                    break
                }
            }

            if theEvent.type == .leftMouseDown, let activeIndex {
                self._activeIndex = activeIndex
                mouseDown(with: theEvent)
            }

            return theEvent
        }
        
        print(localMonitor)
    }

    func setEqualWidthSplitViewItems() {
        let numberOfSplitViewItems = splitViewItems.count
        let width = view.frame.width / CGFloat(numberOfSplitViewItems)
        for dividerIndex in 0 ..< (numberOfSplitViewItems - 1) {
            splitView.setPosition(width + (width * CGFloat(dividerIndex)), ofDividerAt: dividerIndex)
        }
    }

    deinit {
        if let localMonitor {
            NSEvent.removeMonitor(localMonitor)
        }
    }
}
