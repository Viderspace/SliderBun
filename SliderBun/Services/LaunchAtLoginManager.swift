//
//  LaunchAtLoginManager.swift.swift
//  QMKBridge
//
//  Created by Jonatan Vider on 28/11/2025.
//
import Foundation
import ServiceManagement


///Communicating with MacOS's system settings to set this app with  'open at login' ability
enum LaunchAtLoginManager {

    static var isEnabled: Bool {
        get {
            let status = SMAppService.mainApp.status
            // Treat both enabled and requiresApproval as "on"
            switch status {
            case .enabled, .requiresApproval:
                return true
            case .notRegistered:
                return false
            default:
                // Future-proof fallback
                return false
            }
        }
        set {
            if newValue {
                do {
                    try SMAppService.mainApp.register()
                } catch {
                    print("[LaunchAtLogin] Failed to register: \(error)")
                }
            } else {
                do {
                    try SMAppService.mainApp.unregister()
                } catch {
                    print("[LaunchAtLogin] Failed to unregister: \(error)")
                }
            }
        }
    }
}
