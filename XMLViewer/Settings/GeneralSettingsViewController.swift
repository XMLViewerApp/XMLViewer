//
//  GeneralSettingsViewController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/16.
//

import Cocoa
import Settings
import SFSymbol

class GeneralSettingsViewController: NSViewController, SettingsPane {
    var paneIdentifier: Settings.PaneIdentifier = .general

    var paneTitle: String = "General"

    var toolbarItemIcon: NSImage = SFSymbol(systemName: .gearshape).nsImage

    override var nibName: NSNib.Name? { .init(describing: Self.self) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        autoExpandCheckbox.state = XMLViewerDefaults[.Settings.autoExpand] ? .on : .off
    }
    
    @IBOutlet var autoExpandCheckbox: NSButton!
    
    @IBAction func autoExpandCheckboxAction(_ sender: NSButton) {
        XMLViewerDefaults[.Settings.autoExpand] = sender.state.boolValue
    }
}


extension NSControl.StateValue {
    init(boolValue: Bool) {
        self = boolValue ? .on : .off
    }
    
    var boolValue: Bool {
        self == .on
    }
}
