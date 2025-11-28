//
//  QMKBridgeEngine.swift
//  QMKBridge
//
//  Created by Jonatan Vider on 26/11/2025.
//

import Foundation


final class QMKBridgeEngine: QMKBridgeListener {

    private let registry: CommandRegistry
    private let uiState: QMKBridgeUIState
    private let statusItemController: StatusItemController

    init(
        registry: CommandRegistry,
        uiState: QMKBridgeUIState,
        statusItemController: StatusItemController
    ) {
        self.registry = registry
        self.uiState = uiState
        self.statusItemController = statusItemController
    }

    func didReceive(_ message: QMKBridgeMessage) {
        guard
            let cmd = message.command,
            let descriptor = registry[cmd]
        else {
            return
        }

        let value = message.normalized

        // 1) Perform side-effect for this control (volume/brightness/shortcut)
        descriptor.applySideEffect(value)

        // 2) Update HUD state (generic path)
        uiState.updateHUD(using: descriptor, normalized: value)
        statusItemController.updateMenuBarIcon()


        // 3) Show HUD & schedule hide (same behavior for all functions)
        statusItemController.showHUDIfNeeded()
        statusItemController.restartHideTimer()
    }
}
