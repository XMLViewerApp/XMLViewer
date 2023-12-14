//
//  OutlineNodeIndexStore.swift
//  XMLViewer
//
//  Created by JH on 2023/12/14.
//

import AppKit

class OutlineTextIndexStore {
    struct Token {
        var index: Int
        var row: Int
        var column: OutlineViewColumn
        let string: String
        weak var nodeItem: XMLNodeItem?
    }

    var rootNode: XMLNodeItem? {
        didSet {
            guard let rootNode else { return }
            currentStringCount = 0
            currentRow = 0
            tokens = []
            traverseTree(node: rootNode)
        }
    }

    private(set) var currentStringCount: Int = 0

    private(set) var tokens: [Token] = []

    private var currentRow: Int = 0

    func traverseTree(node: XMLNodeItem?) {
        guard let node else { return }

        if let name = node.node.name {
            let nameToken = Token(index: currentStringCount, row: currentRow, column: .name, string: name, nodeItem: node)
            tokens.append(nameToken)

            currentStringCount += name.utf16.count
        }
        if let value = node.node.stringValue {
            let valueToken = Token(index: currentStringCount, row: currentRow, column: .value, string: value, nodeItem: node)
            tokens.append(valueToken)

            currentStringCount += value.utf16.count
        }

        currentRow += 1

        // 递归遍历子节点
        node.children.enumerated().forEach { index, childNode in
            traverseTree(node: childNode)
        }
    }

    subscript(characterIndex: Int) -> Token {
        var position = tokens.count
        var currentIndex = 0
        repeat {
            position -= 1
            currentIndex = tokens[position].index
        } while position > 0 && currentIndex > characterIndex
        let result = tokens[position]
        return result
    }
}
