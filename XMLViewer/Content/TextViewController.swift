//
//  TextViewController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/8.
//

import AppKit
import XMLViewerUI

class TextViewController: SplitContainerViewController {
    let scrollView = NSScrollView()

    let textView = NSTextView()

    var text: String? {
        didSet {
            if let text {
                textView.string = text
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        containerView.addSubview(scrollView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        scrollView.do {
            $0.documentView = textView
            $0.hasVerticalScroller = true
        }

        textView.do {
            $0.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
            $0.isEditable = false
            $0.isSelectable = true
        }
    }
}
