//
//  XMLParserDelegate.swift
//  XMLViewer
//
//  Created by JH on 2023/12/7.
//

import Foundation

class XMLParserDelegate: NSObject, Foundation.XMLParserDelegate {
    class Node {
        var elementName: String
        var text: String = ""
        var attributes: [String: String]
        var children: [Node] = []

        init(elementName: String, attributes: [String: String]) {
            self.elementName = elementName
            self.attributes = attributes
        }

        func addChild(_ node: Node) {
            children.append(node)
        }
    }
    var root: Node?
    var currentElement: Node?
    var elementStack: [Node] = []

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        let newNode = Node(elementName: elementName, attributes: attributeDict)

        if let current = currentElement {
            current.addChild(newNode)
        } else {
            root = newNode
        }

        elementStack.append(newNode)
        currentElement = newNode
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentElement?.text += string.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        elementStack.removeLast()
        currentElement = elementStack.last
    }
    
    func traverseTree() {
        guard let root else { return }
        traverseTree(root)
    }
    
    func traverseTree(_ node: Node, indentLevel: Int = 0) {
        let indent = String(repeating: "  ", count: indentLevel) // 缩进，用于可视化层次结构

        // 打印当前节点的信息
        print("\(indent)Element: \(node.elementName)")
        if !node.text.isEmpty {
            print("\(indent)Text: \(node.text)")
        }
        if !node.attributes.isEmpty {
            print("\(indent)Attributes: \(node.attributes)")
        }

        // 递归遍历子节点
        for child in node.children {
            traverseTree(child, indentLevel: indentLevel + 1)
        }
    }
}
