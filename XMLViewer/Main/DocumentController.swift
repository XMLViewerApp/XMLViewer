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

    override func reopenDocument(for urlOrNil: URL?, withContentsOf contentsURL: URL, display displayDocument: Bool, completionHandler: @escaping (NSDocument?, Bool, (any Error)?) -> Void) {
        completionHandler(nil, false, nil)
    }
}
