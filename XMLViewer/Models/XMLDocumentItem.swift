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
        case .fileSystem(let url):
            return url.path
        case .archiveEntry(let string):
            return string
        }
    }
}


class XMLDocumentItem {
    let name: String
    let path: XMLFilePath
    let document: XMLDocument
    
    lazy var rootNode: XMLNodeItem? = {
        guard let rootElement = document.rootElement() else { return nil }
        return XMLNodeItem(rootElement: rootElement)
    }()

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
