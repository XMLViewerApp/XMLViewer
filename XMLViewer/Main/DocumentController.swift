//
//  DocumentController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/10.
//

import AppKit

class DocumentController: NSDocumentController {
    static var `default`: DocumentController { shared as! DocumentController }

    static let willOpenNotification = Notification.Name("DocumentControllerWillOpenNotification")

    static let didOpenNotification = Notification.Name("DocumentControllerDidOpenNotification")
    
    override func openDocument(withContentsOf url: URL, display displayDocument: Bool, completionHandler: @escaping (NSDocument?, Bool, (any Error)?) -> Void) {
        NotificationCenter.default.post(name: Self.willOpenNotification, object: self)
        super.openDocument(withContentsOf: url, display: displayDocument) {
            completionHandler($0, $1, $2)
            NotificationCenter.default.post(name: Self.didOpenNotification, object: self)
        }
    }
    
    override class func restoreWindow(withIdentifier identifier: NSUserInterfaceItemIdentifier, state: NSCoder, completionHandler: @escaping (NSWindow?, (any Error)?) -> Void) {
        completionHandler(nil, CocoaError.error(.userCancelled))
    }
}
