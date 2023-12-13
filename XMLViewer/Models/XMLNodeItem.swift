//
//  XMLNodeItem.swift
//  XMLViewer
//
//  Created by JH on 2023/12/7.
//

import Foundation

class XMLNodeItem: NSObject, Comparable {
    let node: XMLNode

    @objc dynamic var children: [XMLNodeItem] = []

    private(set) var siblingIndex: Int

    private(set) var isDisplayIndex: Bool

    @objc dynamic var isLeaf: Bool {
        children.count == 0
    }
    
    @objc dynamic var childrenCount: Int {
        children.count
    }
    
    var hasValidName: Bool {
        if let name = node.name, !name.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    var hasValidValue: Bool {
        if let value = node.stringValue, !value.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    var hasChildren: Bool {
        !children.isEmpty
    }

    convenience init(rootElement: XMLElement) {
        self.init(element: rootElement, siblingIndex: 0, isDisplayIndex: false)
    }

    init(element: XMLNode, siblingIndex: Int, isDisplayIndex: Bool) {
        self.node = element

        self.siblingIndex = siblingIndex

        self.isDisplayIndex = isDisplayIndex
        // 处理子节点
        if let element = element as? XMLElement {
            var childNameCounts = [String: Int]()
            var childIndexMap = [String: Int]()
            let elementChildrenNodes = element.children ?? []

            for childrenNode in elementChildrenNodes {
                if let name = childrenNode.name {
                    childNameCounts[name, default: 0] += 1
                }
            }

            self.children = elementChildrenNodes.compactMap { node in
                guard node.kind != .comment, let name = node.name else { return nil }
                var index = 0
                var isDisplayIndex = false

                index = childIndexMap[name, default: 0]
                isDisplayIndex = childNameCounts[name, default: 0] > 1
                childIndexMap[name] = index + 1

                return XMLNodeItem(element: node, siblingIndex: index, isDisplayIndex: isDisplayIndex)
            }

            var attributeNameCounts = [String: Int]()
            var attributeIndexMap = [String: Int]()
            let attributeNodes = element.attributes ?? []
            for attributeNode in attributeNodes {
                if let name = attributeNode.name {
                    attributeNameCounts[name, default: 0] += 1
                }
            }

            // 将属性也作为节点添加
            let attributeChildrenNodes: [XMLNodeItem] = attributeNodes.compactMap { node in
                guard node.kind != .comment, let name = node.name else { return nil }
                var index = 0
                var isDisplayIndex = false

                index = attributeIndexMap[name, default: 0]
                isDisplayIndex = attributeNameCounts[name, default: 0] > 1
                attributeIndexMap[name] = index + 1

                return XMLNodeItem(attribute: node, siblingIndex: index, isDisplayIndex: isDisplayIndex)
            }

            children.append(contentsOf: attributeChildrenNodes)
        }

        children.sort()
    }

    /// 专门用于处理属性节点的初始化方法
    init(attribute: XMLNode, siblingIndex: Int, isDisplayIndex: Bool) {
        self.node = attribute
        self.siblingIndex = siblingIndex
        self.isDisplayIndex = isDisplayIndex
    }

    static func == (lhs: XMLNodeItem, rhs: XMLNodeItem) -> Bool {
        lhs.node == rhs.node
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? XMLNodeItem else { return false }
        return object.node.isEqual(node)
    }
    
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(node)
        return hasher.finalize()
    }

    static func < (lhs: XMLNodeItem, rhs: XMLNodeItem) -> Bool {
        lhs.node.kind.rawValue > rhs.node.kind.rawValue
    }
}
