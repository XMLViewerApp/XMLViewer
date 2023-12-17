//
//  TextViewController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/8.
//

import AppKit
import SnapKit
import STTextView
import XMLViewerUI

class TextViewController: SplitContainerViewController {
    let scrollView = NSScrollView()

    let textView = STTextView()

    var text: String? {
        didSet {
            if let text {
                textView.string = text
            }
        }
    }

    lazy var rulerView = STLineNumberRulerView(textView: textView, scrollView: scrollView)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        containerView.addSubview(scrollView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        rulerView.do {
            $0.font = .monospacedSystemFont(ofSize: 0, weight: .regular)
            $0.highlightSelectedLine = true
        }
        
        scrollView.do {
            $0.documentView = textView
            $0.hasVerticalScroller = true
            $0.verticalRulerView = rulerView
            $0.rulersVisible = true
        }

        textView.do {
            $0.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
            $0.isEditable = false
            $0.isSelectable = true
            $0.widthTracksTextView = true
            $0.showsInvisibleCharacters = false
            $0.highlightSelectedLine = true
        }
    }
}
