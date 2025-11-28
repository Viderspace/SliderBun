import Foundation
import CoreAudio
import AudioToolbox

protocol VolumeControlling {
    /// normalized in 0.0 ... 1.0
    func setVolume(normalized: Float)
}

final class CoreAudioVolumeService: VolumeControlling {

    // MARK: - State for throttling

    /// Last volume we actually sent to CoreAudio (0..1), or -1 if none yet
    private var lastVolume: Float = -1.0

    /// Last mute state we applied
    private var lastMute: Bool = false

    /// Minimum change in *shaped* volume (0..1) to update, e.g. 0.01 = 1%
    private let minDelta: Float = 0.01

    /// Threshold on the *raw* input below which we treat as "mute"
    private let muteThreshold: Float = 0.001

    /// Gamma for perceptual curve (<1 = more resolution at low volumes)
    private let gamma: Float = 1.3

    // MARK: - Public API

    func setVolume(normalized: Float) {
        let raw = clamp01(normalized)
        let targetMute = raw <= muteThreshold

        // If we're muting, shaped volume is always 0
        let shaped: Float = targetMute ? 0.0 : applyVolumeCurve(raw)

        // Throttle tiny changes when not muting
        if !targetMute, lastVolume >= 0.0 {
            if abs(shaped - lastVolume) < minDelta {
                return
            }
        }

        guard let deviceID = defaultOutputDeviceID() else {
            print("[Volume] No default output device")
            return
        }

        if targetMute {
            applyMute(on: deviceID)
        } else {
            applyUnmuteAndVolume(shaped, on: deviceID)
        }

        // Update state
        lastVolume = shaped
        lastMute   = targetMute
    }

    // MARK: - Curve

    /// Apply a perceptual curve so 0..1 feels nicer under the fingers.
    private func applyVolumeCurve(_ x: Float) -> Float {
        let clamped = clamp01(x)
        // gamma < 1.0 → more resolution in the low end
        return powf(clamped, gamma)
    }

    // MARK: - High-level helpers

    private func applyMute(on deviceID: AudioObjectID) {
        if !lastMute {
            setVolumeScalar(0.0, on: deviceID)
            setMute(true, on: deviceID)
            logVolumeUpdate(0.0, muted: true)
        }
    }

    private func applyUnmuteAndVolume(_ volume: Float, on deviceID: AudioObjectID) {
        if lastMute {
            setMute(false, on: deviceID)
        }
        setVolumeScalar(volume, on: deviceID)
        logVolumeUpdate(volume, muted: false)
    }

    private func logVolumeUpdate(_ volume: Float, muted: Bool) {
        let pct = Int((volume * 100).rounded())
        if muted {
            print("[Volume] → MUTED (vol=\(pct)%)")
        } else {
            print("[Volume] → \(pct)%")
        }
    }

    // MARK: - CoreAudio helpers

    private func clamp01(_ value: Float) -> Float {
        return max(0.0, min(1.0, value))
    }

    private func defaultOutputDeviceID() -> AudioObjectID? {
        var deviceID = AudioObjectID(0)
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var size = UInt32(MemoryLayout.size(ofValue: deviceID))

        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &size,
            &deviceID
        )

        if status != noErr {
            print("[Volume] Failed to get default output device, status=\(status)")
            return nil
        }
        return deviceID
    }

    private func setMute(_ mute: Bool, on deviceID: AudioObjectID) {
        var muteValue: UInt32 = mute ? 1 : 0

        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        let size = UInt32(MemoryLayout.size(ofValue: muteValue))

        let status = AudioObjectSetPropertyData(
            deviceID,
            &address,
            0,
            nil,
            size,
            &muteValue
        )

        if status != noErr {
            print("[Volume] Failed to set mute=\(mute) status=\(status)")
        }
    }

    private func setVolumeScalar(_ volume: Float, on deviceID: AudioObjectID) {
        var vol = volume
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        let size = UInt32(MemoryLayout.size(ofValue: vol))

        let status = AudioObjectSetPropertyData(
            deviceID,
            &address,
            0,
            nil,
            size,
            &vol
        )

        if status != noErr {
            print("[Volume] Failed to set volume, status=\(status)")
        }
    }
}
