//
//  XMLNode.Kind+.swift
//  XMLViewer
//
//  Created by JH on 2023/12/10.
//

import AppKit
import IDEIcons

extension XMLNode.Kind: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalid:
            "Invalid"
        case .document:
            "Document"
        case .element:
            "Element"
        case .attribute:
            "Attribute"
        case .namespace:
            "Namespace"
        case .processingInstruction:
            "Processing Instruction"
        case .comment:
            "Comment"
        case .text:
            "Text"
        case .DTDKind:
            "DTD"
        case .entityDeclaration:
            "Entity declaration"
        case .attributeDeclaration:
            "Attribute declaration"
        case .elementDeclaration:
            "Element declaration"
        case .notationDeclaration:
            "Notation declaration"
        @unknown default:
            "Unknown"
        }
    }
    
    var ideIcon: IDEIcon? {
        switch self {
        case .invalid:
            IDEIcon("I", color: .red)
        case .document:
            IDEIcon("D", color: .purple)
        case .element:
            IDEIcon("E", color: .yellow)
        case .attribute:
            IDEIcon("A", color: .blue)
        case .namespace:
            IDEIcon("N", color: .pink)
        case .processingInstruction:
            nil
        case .comment:
            IDEIcon("C", color: .gray)
        case .text:
            IDEIcon("T", color: .green)
        case .DTDKind:
            IDEIcon("DTD", color: .teal)
        case .entityDeclaration:
            nil
        case .attributeDeclaration:
            nil
        case .elementDeclaration:
            nil
        case .notationDeclaration:
            nil
        default:
            nil
        }
    }
}
