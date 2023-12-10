//
//  XMLDocumentItemStore.swift
//  XMLViewer
//
//  Created by JH on 2023/12/10.
//

import AppKit

class XMLDocumentItemStore {
    var items: [XMLDocumentItem]
    init(items: [XMLDocumentItem] = []) {
        self.items = items
    }

    func addItem(_ item: XMLDocumentItem) {
        items.append(item)
    }
}
