//
//  QMKBridgeProtocol.swift
//  QMKBridge
//
//  Created by Jonatan Vider on 25/11/2025.
//

import Foundation

/// The identity of the custom RAW HID interface used by the QMKBridge system.
/// Both QMK firmware and the macOS helper app must use these values.
enum QMKBridgeProtocol {
    /// Vendor-defined HID usage page selected for this project.
    /// 0xFF69 is unused by all known ecosystems and safe for long-term use.
    static let usagePage: Int = 0xFF69

    /// HID usage ID that identifies the specific endpoint inside the usage page.
    /// 0x10 is chosen as "Channel 10" for future extensibility.
    static let usageID: Int = 0x10
}

enum QMKBridgeCommand: UInt8 {
    case setVolume     = 0x01
    case setBrightness = 0x02

    case shortcut1     = 0x10
    case shortcut2     = 0x11
    case shortcut3     = 0x12
    case shortcut4     = 0x13
}


struct QMKBridgeMessage {
    let command: QMKBridgeCommand?
    let rawU16: UInt16
    let normalized: Float
    let length: Int
}

protocol QMKBridgeListener: AnyObject {
    func didReceive(_ message: QMKBridgeMessage)
}
