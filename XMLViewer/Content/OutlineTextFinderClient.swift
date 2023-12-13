//
//  TextFinderController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/13.
//

import AppKit

class OutlineTextFinderClient: NSObject, NSTextFinderClient {
    unowned let outlineView: NSOutlineView

    unowned let treeController: NSTreeController

    let textFinder = NSTextFinder()

    let indexStore = OutlineTextIndexStore()

    var contentObservation: NSKeyValueObservation?

    init(outlineView: NSOutlineView, treeController: NSTreeController) {
        self.outlineView = outlineView
        self.treeController = treeController
        super.init()
        if let content = treeController.content as? [XMLNodeItem], let rootNode = content.first {
            indexStore.rootNode = rootNode
        }
        textFinder.client = self
        textFinder.findBarContainer = outlineView.enclosingScrollView

        self.contentObservation = treeController.observe(\.content) { [weak self] _, value in
            guard let self else { return }
            if let content = value.newValue as? [XMLNodeItem], let rootNode = content.first {
                indexStore.rootNode = rootNode
            }
        }
    }

    var allowsMultipleSelection: Bool { false }

    var isEditable: Bool { false }

    var isSelectable: Bool { false }

    func string(at characterIndex: Int, effectiveRange outRange: NSRangePointer, endsWithSearchBoundary outFlag: UnsafeMutablePointer<ObjCBool>) -> String {
        let token = indexStore[characterIndex]
        outRange.pointee.location = token.index
        outRange.pointee.length = token.string.utf16.count
        outFlag.pointee = true
        return token.string
    }

    func stringLength() -> Int {
        indexStore.currentStringCount
    }

    func scrollRangeToVisible(_ range: NSRange) {
        let token = indexStore[range.location]
        outlineView.scrollRowToVisible(token.row)
    }

    func contentView(at index: Int, effectiveCharacterRange outRange: NSRangePointer) -> NSView {
        let token = indexStore.tokens[index]

        outRange.pointee.location = token.index
        outRange.pointee.length = token.string.utf16.count

        if let cellView = outlineView.view(atColumn: token.column.rawValue, row: token.row, makeIfNecessary: false) as? NSTableCellView, let textField = cellView.textField {
            return textField
        } else {
            return .init()
        }
    }
}
