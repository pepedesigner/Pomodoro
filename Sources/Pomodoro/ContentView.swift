import AppKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: TimerModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var showSettings = false
    @State private var window: NSWindow?

    var body: some View {
        ZStack {
            background

            VStack(spacing: 20) {
                header
                Spacer(minLength: 0)
                ring
                Spacer(minLength: 0)
                controls
                footer
            }
            .padding(.horizontal, 28)
            .padding(.top, 16)
            .padding(.bottom, 22)
        }
        .frame(width: 360, height: 500)
        .background(WindowAccessor { win in
            window = win
            hideStandardWindowButtons(win)
        })
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(model)
        }
        .onAppear { runSelfTestIfRequested() }
    }

    // TEMPORARY self-test: only runs with --test-close launch argument.
    private func runSelfTestIfRequested() {
        guard ProcessInfo.processInfo.arguments.contains("--test-close") else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            guard let window else {
                print("SELFTEST FAIL: window not captured")
                return
            }
            print("SELFTEST window captured: true, visible before close: \(window.isVisible)")

            if let contentView = window.contentView {
                let bounds = contentView.bounds
                if let rep = contentView.bitmapImageRepForCachingDisplay(in: bounds) {
                    contentView.cacheDisplay(in: bounds, to: rep)
                    if let data = rep.representation(using: .png, properties: [:]) {
                        try? data.write(to: URL(fileURLWithPath: "/tmp/pomodoro_ui.png"))
                        print("SELFTEST UI snapshot written")
                    }
                }
            }

            window.close()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                print("SELFTEST visible after close: \(window.isVisible), app alive")
            }
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [
                model.modeColor.opacity(colorScheme == .dark ? 0.30 : 0.16),
                Color(nsColor: .windowBackgroundColor),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack(spacing: 12) {
            Picker(
                "Mode",
                selection: Binding(
                    get: { model.mode },
                    set: { model.switchMode($0) }
                )
            ) {
                ForEach(TimerMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: .infinity)

            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(Color.primary.opacity(0.08)))
            }
            .buttonStyle(.plain)
            .help("Settings")

            Button {
                window?.close()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(Color.primary.opacity(0.08)))
            }
            .buttonStyle(.plain)
            .help("Close window (⌘W)")
            .keyboardShortcut("w", modifiers: .command)
        }
    }

    private var ring: some View {
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.08), lineWidth: 14)

            Circle()
                .trim(from: 0, to: model.fraction)
                .stroke(
                    model.modeColor,
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.9), value: model.remaining)

            VStack(spacing: 6) {
                Text(model.timeString)
                    .font(.system(size: 62, weight: .thin, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.default, value: model.remaining)

                Label(model.mode.title, systemImage: model.mode.symbol)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 250, height: 250)
    }

    private var controls: some View {
        HStack(spacing: 44) {
            roundIconButton("arrow.counterclockwise", help: "Reset") {
                model.reset()
            }

            Button {
                model.toggle()
            } label: {
                Image(systemName: model.isRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 72, height: 72)
                    .background(Circle().fill(model.modeColor))
                    .shadow(color: model.modeColor.opacity(0.45), radius: 10, y: 5)
            }
            .buttonStyle(.plain)
            .help(model.isRunning ? "Pause" : "Start")

            roundIconButton("forward.end.fill", help: "Skip") {
                model.skip()
            }
        }
    }

    private func roundIconButton(
        _ symbol: String,
        help: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 48, height: 48)
                .background(Circle().fill(Color.primary.opacity(0.08)))
        }
        .buttonStyle(.plain)
        .help(help)
    }

    private var footer: some View {
        Label("\(model.completedFocusSessions) completed today", systemImage: "checkmark.circle.fill")
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}
