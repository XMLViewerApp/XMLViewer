//
//  SidebarCellView.swift
//  XMLViewer
//
//  Created by JH on 2023/12/8.
//

import AppKit
import XMLViewerUI

class SidebarCellView: ImageTextTableCellView {
    
    
    override func setup() {
        super.setup()
        
        _textField.lineBreakMode = .byTruncatingTail
        _textField.allowsExpansionToolTips = true
    }
}
