//
//  SettingsView..swift
//  QMKBridge
//
//  Created by Jonatan Vider on 28/11/2025.
//
import SwiftUI

struct SettingsView: View {
    @Bindable var uiState: AppUIState

    @AppStorage("showHUDOnEvents") private var showHUDOnEventsStored: Bool = true

    @State private var launchAtLoginEnabled: Bool = LaunchAtLoginManager.isEnabled


    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.headline)

            Toggle("Show HUD when slider moves", isOn: Binding(
                get: { showHUDOnEventsStored },
                set: { newValue in
                    showHUDOnEventsStored = newValue
                    uiState.showHUDOnEvents = newValue
                }
            ))

            Toggle("Open at login", isOn: $launchAtLoginEnabled)
                .onChange(of: launchAtLoginEnabled) {
                    LaunchAtLoginManager.isEnabled = launchAtLoginEnabled
                }

            Spacer()

               // Footer
               Divider()

               HStack {
                   Text("© 2025 Jonatan Vider. All rights reserved.")
                       .font(.caption2)
                       .foregroundStyle(.secondary
                       )
                   Spacer()

                   if let url = URL(string: "mailto:viderspace@gmail.com") {
                       Link("Contact", destination: url)
                           .font(.caption2)
                   }
               }
           }
        .padding(16)
        .frame(width: 350, height: 170)
        .onAppear {
            uiState.showHUDOnEvents = showHUDOnEventsStored
            launchAtLoginEnabled = LaunchAtLoginManager.isEnabled // resync on reopen
        }
    }
}
