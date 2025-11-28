//
//  StatusItemController.swift
//  QMKBridge
//
//  Created by Jonatan Vider on 27/11/2025.
//

import AppKit
import SwiftUI

@MainActor
final class StatusItemController: NSObject {

    private let statusItem: NSStatusItem
    private let uiState: QMKBridgeUIState
    private let iconRenderer: StatusIconRenderer
    private let settingsController: SettingsWindowController
    private let hudController: HUDController

    init(uiState: QMKBridgeUIState) {
        self.uiState = uiState
        self.iconRenderer = StatusIconRenderer(canvasSize: NSSize(width: 26, height: 18))
        self.settingsController = SettingsWindowController(uiState: uiState)

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.statusItem = item
        self.hudController = HUDController(
            uiState: uiState,
            statusItem: item,
            hudTimeout: 0.5
        )
        super.init()

        if let button = item.button {
            button.image = iconRenderer.image(named: "MenuBarIcon")
            button.imagePosition = .imageOnly
            button.isBordered = false
            button.bezelStyle = .texturedRounded
            button.action = #selector(statusItemClicked(_:))
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    @objc private func statusItemClicked(_ sender: Any?) {
        guard let event = NSApp.currentEvent else {
            showSettingsWindow()
            return
        }

        switch event.type {
        case .rightMouseUp:
            showStatusItemMenu(with: event)

        case .leftMouseUp:
            if event.modifierFlags.contains(.control) {
                showStatusItemMenu(with: event)
            } else {
                showSettingsWindow()
            }

        default:
            break
        }
    }

    private func showStatusItemMenu(with event: NSEvent) {
        let menu = NSMenu()
        let quitItem = NSMenuItem(
            title: "Quit SliderBun",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        if let button = statusItem.button {
            NSMenu.popUpContextMenu(menu, with: event, for: button)
        }
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }

    func showHUDIfNeeded() {
        hudController.showIfNeeded()
    }


    func restartHideTimer() {
        hudController.restartHideTimerIfNeeded()
    }


    func updateMenuBarIcon() {
        guard
            let button = statusItem.button,
            let image = iconRenderer.systemImage(named: uiState.hudIconName)
        else { return }

        button.image = image
    }

    private func showSettingsWindow() {
        settingsController.show()
    }
}
