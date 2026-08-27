import AppKit
import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var model: TimerModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(model.timeString, systemImage: model.mode.symbol)
                .font(.headline)
                .padding(.bottom, 4)

            Button("Show Timer") { openWindow(id: "main") }
            Button(model.isRunning ? "Pause" : "Resume") { model.toggle() }
            Button("Reset") { model.reset() }
            Button("Skip") { model.skip() }

            Divider()

            Button("Quit Pomodoro") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(4)
    }
}
