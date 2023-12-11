//
//  TextViewController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/8.
//

import AppKit
import UIFoundation
import MagicLoading

@IBDesignable
class TextViewController: EmbedViewController, StoryboardViewController {
    
    static var storyboard: _NSUIStoryboard { .main }
    
    static var storyboardIdentifier: String { .init(describing: self) }
    
    @MagicViewLoading
    @IBOutlet var textView: NSTextView

    var text: String? {
        didSet {
            if let text {
                textView.string = text
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        textView.do {
            $0.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
            $0.isEditable = false
            $0.isSelectable = true
        }
    }
}
