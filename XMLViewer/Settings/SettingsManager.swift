//
//  SettingsManager.swift
//  XMLViewer
//
//  Created by JH on 2023/12/16.
//

import AppKit
import Settings

class SettingsManager {
    static let shared = SettingsManager()
    
    private lazy var panes: [SettingsPane] = [
        GeneralSettingsViewController()
    ]
    
    private lazy var settingsWindowController = SettingsWindowController(panes: panes, style: .toolbarItems, animated: true, hidesToolbarForSingleItem: true)
    
    
    public func show(pane paneIdentifier: Settings.PaneIdentifier? = nil) {
        settingsWindowController.show(pane: paneIdentifier)
    }
    
    public func close() {
        settingsWindowController.close()
    }
}

extension Settings.PaneIdentifier {
    static let general = Self("general")
}
