//
//  SplitContainerViewController.swift
//  XMLViewer
//
//  Created by JH on 2023/12/12.
//

import AppKit
import SnapKit
import SFSymbol
import IDEIcons
import XMLViewerUI
import ViewHierarchyBuilder

class SplitContainerViewController: XiblessViewController<NSView> {
    let topBarView = TopBarView()

    let containerView = XiblessView()

    let bottomBarView = BottomBarView()

    var topBarHeight: CGFloat {
        showTopBar ? 30 : 0
    }

    var showTopBar: Bool = false {
        didSet {
            topBarView.snp.remakeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                make.left.right.equalToSuperview()
                make.height.equalTo(topBarHeight)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        hierarchy {
            topBarView
            containerView
            bottomBarView
        }

        topBarView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(topBarHeight)
        }

        containerView.snp.makeConstraints { make in
            make.top.equalTo(topBarView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(bottomBarView.snp.top)
        }

        bottomBarView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(30)
        }
    }
}

class TopBarView: XiblessView {
    private let closeButton = Button()

    var didClickCloseButton: () -> Void = {}

    override init(frame frameRect: CGRect) {
        super.init(frame: frameRect)

        hierarchy {
            closeButton
        }

        closeButton.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(30)
        }

        closeButton.do {
            $0.isBordered = false
            $0.image = NSImage(named: NSImage.stopProgressTemplateName)
            $0.box.setTarget(self, action: #selector(closeButtonAction(_:)))
        }
    }

    @objc func closeButtonAction(_ sender: NSButton) {
        didClickCloseButton()
    }
}

class BottomBarView: XiblessView {
    private let pathControl = NSPathControl()

    public var filePath: XMLFilePath? {
        didSet {
            guard let filePath else { return }
            switch filePath {
            case let .fileSystem(url):
                pathControl.url = url
            case let .archiveEntry(string):
                var components = string.components(separatedBy: "/")
                guard let last = components.popLast() else { return }
                var items = components.map { component in
                    let item = NSPathControlItem()
                    item.title = component
                    item.image = NSImage(named: NSImage.folderName)
                    return item
                }
                let item = NSPathControlItem().then {
                    $0.title = last
                    $0.image = IDEIcon(systemImage: "chevron.left.forwardslash.chevron.right", color: .green).image
                }
                items.append(item)
                pathControl.pathItems = items
            }
        }
    }

    override init(frame frameRect: CGRect) {
        super.init(frame: frameRect)

        hierarchy {
            pathControl
        }

        pathControl.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        pathControl.do {
            $0.isEditable = false
        }
    }
}
