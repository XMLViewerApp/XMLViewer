//
//  AppDelegate.swift
//  XMLViewer
//
//  Created by JH on 2023/12/6.
//

import AppKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    override init() {
        super.init()
        _ = DocumentController.shared
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        WelcomeManager.shared.show()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            if DocumentController.default.documents.isEmpty {
                WelcomeManager.shared.show()
            } else {
                DocumentController.default.documents.forEach { document in
                    document.showWindows()
                }
            }
        }
        return true
    }
    
    @IBAction func showSettings(_ sender: Any?) {
        SettingsManager.shared.show()
    }
}
