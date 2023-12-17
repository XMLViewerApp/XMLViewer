//
//  XMLDocumentItem.swift
//  XMLViewer
//
//  Created by JH on 2023/12/10.
//

import AppKit

enum XMLFilePath {
    case fileSystem(URL)
    case archiveEntry(String)
    
    var stringValue: String {
        switch self {
        case let .fileSystem(url):
            return url.path
        case let .archiveEntry(string):
            return string
        }
    }
}

class XMLDocumentItem {
    let name: String
    let path: XMLFilePath
    let document: XMLDocument

    lazy var rootNode: XMLNodeItem? = document.rootElement().map { XMLNodeItem(rootElement: $0) }

    lazy var text: String = document.xmlString()

    init(path: XMLFilePath, data: Data) throws {
        self.name = path.stringValue.lastPathComponent
        self.path = path
        self.document = try XMLDocument(data: data)
    }
}

extension String {
    var lastPathComponent: String {
        let nsString = self as NSString
        return nsString.lastPathComponent
    }
}
