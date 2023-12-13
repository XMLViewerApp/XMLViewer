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
    }

    var rootNode: XMLNodeItem? {
        didSet {
            guard let rootNode else { return }
            currentStringCount = 0
            tokens = []
            traverseTree(node: rootNode, atDepth: 0)
        }
    }

    private(set) var currentStringCount: Int = 0

    private(set) var tokens: [Token] = []

    func traverseTree(node: XMLNodeItem?, atDepth depth: Int = 0) {
        guard let node else { return }

        if let name = node.node.name {
            let nameToken = Token(index: currentStringCount, row: depth, column: .name, string: name)
            tokens.append(nameToken)

            currentStringCount += name.utf16.count
        }
        if let value = node.node.stringValue {
            let valueToken = Token(index: currentStringCount, row: depth, column: .value, string: value)
            tokens.append(valueToken)

            currentStringCount += value.utf16.count
        }
        // 递归遍历子节点
        node.children.enumerated().forEach { index, childNode in
            traverseTree(node: childNode, atDepth: depth + 1)
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
