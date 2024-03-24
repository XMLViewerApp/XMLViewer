//
//  TextFinderController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/13.
//

import AppKit
import Combine

class OutlineTextFinderClient: NSObject, NSTextFinderClient {
    unowned let outlineView: NSOutlineView

    let textFinder = NSTextFinder()

    let indexStore = OutlineTextIndexStore()

    var contentObservation: NSKeyValueObservation?

    var cancellables: Set<AnyCancellable> = []

    /// TextKit1
    let textStorage = NSTextStorage()
    let textContainerWithTextKit1 = NSTextContainer()
    let layoutManager = NSLayoutManager()
    /// TextKit2
    let textContentStorage = NSTextContentStorage()
    let textContainerWithTextKit2 = NSTextContainer()
    let textLayoutManager = NSTextLayoutManager()

    init(outlineView: NSOutlineView, initialValue: XMLNodeItem?, publisher: Published<XMLNodeItem?>.Publisher) {
        self.outlineView = outlineView
        super.init()
        indexStore.rootNode = initialValue
        textFinder.client = self
        textFinder.findBarContainer = outlineView.enclosingScrollView
        // Initial for TextKit1
        layoutManager.addTextContainer(textContainerWithTextKit1)
        textStorage.addLayoutManager(layoutManager)
        layoutManager.typesetterBehavior = .latestBehavior
        textContainerWithTextKit1.lineFragmentPadding = 2
        // Initial for TextKit2
        textLayoutManager.textContainer = textContainerWithTextKit2
        textContentStorage.addTextLayoutManager(textLayoutManager)
        textContentStorage.primaryTextLayoutManager = textLayoutManager
        textContainerWithTextKit2.lineFragmentPadding = 2

        publisher.sink { [weak self] rootNode in
            guard let self else { return }
            textFinder.noteClientStringWillChange()
            indexStore.rootNode = rootNode
        }
        .store(in: &cancellables)
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
        var location = currentSelectedLocation + 4
        if location > indexStore.currentStringCount {
            location = indexStore.currentStringCount
        }
        return .init(location: location, length: 0)
    }

    func contentView(at index: Int, effectiveCharacterRange outRange: NSRangePointer) -> NSView {
        let token = indexStore[index]

        var parent: Any? = outlineView.parent(forItem: token.nodeItem)
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
        let token = indexStore[range.location]
        let location = range.location - token.index
        let length = range.length
        let characterRange = NSRange(location: location, length: length)
        guard let textField = textField(at: token), let rects = rectsWithTextKit2(forCharacterRange: characterRange, in: textField) else {
            return nil
        }
        return rects
    }

    func rectsWithTextKit1(forCharacterRange range: NSRange, in textField: NSTextField) -> [NSValue]? {
        guard let textFieldCell = textField.cell else { return nil }
        let textBounds = textFieldCell.titleRect(forBounds: textField.bounds)
        print(textBounds)
        textContainerWithTextKit1.containerSize = textBounds.size
        textStorage.beginEditing()
        textStorage.setAttributedString(textField.attributedStringValue)
        textStorage.endEditing()
        var rects: [NSValue] = []
        layoutManager.enumerateEnclosingRects(forGlyphRange: range, withinSelectedGlyphRange: range, in: textContainerWithTextKit1) { rect, _ in
            rects.append(.init(rect: rect))
        }
        return rects
    }

    func rectsWithTextKit2(forCharacterRange range: NSRange, in textField: NSTextField) -> [NSValue]? {
        guard let textFieldCell = textField.cell else { return nil }
        let textBounds = textFieldCell.titleRect(forBounds: textField.bounds)
        print(textBounds)
        textContentStorage.attributedString = textField.attributedStringValue
        textContainerWithTextKit2.containerSize = textBounds.size
        guard let textRange = NSTextRange(range, in: textContentStorage) else { return nil }
        var rects: [NSValue] = []
        textLayoutManager.enumerateTextSegments(in: textRange, type: .standard) { _, rect, _, _ in
            rects.append(.init(rect: rect))
            return true
        }
        return rects
    }

    func drawCharacters(in range: NSRange, forContentView view: NSView) {
        let token = indexStore[range.location]
        let location = range.location - token.index
        let length = range.length
        let characterRange = NSRange(location: location, length: length)
        guard let textRange = NSTextRange(characterRange, in: textContentStorage),
              let context = NSGraphicsContext.current?.cgContext
        else { return }
        if let layoutFragment = textLayoutManager.textLayoutFragment(for: textRange.location) {
            layoutFragment.draw(at: layoutFragment.layoutFragmentFrame.pixelAligned.origin, in: context)
        }
    }
}

extension NSRectArray {
    func values(count: Int) -> [NSValue] {
        (0 ..< count).map { NSValue(rect: self[$0]) }
    }

    func rects(count: Int) -> [NSRect] {
        (0 ..< count).map { self[$0] }
    }
}

extension NSTextRange {
    public convenience init?(_ nsRange: NSRange, in textContentManager: NSTextContentManager) {
        guard let start = textContentManager.location(textContentManager.documentRange.location, offsetBy: nsRange.location) else {
            return nil
        }
        let end = textContentManager.location(start, offsetBy: nsRange.length)
        self.init(location: start, end: end)
    }
}

extension CGRect {
    var pixelAligned: CGRect {
        // https://developer.apple.com/library/archive/documentation/GraphicsAnimation/Conceptual/HighResolutionOSX/APIs/APIs.html#//apple_ref/doc/uid/TP40012302-CH5-SW9
        // NSIntegralRectWithOptions(self, [.alignMinXOutward, .alignMinYOutward, .alignWidthOutward, .alignMaxYOutward])
        #if os(macOS)
        NSIntegralRectWithOptions(self, .alignAllEdgesNearest)
        #else
        // NSIntegralRectWithOptions is not available in ObjC Foundation on iOS
        // "self.integral" is not the same, but for now it has to be enough
        // https://twitter.com/krzyzanowskim/status/1512451888515629063
        integral
        #endif
    }
}
