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

    private var documentController: DocumentController { .default }

    private init() {
        let primaryAction = WelcomeAction(image: SFSymbol(systemName: .chevronLeftForwardslashChevronRight).nsImage, title: "Open Plain XML", subtitle: "Open a plain XML file ") { [weak self] _ in
            guard let self else { return }
            documentController.beginOpenPanel { urls in
                guard let url = urls?.first else { return }
                self.documentController.openDocument(withContentsOf: url, display: true) { _, _, _ in }
                self.close()
            }
        }
        let secondaryAction = WelcomeAction(image: SFSymbol(systemName: .docText).nsImage, title: "Open Office Open XML", subtitle: "Open a Microsoft Office document file") { [weak self] _ in
            guard let self else { return }
            documentController.beginOpenPanel { urls in
                guard let url = urls?.first else { return }
                self.documentController.openDocument(withContentsOf: url, display: true) { _, _, _ in }
                self.close()
            }
        }
        welcomePanelController.configuration = .init(primaryAction: primaryAction, secondaryAction: secondaryAction)
        welcomePanelController.dataSource = self
        welcomePanelController.delegate = self
    }

    private var cancellable = Set<AnyCancellable>()

    private let welcomePanelController: WelcomePanelController = .init()

    public func show() {
        welcomePanelController.showWindow(self)
    }

    public func close() {
        welcomePanelController.close()
    }
}

extension WelcomeManager: WelcomePanelDataSource, WelcomePanelDelegate {
    func welcomePanelUsesRecentDocumentURLs(_ welcomePanel: WelcomePanelController) -> Bool {
        return true
    }

    func numberOfProjects(in welcomePanel: WelcomeKit.WelcomePanelController) -> Int {
        return documentController.recentDocumentURLs.count
    }

    func welcomePanel(_ welcomePanel: WelcomeKit.WelcomePanelController, urlForProjectAtIndex index: Int) -> URL {
        return documentController.recentDocumentURLs[index]
    }

    func welcomePanel(_ welcomePanel: WelcomeKit.WelcomePanelController, didSelectProjectAtIndex index: Int) {}

    func welcomePanel(_ welcomePanel: WelcomePanelController, didCheckShowPanelWhenLaunch isCheck: Bool) {}

    func welcomePanel(_ welcomePanel: WelcomeKit.WelcomePanelController, didDoubleClickProjectAtIndex index: Int) {
        guard let url = documentController.recentDocumentURLs[safe: index] else { return }
        documentController.openDocument(withContentsOf: url, display: true) { _, _, _ in
            self.close()
        }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}
