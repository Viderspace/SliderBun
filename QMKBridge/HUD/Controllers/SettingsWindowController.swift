//
//  SettingsWindowController.swift
//  QMKBridge
//
//  Created by Jonatan Vider on 28/11/2025.
//


import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController: NSObject, NSWindowDelegate {
    private let uiState: QMKBridgeUIState
    private var window: NSWindow?

    init(uiState: QMKBridgeUIState) {
        self.uiState = uiState
        super.init()
    }

    func show() {
        // If we already have a window, just bring it to front
        if let window = window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        // Create a new window with a SwiftUI SettingsView
        let hosting = NSHostingController(rootView: SettingsView(uiState: uiState))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 260, height: 160),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )

        window.title = "SliderBun"
        window.isReleasedWhenClosed = false
        window.contentViewController = hosting
        window.center()
        window.delegate = self

        window.collectionBehavior.insert(.canJoinAllSpaces)
        window.level = .floating

        self.window = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: - NSWindowDelegate

    func windowWillClose(_ notification: Notification) {
        window = nil
    }

    func windowDidResignKey(_ notification: Notification) {
        guard let window = notification.object as? NSWindow,
              window === self.window else { return }

        window.close()
    }
}
