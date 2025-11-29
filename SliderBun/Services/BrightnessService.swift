//
//  BrightnessService.swift
//  QMKBridge
//
//  Created by Jonatan Vider on 26/11/2025.
//

import Foundation
import CoreGraphics

protocol BrightnessControlling {
    func setBrightness(normalized: Float)
}

struct BrightnessService: BrightnessControlling {

    func setBrightness(normalized: Float) {
        let clamped = max(0.0, min(1.0, normalized))
        let mainDisplay = CGMainDisplayID()
        BrightnessShim_Set(mainDisplay, Double(clamped))
    }

    // Optional helper
    func currentBrightness() -> Float {
        let mainDisplay = CGMainDisplayID()
        let v = BrightnessShim_Get(mainDisplay)
        guard v >= 0 else { return 0 }
        return max(0, min(1, Float(v)))
    }
}
