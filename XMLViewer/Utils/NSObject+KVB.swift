//
//  NSObject+KVB.swift
//  XMLViewer
//
//  Created by JH on 2023/12/13.
//

import AppKit

extension NSObject {
    public func bind<Root>(_ binding: NSBindingName, to observable: Root, keyPath: KeyPath<Root, some Any>, options: [NSBindingOption: Any]? = nil) {
        guard let kvcKeyPath = keyPath._kvcKeyPathString else {
            print("KeyPath doesn't contain @objc exposed values")
            return
        }
        bind(binding, to: observable, withKeyPath: kvcKeyPath, options: options)
    }
}
