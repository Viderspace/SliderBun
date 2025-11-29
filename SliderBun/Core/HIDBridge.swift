//
//  HIDBridge.swift
//  QMKBridge
//
//  Created by Jonatan Vider on 25/11/2025.
//

import Foundation
import IOKit.hid

// MARK: - HIDBridge

final class HIDBridge {

    // Exposed as fileprivate so the callbacks can reach them.
    fileprivate let maxReportLength: Int = 32
    fileprivate let reportBuffer: UnsafeMutablePointer<UInt8>
    fileprivate let manager: IOHIDManager

    weak var listener: SliderEventListener?

    init() {
        print("[HIDBridge] init")

        reportBuffer = Self.makeReportBuffer(length: maxReportLength)
        manager      = Self.makeManager()

        configureMatching()
        registerCallbacks()
        scheduleOnRunLoop()
        openManager()
    }

    deinit {
        print("[HIDBridge] deinit")
        tearDownRunLoop()
        IOHIDManagerClose(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        reportBuffer.deallocate()
    }
}

// MARK: - Setup helpers

private extension HIDBridge {

    static func makeReportBuffer(length: Int) -> UnsafeMutablePointer<UInt8> {
        .allocate(capacity: length)
    }

    static func makeManager() -> IOHIDManager {
        IOHIDManagerCreate(
            kCFAllocatorDefault,
            IOOptionBits(kIOHIDOptionsTypeNone)
        )
    }

    func configureMatching() {
        IOHIDManagerSetDeviceMatching(manager, matchingDictionary as CFDictionary)
    }

    var matchingDictionary: [String: Any] {
        [
            kIOHIDDeviceUsagePageKey as String: BridgeProtocol.usagePage,
            kIOHIDDeviceUsageKey as String:      BridgeProtocol.usageID
        ]
    }

    func registerCallbacks() {
        let ctx = opaqueContext
        IOHIDManagerRegisterDeviceMatchingCallback(
            manager,
            deviceMatchedCallback,
            ctx
        )
    }

    func scheduleOnRunLoop() {
        IOHIDManagerScheduleWithRunLoop(
            manager,
            CFRunLoopGetCurrent(),
            CFRunLoopMode.defaultMode.rawValue
        )
    }

    func openManager() {
        let result = IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        logOpenResult(result)
    }

    func tearDownRunLoop() {
        IOHIDManagerUnscheduleFromRunLoop(
            manager,
            CFRunLoopGetCurrent(),
            CFRunLoopMode.defaultMode.rawValue
        )
    }

    var opaqueContext: UnsafeMutableRawPointer {
        UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
    }

    func logOpenResult(_ result: IOReturn) {
        if result == kIOReturnSuccess {
            print("[HIDBridge] IOHIDManager opened successfully")
        } else {
            print("[HIDBridge] IOHIDManagerOpen failed with code \(result)")
        }
    }
}

// MARK: - Instance-level event handling

extension HIDBridge {

    func handleDeviceMatched(_ device: IOHIDDevice) {
        print("[HIDBridge] device matched")
        registerInputReportCallback(for: device)
    }


    func handleReport(
        reportID: UInt32,
        bytes: UnsafeMutablePointer<UInt8>,
        length: Int
    ) {
        guard length >= 4 else { return }

        let cmd        = parseCommand(bytes: bytes)
        let rawU16     = readU16LE(from: bytes, offset: 2)
        let normalized = normalizeU16(rawU16)
//        let percent    = normalizedToPercent(normalized)

        let message = SliderEventMessage(
            command: cmd,
            rawU16: rawU16,
            normalized: normalized,
            length: length
        )

        // 1) Notify any listener (future QMKBridgeEngine, etc.)
        listener?.didReceive(message)
    }


    private func parseCommand(
        bytes: UnsafeMutablePointer<UInt8>
    ) -> HIDBridgeCommand? {
        let rawCmd = bytes[0]
        return HIDBridgeCommand(rawValue: rawCmd)
    }
    private func readU16LE(
        from bytes: UnsafeMutablePointer<UInt8>,
        offset: Int
    ) -> UInt16 {
        let lo = UInt16(bytes[offset])
        let hi = UInt16(bytes[offset + 1]) << 8
        return lo | hi
    }

    private func normalizeU16(_ value: UInt16) -> Float {
        return Float(value) / 65535.0
    }

    private func normalizedToPercent(_ normalized: Float) -> Int {
        let clamped = max(0.0, min(1.0, normalized))
        return Int((clamped * 100.0).rounded())
    }

    private func logReportSummary(
        id: UInt32,
        cmd: HIDBridgeCommand?,
        rawU16: UInt16,
        normalized: Float,
        percent: Int,
        length: Int
    ) {
        let cmdDescription = cmd.map { "\($0)" } ?? "unknown"
        let normStr = String(format: "%.3f", normalized)
        print("[HIDBridge] reportID=\(id) len=\(length) cmd=\(cmdDescription) raw=\(rawU16) norm=\(normStr) percent=\(percent)")
    }


    private func registerInputReportCallback(for device: IOHIDDevice) {
        IOHIDDeviceRegisterInputReportCallback(
            device,
            reportBuffer,
            maxReportLength,
            inputReportCallback,
            opaqueContext
        )
    }



    private func logReportDump(
        bytes: UnsafeMutablePointer<UInt8>,
        length: Int
    ) {
        var dump = "[HIDBridge] raw:"
        for i in 0..<length {
            dump += String(format: " %02X", bytes[i])
        }
        print(dump)
    }
}

// MARK: C-style callbacks (thin shims)

private func deviceMatchedCallback(
    context: UnsafeMutableRawPointer?,
    result: IOReturn,
    sender: UnsafeMutableRawPointer?,
    device: IOHIDDevice
) {
    bridge(from: context)?.handleDeviceMatched(device)
}


private func inputReportCallback(
    context: UnsafeMutableRawPointer?,
    result: IOReturn,
    sender: UnsafeMutableRawPointer?,
    type: IOHIDReportType,
    reportID: UInt32,
    report: UnsafeMutablePointer<UInt8>,
    reportLength: CFIndex
) {
    bridge(from: context)?.handleReport(
        reportID: reportID,
        bytes: report,
        length: reportLength
    )
}

// MARK:  Context → bridge helper

private func bridge(from context: UnsafeMutableRawPointer?) -> HIDBridge? {
    guard let context else { return nil }
    return Unmanaged<HIDBridge>.fromOpaque(context).takeUnretainedValue()
}
