//
//  ControlDescriptor.swift
//  QMKBridge
//
//  Created by Jonatan Vider on 27/11/2025.
//

// QMKBridgeControlDescriptor.swift

import Foundation

/// High-level identity for what the HUD is showing.
enum HUDFunction {
    case volume
    case brightness
    case shortcut(Int)   // 1..4
}

/// Describes how a given QMK command behaves:
/// - what "function" it represents (for HUD / mode)
/// - what side-effect to perform for a normalized value
/// - how its icon changes as the value changes
struct ControlDescriptor {
    let function: HUDFunction
    let applySideEffect: (Float) -> Void
    let iconNameForValue: (Float) -> String
}

/// Convenience alias: mapping from HID command → descriptor
typealias CommandRegistry = [QMKBridgeCommand: ControlDescriptor]
