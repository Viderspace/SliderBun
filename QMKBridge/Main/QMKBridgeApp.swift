import SwiftUI

@main
struct QMKBridgeApp: App {
    private let uiState = QMKBridgeUIState()

    private let hidBridge: HIDBridge
    private let engine: QMKBridgeEngine
    private let statusItemController: StatusItemController

    init() {
        let volumeService     = CoreAudioVolumeService()
        let brightnessService = BrightnessService()
        let shortcutHandler   = ShortcutService()

        let uiState = self.uiState
        let storedShowHUD = UserDefaults.standard.object(forKey: "showHUDOnEvents") as? Bool ?? true
        uiState.showHUDOnEvents = storedShowHUD

        let statusItemController = StatusItemController(uiState: uiState)
        self.statusItemController = statusItemController

        let registry = QMKBridgeRegistryFactory.makeRegistry(
            volumeService: volumeService,
            brightnessService: brightnessService,
            shortcutHandler: shortcutHandler
        )

        self.engine = QMKBridgeEngine(
            registry: registry,
            uiState: uiState,
            statusItemController: statusItemController
        )

        let bridge = HIDBridge()
        bridge.listener = engine
        self.hidBridge = bridge
    }

    var body: some Scene {
        // No main window – this is a menu-bar–only utility.
        Settings {
            EmptyView()
        }
    }
}
