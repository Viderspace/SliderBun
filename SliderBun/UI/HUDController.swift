//
//  HUDController.swift
//  QMKBridge
//
//  Created by Jonatan Vider on 28/11/2025.
//

import AppKit
import SwiftUI

@MainActor
final class HUDController {
    private let uiState: AppUIState
    private unowned let statusItem: NSStatusItem

    private let hudTimeout: TimeInterval
    private var hideTask: Task<Void, Never>?
    private let popover: NSPopover

    init(
        uiState: AppUIState,
        statusItem: NSStatusItem,
        hudTimeout: TimeInterval = 0.5
    ) {
        self.uiState = uiState
        self.statusItem = statusItem
        self.hudTimeout = hudTimeout

        let popover = NSPopover()
        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = NSSize(width: 80, height: 180)
        popover.contentViewController = NSHostingController(
            rootView: HUDView(uiState: uiState)
        )
        self.popover = popover
    }

    // MARK: - Public API

    func showIfNeeded() {
        guard uiState.showHUDOnEvents else { return }
        show()
    }

    func restartHideTimerIfNeeded() {
        guard uiState.showHUDOnEvents else { return }

        hideTask?.cancel()
        hideTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(
                nanoseconds: UInt64(hudTimeout * 1_000_000_000)
            )
            if !Task.isCancelled {
                self.hide()
            }
        }
    }

    func show() {
        guard let button = statusItem.button else { return }
        guard !popover.isShown else { return }

        popover.show(
            relativeTo: button.bounds,
            of: button,
            preferredEdge: .minY
        )
    }

    func hide() {
        if popover.isShown {
            popover.performClose(nil)
        }
    }

    var isVisible: Bool {
        popover.isShown
    }
}
