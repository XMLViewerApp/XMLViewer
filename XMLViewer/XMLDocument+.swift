//
//  XMLDocument+.swift
//  XMLViewer
//
//  Created by JH on 2023/12/7.
//

import Foundation

extension XMLDocument {
    func traverseXMLNode() {
        guard let rootNode = rootElement() else { return }
        traverseXMLNode(rootNode)
    }

    func traverseXMLNode(_ node: XMLNode, indentLevel: Int = 0) {
        let indent = String(repeating: "  ", count: indentLevel)

        // 打印节点类型和名称
        print("\(indent)\(node.kind) - Name: \(node.name ?? "N/A")")

        // 如果节点是元素类型，打印其属性
        if let element = node as? XMLElement {
            let attributesString = element.attributes?.map { "\($0.name ?? "")=\($0.stringValue ?? "")" }.joined(separator: ", ") ?? "None"
            print("\(indent)Attributes: \(attributesString)")
        }

        // 打印节点的值（如果有）
        if !node.stringValue!.isEmpty {
            print("\(indent)Value: \(node.stringValue ?? "")")
        }

        // 递归遍历子节点
        if let children = node.children {
            for child in children {
                traverseXMLNode(child, indentLevel: indentLevel + 1)
            }
        }
    }

    static func create(data: Data) async throws -> XMLDocument {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<XMLDocument, Error>) in
            DispatchQueue.global().async {
                do {
                    let document = try XMLDocument(data: data)
                    continuation.resume(returning: document)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}


extension XMLDocument: @unchecked Sendable {}
