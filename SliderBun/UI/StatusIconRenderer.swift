//
//  StatusIconRenderer.swift
//  QMKBridge
//
//  Created by Jonatan Vider on 28/11/2025.
//

import Foundation
import AppKit

struct StatusIconRenderer {
    let canvasSize: NSSize

    func image(named name: String) -> NSImage? {
        guard let baseImage = NSImage(named: name) else { return nil }

        let canvas = NSImage(size: canvasSize)
        canvas.lockFocus()

        NSColor.clear.set()
        NSBezierPath(rect: NSRect(origin: .zero, size: canvasSize)).fill()

        let targetHeight = canvasSize.height
        let scale = targetHeight / baseImage.size.height
        let targetWidth = baseImage.size.width * scale

        let targetRect = NSRect(
            x: 0,
            y: 0,
            width: targetWidth,
            height: targetHeight
        )

        baseImage.draw(
            in: targetRect,
            from: .zero,
            operation: .sourceOver,
            fraction: 1.0,
            respectFlipped: true,
            hints: nil
        )

        canvas.unlockFocus()
        canvas.isTemplate = true

        return canvas
    }

    func systemImage(named systemName: String) -> NSImage? {
        guard let symbol = NSImage(
            systemSymbolName: systemName,
            accessibilityDescription: nil
        ) else {
            return nil
        }

        let canvas = NSImage(size: canvasSize)
        canvas.lockFocus()

        NSColor.clear.set()
        NSBezierPath(rect: NSRect(origin: .zero, size: canvasSize)).fill()

        let targetHeight = canvasSize.height
        let scale = targetHeight / symbol.size.height
        let targetWidth = symbol.size.width * scale

        let targetRect = NSRect(
            x: 0,
            y: 0,
            width: targetWidth,
            height: targetHeight
        )

        symbol.draw(
            in: targetRect,
            from: .zero,
            operation: .sourceOver,
            fraction: 1.0,
            respectFlipped: true,
            hints: nil
        )

        canvas.unlockFocus()
        canvas.isTemplate = true

        return canvas
    }
}
