//
//  WelcomeManager.swift
//  XMLViewer
//
//  Created by JH on 2023/12/10.
//

import AppKit
import Combine
import SFSymbol
import WelcomeKit

class WelcomeManager {
    static let shared = WelcomeManager()

    enum WelcomeAction: CaseIterable, WelcomeActionModel {
        case plainXML
        case openXML

        var iconImage: NSImage {
            switch self {
            case .plainXML:
                SFSymbol(systemName: .chevronLeftForwardslashChevronRight).nsImage
            case .openXML:
                SFSymbol(systemName: .docText).nsImage
            }
        }

        var title: String {
            switch self {
            case .plainXML:
                "Open Plain XML"
            case .openXML:
                "Open Office Open XML"
            }
        }

        var detail: String {
            switch self {
            case .plainXML:
                "Open a plain XML file "
            case .openXML:
                "Open a Microsoft Office document file"
            }
        }
    }

    private var documentController: DocumentController { .default }

    private init() {
        welcomePanelController.dataSource = self
        welcomePanelController.delegate = self
    }

    private var cancellable = Set<AnyCancellable>()

    private let welcomePanelController = WelcomePanelController()

    public func show() {
        welcomePanelController.showWindow(self)
    }

    public func close() {
        welcomePanelController.close()
    }
}

extension WelcomeManager: WelcomePanelDataSource, WelcomePanelDelegate {
    func numberOfActions(_ welcomePanel: WelcomeKit.WelcomePanelController) -> Int {
        return WelcomeAction.allCases.count
    }

    func numberOfProjects(_ welcomePanel: WelcomeKit.WelcomePanelController) -> Int {
        return documentController.recentDocumentURLs.count
    }

    func welcomePanel(_ welcomePanel: WelcomeKit.WelcomePanelController, modelForWelcomeActionViewAt index: Int) -> WelcomeKit.WelcomeActionModel {
        return WelcomeAction.allCases[index]
    }

    func welcomePanel(_ welcomePanel: WelcomeKit.WelcomePanelController, urlForRecentTableViewAt index: Int) -> URL {
        return documentController.recentDocumentURLs[index]
    }

    func welcomePanel(_ welcomePanel: WelcomeKit.WelcomePanelController, didClickActionAt index: Int) {
        documentController.beginOpenPanel { urls in
            guard let url = urls?.first else { return }
            self.documentController.openDocument(withContentsOf: url, display: true) { _, _, _ in }
            self.close()
        }
    }

    func welcomePanel(_ welcomePanel: WelcomeKit.WelcomePanelController, didSelectRecentProjectAt index: Int) {}

    func welcomePanel(_ welcomePanel: WelcomePanelController, didCheckShowPanelWhenLaunch isCheck: Bool) {}

    func welcomePanel(_ welcomePanel: WelcomeKit.WelcomePanelController, didDoubleClickRecentProjectAt index: Int) {
        let url = documentController.recentDocumentURLs[index]
        documentController.openDocument(withContentsOf: url, display: true) { _, _, _ in
            self.close()
        }
    }
}
