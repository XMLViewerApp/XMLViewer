//
//  SettingCenter.swift
//  XMLViewer
//
//  Created by JH on 2023/12/16.
//

import AppKit
import Defaults

typealias XMLViewerDefaults = Defaults

extension Defaults.Keys {
    enum Settings {
        static let autoExpand: Defaults.Key<Bool> = .init("autoExpand", default: true)
    }
}
