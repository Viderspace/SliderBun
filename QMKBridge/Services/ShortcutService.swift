import Foundation

/// Handles slider-driven shortcut actions.
/// slot: 0 = Shortcut1, 1 = Shortcut2, 2 = Shortcut3, 3 = Shortcut4
protocol SliderShortcutHandling {
    func handleShortcut(_ slot: Int, normalized: Float)
}

final class ShortcutService: SliderShortcutHandling {

    /// Minimum time between invocations per slot (seconds)
    private let minInterval: TimeInterval = 0.25

    /// Last fire time per slot
    private var lastFireDates: [Int: Date] = [:]

    /// Serial queue to keep state mutations safe and off the main thread
    private let queue = DispatchQueue(label: "QMKBridge.ShortcutService")

    func handleShortcut(_ slot: Int, normalized: Float) {
        queue.async { [weak self] in
            guard let self else { return }

            let now  = Date()
            let last = self.lastFireDates[slot] ?? .distantPast

            // Debounce: ignore events within minInterval
            guard now.timeIntervalSince(last) >= self.minInterval else {
                return
            }

            self.lastFireDates[slot] = now
            self.runShortcut(slot: slot, normalized: normalized)
        }
    }

    // MARK: - Private helpers

    private func runShortcut(slot: Int, normalized: Float) {
        let clamped = max(0.0, min(1.0, Double(normalized)))
        let valueString = String(format: "%.3f", clamped)

        let name = shortcutName(for: slot)
        print("[ShortcutService] slot \(slot) → \(valueString) → '\(name)'")

        guard let inputFileURL = writeTempInputFile(slot: slot, valueString: valueString) else {
            print("[ShortcutService] Failed to write temp input file for slot \(slot)")
            return
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/shortcuts")
        process.arguments = [
            "run",
            name,
            "-i",
            inputFileURL.path
        ]

        do {
            try process.run()
            // Fire-and-forget (Best effort)
        } catch {
            print("[ShortcutService] Failed to run shortcut '\(name)': \(error)")
        }
    }

    private func shortcutName(for slot: Int) -> String {
        // hard-coded mapping - Worth a better solution
        switch slot {
        case 0: return "SliderBun1"
        case 1: return "SliderBun2"
        case 2: return "SliderBun3"
        case 3: return "SliderBun4"
        default: return "SliderBun\(slot + 1)"
        }
    }

    private func writeTempInputFile(slot: Int, valueString: String) -> URL? {
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let url = tempDir.appendingPathComponent("qmk_slider_\(slot + 1).txt")

        do {
            try valueString.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            print("[ShortcutService] Error writing temp file: \(error)")
            return nil
        }
    }
}

