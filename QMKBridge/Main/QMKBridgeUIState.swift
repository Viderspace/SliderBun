//
//  QMKBridgeUIState.swift
//  QMKBridge
//
//  Created by Jonatan Vider on 27/11/2025.
//

import Foundation

@MainActor
@Observable
final class QMKBridgeUIState {

    // You can keep these if ContentView or other debug UI still relies on them.
    // If not used anywhere, feel free to remove them as well.
    var volume: Float = 0.0
    var brightness: Float = 0.0
    var currentFunction: HUDFunction = .volume

    // MARK: - Generic HUD state (new source of truth)

    /// Which logical function the HUD is currently showing
    var hudFunction: HUDFunction = .volume

    /// Normalized 0.0 ... 1.0 value for the current HUD function
    var hudValue: Float = 0.0

    /// SF Symbol name for the current HUD icon
    var hudIconName: String = "speaker.wave.2.fill"

    var showHUDOnEvents: Bool = true

}

// MARK: - NEW generic HUD update API used by the engine

extension QMKBridgeUIState {
    /// Update the HUD based on a control descriptor and a normalized value.
    /// This is the new, generic path for ALL commands.
    func updateHUD(using descriptor: ControlDescriptor, normalized: Float) {

        let clamped = max(0, min(1, normalized))

        // Update generic HUD state
        hudFunction = descriptor.function
        hudValue = clamped
        hudIconName = descriptor.iconNameForValue(clamped)

    }
}
