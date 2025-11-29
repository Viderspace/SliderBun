//
//  QMKBridgeRegistryFactory.swift
//  QMKBridge
//
//  Created by Jonatan Vider on 27/11/2025.
//

// QMKBridgeRegistryFactory.swift

import Foundation

struct CommandRegistryFactory {

    static func makeRegistry(
        volumeService: VolumeControlling,
        brightnessService: BrightnessControlling,
        shortcutHandler: SliderShortcutHandling
    ) -> CommandRegistry {

        return [
            .setVolume: VolumeControlDescriptor.make(volumeService: volumeService),

            .setBrightness: BrightnessControlDescriptor.make(
                brightnessService: brightnessService
            ),

            .shortcut1: ShortcutControlDescriptor.make(
                slotIndex: 0,
                displayIndex: 1,
                shortcutHandler: shortcutHandler
            ),

            .shortcut2: ShortcutControlDescriptor.make(
                slotIndex: 1,
                displayIndex: 2,
                shortcutHandler: shortcutHandler
            ),

            .shortcut3: ShortcutControlDescriptor.make(
                slotIndex: 2,
                displayIndex: 3,
                shortcutHandler: shortcutHandler
            ),

            .shortcut4: ShortcutControlDescriptor.make(
                slotIndex: 3,
                displayIndex: 4,
                shortcutHandler: shortcutHandler
            )
        ]
    }
}



private enum VolumeControlDescriptor {
    static func make(volumeService: VolumeControlling) -> ControlDescriptor {
        func iconName(for value: Float) -> String {
            let clamped = max(0, min(1, value))
            if clamped <= 0.001 {
                return "speaker.slash.fill"
            } else if clamped < 0.3 {
                return "speaker.wave.1.fill"
            } else if clamped < 0.7 {
                return "speaker.wave.2.fill"
            } else {
                return "speaker.wave.3.fill"
            }
        }

        return ControlDescriptor(
            function: .volume,
            applySideEffect: { value in
                volumeService.setVolume(normalized: value)
            },
            iconNameForValue: iconName(for:)
        )
    }
}

private enum BrightnessControlDescriptor {
    static func make(brightnessService: BrightnessControlling) -> ControlDescriptor {
        func iconName(for value: Float) -> String {
            let clamped = max(0, min(1, value))
            // Simple example: two-state brightness
            return clamped < 0.5 ? "sun.min.fill" : "sun.max.fill"
        }

        return ControlDescriptor(
            function: .brightness,
            applySideEffect: { value in
                brightnessService.setBrightness(normalized: value)
            },
            iconNameForValue: iconName(for:)
        )
    }
}

private enum ShortcutControlDescriptor {
    /// slotIndex: 0-based slot used by the service
    /// displayIndex: 1-based index for HUDFunction.shortcut(...)
    static func make(
        slotIndex: Int,
        displayIndex: Int,
        shortcutHandler: SliderShortcutHandling
    ) -> ControlDescriptor {

        func iconName(for _: Float) -> String {
            switch displayIndex {
            case 1: return "1.circle.fill"
            case 2: return "2.circle.fill"
            case 3: return "3.circle.fill"
            case 4: return "4.circle.fill"
            default: return "questionmark.circle.fill"
            }
        }

        return ControlDescriptor(
            function: .shortcut(displayIndex),
            applySideEffect: { value in
                shortcutHandler.handleShortcut(slotIndex, normalized: value)
            },
            iconNameForValue: iconName(for:)
        )
    }
}
