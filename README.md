# SliderBun
Minimal macOS utility for controlling **volume**, **brightness**, and **Shortcuts actions** using a **QMK-based hardware slider**.

No installers, no background daemons, no BS.  
Just a single menu-bar app that reacts to RAW HID reports.

---

## Features
- System volume control  
- Built-in display brightness control  
- 4 assignable macOS Shortcuts (`SliderBun1`…`SliderBun4`)  
- Simple HUD (icon + slider + value)  
- Menu-bar icon updates based on the active control  
- “Launch at Login” support  
- macOS 14+ (Sonoma and up)

---

## Installation
1. Download the latest release from **Releases**.  
2. Open the `.dmg`.  
3. Drag `SliderBun.app` into `/Applications`.  
4. Run it. The app lives in the menu bar.  
5. Open Settings via menu-bar icon.

No configuration files. Nothing persistent except your two preferences.

---

## QMK Protocol
SliderBun listens for RAW HID packets of the form:

```
[0] = command (UInt8)
[1] = reserved
[2] = value LSB (UInt8)
[3] = value MSB (UInt8)
```

Where `value` is a 16-bit analog reading normalized to 0.0–1.0.

Supported commands:

```
0x01  setVolume
0x02  setBrightness
0x10  shortcut1
0x11  shortcut2
0x12  shortcut3
0x13  shortcut4
```

A ready-to-use QMK reference implementation will be provided in this repository.

---

## Shortcuts Integration
Each shortcut slot (`SliderBun1`...`SliderBun4`) is triggered when its command is received.  
SliderBun writes the slider value to a temp file and invokes the Shortcut via the system `shortcuts` CLI.

Shortcuts can read the file or use "Shortcut Input".

A `Shortcuts Demo/` folder is included in the DMG.

---

## Settings
- **Show HUD**: enables/disables the on-screen HUD  
- **Launch at Login**: managed via `SMAppService`  
Settings stay minimal by design.

---

## Notes
- Brightness is controlled using undocumented `DisplayServices` APIs (same technique used by MonitorControl).  
- SliderBun never transmits, collects, or stores user data.  
- No licensing yet (all rights reserved). May change later.

---

## About
SliderBun is intentionally small and handcrafted.  
It doesn’t attempt to be an ecosystem, a platform, or a product.  
It’s a utility — like they used to make them.

PRs and forks welcome once the project stabilizes.