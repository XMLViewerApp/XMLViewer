//
//  DocumentController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/10.
//

import AppKit

class DocumentController: NSDocumentController {
    static var `default`: DocumentController { shared as! DocumentController }
    
    override func reopenDocument(for urlOrNil: URL?, withContentsOf contentsURL: URL, display displayDocument: Bool, completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void) {
        completionHandler(nil, false, nil)
    }
}
