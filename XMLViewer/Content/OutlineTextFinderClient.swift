//
//  TextFinderController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/13.
//

import AppKit

protocol OutlineTextFinderClientDataSource: AnyObject {
    var rootNode: XMLNodeItem? { get }
}

class OutlineTextFinderClient: NSObject, NSTextFinderClient {
    unowned let outlineView: NSOutlineView

    unowned let dataSource: OutlineTextFinderClientDataSource

    let textFinder = NSTextFinder()

    let indexStore = OutlineTextIndexStore()

    var contentObservation: NSKeyValueObservation?

    init(outlineView: NSOutlineView, dataSource: OutlineTextFinderClientDataSource) {
        self.outlineView = outlineView
        self.dataSource = dataSource
        super.init()
        indexStore.rootNode = dataSource.rootNode
        textFinder.client = self
        textFinder.findBarContainer = outlineView.enclosingScrollView
    }

    var allowsMultipleSelection: Bool { false }

    var isEditable: Bool { false }

    var isSelectable: Bool { false }

    var currentSelectedLocation: Int = 0

    func string(at characterIndex: Int, effectiveRange outRange: NSRangePointer, endsWithSearchBoundary outFlag: UnsafeMutablePointer<ObjCBool>) -> String {
        let token = indexStore[characterIndex]
        let range = NSRange(location: token.index, length: token.string.utf16.count)
        outRange.pointee = range
        outFlag.pointee = true
        currentSelectedLocation = NSMaxRange(range)
        return token.string
    }

    func stringLength() -> Int {
        indexStore.currentStringCount
    }

    func scrollRangeToVisible(_ range: NSRange) {
        let token = indexStore[range.location]
        outlineView.scrollRowToVisible(token.row)
    }

    var firstSelectedRange: NSRange {
        return .init(location: currentSelectedLocation, length: 0)
    }

    func contentView(at index: Int, effectiveCharacterRange outRange: NSRangePointer) -> NSView {
        let token = indexStore[index]

        var parent: Any? = outlineView.parent(forItem: token.nodeItem) ?? dataSource.rootNode
        while let parentItem = parent as? XMLNodeItem, outlineView.isExpandable(parentItem), !outlineView.isItemExpanded(parentItem) {
            outlineView.expandItem(parentItem)
            parent = outlineView.parent(forItem: parentItem)
        }

        outRange.pointee.location = token.index
        outRange.pointee.length = token.string.utf16.count

        return textField(at: token) ?? .init()
    }

    func textField(at token: OutlineTextIndexStore.Token) -> NSTextField? {
        if let cellView = outlineView.view(atColumn: token.column.rawValue, row: token.row, makeIfNecessary: false) as? NSTableCellView, let textField = cellView.textField {
            return textField
        } else {
            return nil
        }
    }

    func rects(forCharacterRange range: NSRange) -> [NSValue]? {
//        currentSelectedLocation = NSMaxRange(range)
        let token = indexStore[range.location]
        let location = range.location - token.index
        let length = range.length
        let characterRange = NSRange(location: location, length: length)
        guard let textField = textField(at: token), let rects = rects(forCharacterRange: characterRange, in: textField) else {
            return nil
        }
        return rects
    }

    func rects(forCharacterRange range: NSRange, in textField: NSTextField) -> [NSValue]? {
        guard let textFieldCell = textField.cell,
              let textFieldCellBounds = textFieldCell.controlView?.bounds
        else {
            return nil
        }
        let textBounds = textFieldCell.titleRect(forBounds: textFieldCellBounds)
        let textContainer = NSTextContainer()
        let layoutManager = NSLayoutManager()
        let textStorage = NSTextStorage()

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        layoutManager.typesetterBehavior = .latestBehavior

        textContainer.containerSize = textBounds.size
        textStorage.beginEditing()
        textStorage.setAttributedString(textFieldCell.attributedStringValue)
        textStorage.endEditing()

        var count = 0
        guard let rectsArray = layoutManager.rectArray(
            forCharacterRange: range,
            withinSelectedCharacterRange: range,
            in: textContainer,
            rectCount: &count
        )
        else {
            return nil
        }
        return rectsArray.values(count: count)
    }

    func drawCharacters(in range: NSRange, forContentView view: NSView) {}
}

extension NSRectArray {
    func values(count: Int) -> [NSValue] {
        (0 ..< count).map { NSValue(rect: self[$0]) }
    }

    func rects(count: Int) -> [NSRect] {
        (0 ..< count).map { self[$0] }
    }
}
