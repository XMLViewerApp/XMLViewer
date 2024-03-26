//
//  InspectorCellView.swift
//  XMLViewer
//
//  Created by JH on 2023/12/9.
//

import AppKit
import XMLViewerUI

class InspectorTitleCellView: TextTableCellView {}

class InspectorDetailCellView: TextTableCellView {
    override func setup() {
        super.setup()
        _textField.lineBreakMode = .byTruncatingTail
        _textField.allowsExpansionToolTips = true
    }
}
