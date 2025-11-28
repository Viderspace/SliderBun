//
//  HUDView.swift
//  QMKBridge
//
//  Created by Jonatan Vider on 27/11/2025.
//
import SwiftUI

struct HUDView: View {
    @Bindable var uiState: QMKBridgeUIState

    var body: some View {
        HStack(spacing: 10) {

            Image(systemName: uiState.hudIconName)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.primary, .secondary)
                .font(.system(size: 13))
                .frame(width: 20, alignment: .leading)

            // FIXED-WIDTH BAR
            HUDBar(value: CGFloat(uiState.hudValue))
                .frame(width: 160, height: 16)

            Text(valueLabel)
                .font(.caption2)
                .monospacedDigit()
                .frame(width: 40, alignment: .trailing)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .frame(width: 260, height: 40)
    }

    private var valueLabel: String {
        let clamped = max(0, min(1, uiState.hudValue))
        switch uiState.hudFunction {
        case .volume, .brightness:
            return "\(Int(clamped * 100))%"
        case .shortcut(let index):
            // Simple label for now: "S1", "S2", ...
            return "S\(index)"
        }
    }
}
/// A non-interactive, smooth volume bar
struct HUDBar: View {
    let value: CGFloat // 0 ... 1

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let knobX = max(10, min(w - 10, 10 + value * (w - 20)))

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.25))

                Capsule()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: knobX)

                Circle()
                    .fill(Color.white)
                    .shadow(radius: 1)
                    .overlay(
                        Circle()
                            .stroke(Color.accentColor, lineWidth: 1)
                    )
                    .frame(width: 14, height: 14)
                    .position(x: knobX, y: h / 2)
            }
        }
        .frame(height: 16)
    }
}
