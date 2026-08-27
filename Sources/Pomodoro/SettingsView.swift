import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var model: TimerModel

    @AppStorage(SettingsKeys.focusMinutes) private var focusMinutes = 25
    @AppStorage(SettingsKeys.shortBreakMinutes) private var shortBreakMinutes = 5
    @AppStorage(SettingsKeys.longBreakMinutes) private var longBreakMinutes = 15
    @AppStorage(SettingsKeys.longBreakInterval) private var longBreakInterval = 4
    @AppStorage(SettingsKeys.autoStartBreaks) private var autoStartBreaks = true
    @AppStorage(SettingsKeys.autoStartFocus) private var autoStartFocus = false
    @AppStorage(SettingsKeys.soundEnabled) private var soundEnabled = true
    @AppStorage(SettingsKeys.notificationsEnabled) private var notificationsEnabled = true

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Settings")
                    .font(.title2.bold())
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(16)

            Form {
                Section("Durations") {
                    Stepper("Focus: \(focusMinutes) min", value: $focusMinutes, in: 1...180)
                    Stepper("Short break: \(shortBreakMinutes) min", value: $shortBreakMinutes, in: 1...60)
                    Stepper("Long break: \(longBreakMinutes) min", value: $longBreakMinutes, in: 1...120)
                    Stepper("Long break every \(longBreakInterval) pomodoros", value: $longBreakInterval, in: 2...12)
                }
                Section("Automation") {
                    Toggle("Auto-start breaks", isOn: $autoStartBreaks)
                    Toggle("Auto-start focus sessions", isOn: $autoStartFocus)
                }
                Section("Alerts") {
                    Toggle("Play sound", isOn: $soundEnabled)
                    Toggle("Show notifications", isOn: $notificationsEnabled)
                }
            }
            .formStyle(.grouped)
            .padding(.bottom, 10)
        }
        .frame(width: 400, height: 420)
        .onChange(of: focusMinutes) { model.reloadDurationIfIdle() }
        .onChange(of: shortBreakMinutes) { model.reloadDurationIfIdle() }
        .onChange(of: longBreakMinutes) { model.reloadDurationIfIdle() }
    }
}
