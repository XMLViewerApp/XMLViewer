//
//  XMLDocumentItem.swift
//  XMLViewer
//
//  Created by JH on 2023/12/10.
//

import AppKit

class XMLDocumentItem {
    let name: String
    let document: XMLDocument

    lazy var rootNode: XMLNodeItem? = {
        guard let rootElement = document.rootElement() else { return nil }
        return XMLNodeItem(rootElement: rootElement)
    }()

    lazy var text: String = document.xmlString()

    init(name: String, data: Data) throws {
        self.name = name
        self.document = try XMLDocument(data: data)
    }
}
