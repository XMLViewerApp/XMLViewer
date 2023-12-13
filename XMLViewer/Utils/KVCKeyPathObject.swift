//
//  KVCKeyPathObject.swift
//  XMLViewer
//
//  Created by JH on 2023/12/13.
//

import AppKit

protocol KVCKeyPathObject: NSObject {}

extension NSObject: KVCKeyPathObject {}

extension KVCKeyPathObject {
    static func keyPathString(_ keyPath: KeyPath<Self, some Any>) -> String? {
        keyPath._kvcKeyPathString
    }
}
