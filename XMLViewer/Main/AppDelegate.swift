//
//  AppDelegate.swift
//  XMLViewer
//
//  Created by JH on 2023/12/6.
//

import AppKit
import Darwin

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    override init() {
        super.init()
        _ = DocumentController.shared
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let isDefaultLaunch = aNotification.userInfo?[NSApplication.launchIsDefaultUserInfoKey] as? Bool,
           isDefaultLaunch || Helper.isDebuggerAttached {
            WelcomeManager.shared.show()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag {
            return false
        }

        if DocumentController.default.documents.isEmpty {
            WelcomeManager.shared.show()
        }

        return false
    }

    @IBAction func showSettings(_ sender: Any?) {
        SettingsManager.shared.show()
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        false
    }
}

enum Helper {
    static let isDebuggerAttached: Bool = {
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]

        let status = sysctl(&mib, u_int(mib.count), &info, &size, nil, 0)
        if status != 0 {
            return false
        }

        return (info.kp_proc.p_flag & P_TRACED) != 0

    }()
}
