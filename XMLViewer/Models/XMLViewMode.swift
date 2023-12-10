//
//  XMLViewMode.swift
//  XMLViewer
//
//  Created by JH on 2023/12/10.
//

import AppKit
import SFSymbol

enum XMLViewMode: Int, CaseIterable {
    case outline
    case text
    
    var label: String {
        switch self {
        case .outline:
            "Outline"
        case .text:
            "Text"
        }
    }
    
    var image: NSImage {
        switch self {
        case .outline:
            SFSymbol(systemName: .listBulletIndent).nsImage
        case .text:
            SFSymbol(systemName: .character).nsImage
        }
    }
}
