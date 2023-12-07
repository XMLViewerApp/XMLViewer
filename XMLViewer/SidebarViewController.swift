//
//  SidebarViewController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/6.
//

import AppKit
import UniformTypeIdentifiers

protocol SidebarViewControllerDelegate: AnyObject {
    func sidebarViewController(_ controller: SidebarViewController, didSelectXMLFileData: Data)
}

class SidebarViewController: NSViewController {
    weak var delegate: SidebarViewControllerDelegate?
    
    
    @IBAction func handleSelectXMLFileAction(_ button: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.allowedContentTypes = [.xml]
        let result = openPanel.runModal()
        guard result == .OK, let url = openPanel.url, let data = try? Data(contentsOf: url) else { return }
        delegate?.sidebarViewController(self, didSelectXMLFileData: data)
    }
}
