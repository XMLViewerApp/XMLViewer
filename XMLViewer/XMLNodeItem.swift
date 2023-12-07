//
//  XMLNodeItem.swift
//  XMLViewer
//
//  Created by JH on 2023/12/7.
//

import Foundation

class XMLNodeItem {
    var xmlNode: XMLNode
    var children: [XMLNodeItem] = []

    init(xmlNode: XMLNode) {
        self.xmlNode = xmlNode

        // 处理子节点
        if let element = xmlNode as? XMLElement {
            self.children = element.children?.compactMap { XMLNodeItem(xmlNode: $0) } ?? []

            // 将属性也作为节点添加
            let attributeNodes = element.attributes?.compactMap { XMLNodeItem(attribute: $0) } ?? []
            self.children.append(contentsOf: attributeNodes)
        }
    }

    // 专门用于处理属性节点的初始化方法
    init(attribute: XMLNode) {
        self.xmlNode = attribute
    }
}
