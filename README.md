# SliderBun

SliderBun is a small macOS utility that connects a QMK-controlled analog slider to system functions such as volume, brightness, or user-defined shortcuts.  
It is intended for users who prefer physical input devices over software controls.

---

## Overview

When running, SliderBun resides in the macOS menu bar and listens for input from a QMK device implementing a simple HID protocol.  
Upon receiving a normalized value (0.0–1.0), it applies the configured action and optionally displays a minimal on-screen indicator.

Typical use cases:
- Hardware volume control  
- Hardware display brightness control  
- Triggering macOS Shortcuts

A demonstration QMK firmware is provided separately.

*(screenshot placeholder)*  
`![HUD](docs/hud_placeholder.png)`

---

## Installation

1. Download the current release (`.dmg`).  
2. Open the disk image and drag `SliderBun.app` into `Applications`.  
3. Launch the application.  
4. If desired, enable “Launch at Login” from the Settings window.

No additional system extensions or drivers are required.

*(dmg layout screenshot placeholder)*  
`![DMG](docs/dmg_placeholder.png)`

---

## Operation

After launch, a small icon appears in the menu bar.  
Moving the hardware slider sends events through QMK; the application translates these into macOS actions.

A small window with two controls is available:
- show HUD on input  
- launch at login  

Behavior is immediate and does not require relaunching.

*(settings screenshot placeholder)*  
`![Settings](docs/settings_placeholder.png)`

---

## QMK Firmware

SliderBun depends on a matching QMK implementation that reports slider values through a simple normalized HID field.  
A reference implementation is available here:

https://github.com/yourname/yourqmkrepo (placeholder)

The QMK side is intentionally small and easy to adapt to other keyboards or analog inputs.  
Any board capable of reading an ADC value can be supported.

---

## Shortcuts

The disk image includes a `Shortcuts Demo` directory containing four example macOS Shortcuts named:

- `SliderBun1`  
- `SliderBun2`  
- `SliderBun3`  
- `SliderBun4`

These serve as placeholders for custom automation.

---

## Requirements

- macOS 14.0 or newer  
- A QMK-compatible device with an analog input  
- The accompanying firmware described above

---

## Notes

SliderBun is intended to be simple, transparent, and predictable.  
It does not attempt to manage more than one slider, map multiple devices, or perform device discovery.  
The application does not collect data and does not communicate externally.

---

## License

The macOS application is released under the MIT license.  
The QMK code follows the licensing requirements of QMK (GPL-2.0).

Bug reports and contributions are welcome.