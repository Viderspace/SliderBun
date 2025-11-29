import SwiftUI

@main
struct SliderBunApp: App {
    private let uiState = AppUIState()

    private let hidBridge: HIDBridge
    private let engine: SliderBunEngine
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

        let registry = CommandRegistryFactory.makeRegistry(
            volumeService: volumeService,
            brightnessService: brightnessService,
            shortcutHandler: shortcutHandler
        )

        self.engine = SliderBunEngine(
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
