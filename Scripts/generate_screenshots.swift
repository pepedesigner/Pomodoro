import AppKit
import SwiftUI

enum PreviewMode: String, CaseIterable, Identifiable {
    case focus = "Focus"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .focus: "brain.head.profile"
        case .shortBreak: "cup.and.saucer.fill"
        case .longBreak: "moon.zzz.fill"
        }
    }

    var color: Color {
        switch self {
        case .focus: Color(red: 0.93, green: 0.30, blue: 0.24)
        case .shortBreak: Color(red: 0.21, green: 0.67, blue: 0.46)
        case .longBreak: Color(red: 0.25, green: 0.52, blue: 0.89)
        }
    }
}

struct SnapshotMainView: View {
    var mode: PreviewMode = .focus
    var timeString: String = "25:00"
    var fraction: Double = 1.0
    var isRunning: Bool = false
    var completed: Int = 4
    var isDarkMode: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    mode.color.opacity(isDarkMode ? 0.30 : 0.16),
                    isDarkMode ? Color(red: 0.12, green: 0.12, blue: 0.13) : Color(red: 0.96, green: 0.96, blue: 0.97),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                HStack(spacing: 12) {
                    HStack(spacing: 0) {
                        ForEach(PreviewMode.allCases) { m in
                            Text(m.rawValue)
                                .font(.system(size: 12, weight: m == mode ? .semibold : .regular))
                                .foregroundStyle(m == mode ? Color.primary : Color.secondary)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(m == mode ? (isDarkMode ? Color.white.opacity(0.18) : Color.white) : Color.clear)
                                        .shadow(color: m == mode ? Color.black.opacity(0.08) : Color.clear, radius: 2, y: 1)
                                )
                        }
                    }
                    .padding(3)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.primary.opacity(0.06)))
                    .frame(maxWidth: .infinity)

                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Color.primary.opacity(0.08)))

                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Color.primary.opacity(0.08)))
                }

                Spacer(minLength: 0)

                // Ring
                ZStack {
                    Circle()
                        .stroke(Color.primary.opacity(0.08), lineWidth: 14)

                    Circle()
                        .trim(from: 0, to: CGFloat(fraction))
                        .stroke(
                            mode.color,
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 6) {
                        Text(timeString)
                            .font(.system(size: 62, weight: .thin, design: .rounded))
                            .monospacedDigit()

                        Label(mode.rawValue, systemImage: mode.symbol)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 250, height: 250)

                Spacer(minLength: 0)

                // Controls
                HStack(spacing: 44) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 48, height: 48)
                        .background(Circle().fill(Color.primary.opacity(0.08)))

                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 72, height: 72)
                        .background(Circle().fill(mode.color))
                        .shadow(color: mode.color.opacity(0.45), radius: 10, y: 5)

                    Image(systemName: "forward.end.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 48, height: 48)
                        .background(Circle().fill(Color.primary.opacity(0.08)))
                }

                // Footer
                Label("\(completed) completed today", systemImage: "checkmark.circle.fill")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 28)
            .padding(.top, 16)
            .padding(.bottom, 22)
        }
        .frame(width: 360, height: 500)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
        )
    }
}

struct SnapshotSettingsView: View {
    var isDarkMode: Bool = false

    var body: some View {
        ZStack {
            (isDarkMode ? Color(red: 0.14, green: 0.14, blue: 0.15) : Color(red: 0.95, green: 0.95, blue: 0.96))
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text("Settings")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 18))
                }

                VStack(spacing: 12) {
                    settingRow("Focus duration", value: "25 min")
                    settingRow("Short break", value: "5 min")
                    settingRow("Long break", value: "15 min")
                    settingRow("Long break interval", value: "Every 4 sessions")
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 10).fill(isDarkMode ? Color.white.opacity(0.06) : Color.white))

                VStack(spacing: 12) {
                    toggleRow("Auto-start breaks", isOn: false)
                    toggleRow("Auto-start focus", isOn: false)
                    toggleRow("Play sound on complete", isOn: true)
                    toggleRow("Show system notifications", isOn: true)
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 10).fill(isDarkMode ? Color.white.opacity(0.06) : Color.white))

                Spacer()

                HStack {
                    Spacer()
                    Text("Pomodoro v1.0 • Made with SwiftUI for macOS")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
            .padding(22)
        }
        .frame(width: 360, height: 500)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
        )
    }

    private func settingRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }

    private func toggleRow(_ label: String, isOn: Bool) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
            Spacer()
            Toggle("", isOn: .constant(isOn))
                .toggleStyle(.switch)
                .labelsHidden()
                .controlSize(.small)
        }
    }
}

func renderView<V: View>(_ view: V, size: CGSize) -> NSImage {
    let hostingView = NSHostingView(rootView: view)
    hostingView.frame = NSRect(origin: .zero, size: size)

    let rep = hostingView.bitmapImageRepForCachingDisplay(in: hostingView.bounds)!
    rep.size = size
    hostingView.cacheDisplay(in: hostingView.bounds, to: rep)

    let image = NSImage(size: size)
    image.addRepresentation(rep)
    return image
}

func savePNG(_ image: NSImage, to path: String) {
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else {
        print("Failed to encode PNG for \(path)")
        return
    }
    try? png.write(to: URL(fileURLWithPath: path))
    print("Saved \(path)")
}

let outDir = "/Users/qumo/Documents/Others/Pomodoro/screenshots"

let focusLight = SnapshotMainView(mode: .focus, timeString: "25:00", fraction: 1.0, isRunning: false, completed: 4, isDarkMode: false)
savePNG(renderView(focusLight, size: CGSize(width: 360, height: 500)), to: "\(outDir)/pomodoro-focus-light.png")

let focusDark = SnapshotMainView(mode: .focus, timeString: "18:42", fraction: 0.75, isRunning: true, completed: 4, isDarkMode: true)
savePNG(renderView(focusDark, size: CGSize(width: 360, height: 500)), to: "\(outDir)/pomodoro-focus-dark.png")

let breakLight = SnapshotMainView(mode: .shortBreak, timeString: "05:00", fraction: 1.0, isRunning: false, completed: 4, isDarkMode: false)
savePNG(renderView(breakLight, size: CGSize(width: 360, height: 500)), to: "\(outDir)/pomodoro-break.png")

let settingsDark = SnapshotSettingsView(isDarkMode: true)
savePNG(renderView(settingsDark, size: CGSize(width: 360, height: 500)), to: "\(outDir)/pomodoro-settings.png")

print("All snapshots generated!")
