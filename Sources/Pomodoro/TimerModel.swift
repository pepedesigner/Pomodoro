import AppKit
import Combine
import SwiftUI
import UserNotifications

// MARK: - Settings keys

enum SettingsKeys {
    static let focusMinutes = "focusMinutes"
    static let shortBreakMinutes = "shortBreakMinutes"
    static let longBreakMinutes = "longBreakMinutes"
    static let longBreakInterval = "longBreakInterval"
    static let autoStartBreaks = "autoStartBreaks"
    static let autoStartFocus = "autoStartFocus"
    static let soundEnabled = "soundEnabled"
    static let notificationsEnabled = "notificationsEnabled"
    static let completedToday = "completedToday"
}

// MARK: - Modes

enum TimerMode: String, CaseIterable, Identifiable {
    case focus
    case shortBreak
    case longBreak

    var id: String { rawValue }

    var title: String {
        switch self {
        case .focus: "Focus"
        case .shortBreak: "Short Break"
        case .longBreak: "Long Break"
        }
    }

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

// MARK: - Model

@MainActor
final class TimerModel: ObservableObject {
    @Published var mode: TimerMode = .focus
    @Published private(set) var remaining: TimeInterval = 25 * 60
    @Published private(set) var isRunning = false
    @Published private(set) var completedFocusSessions = 0

    private var timer: Timer?
    private var currentDuration: TimeInterval = 25 * 60
    private var didRequestNotificationPermission = false

    private let defaults = UserDefaults.standard

    init() {
        defaults.register(defaults: [
            SettingsKeys.focusMinutes: 25,
            SettingsKeys.shortBreakMinutes: 5,
            SettingsKeys.longBreakMinutes: 15,
            SettingsKeys.longBreakInterval: 4,
            SettingsKeys.autoStartBreaks: true,
            SettingsKeys.autoStartFocus: false,
            SettingsKeys.soundEnabled: true,
            SettingsKeys.notificationsEnabled: true,
            SettingsKeys.completedToday: 0,
        ])
        completedFocusSessions = defaults.integer(forKey: SettingsKeys.completedToday)
        currentDuration = duration(for: mode)
        remaining = currentDuration
    }

    var timeString: String {
        let total = Int(max(0, remaining.rounded()))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }

    var fraction: Double {
        guard currentDuration > 0 else { return 0 }
        return min(max(remaining / currentDuration, 0), 1)
    }

    var modeColor: Color { mode.color }

    func requestNotificationPermissionIfNeeded() {
        guard !didRequestNotificationPermission else { return }
        didRequestNotificationPermission = true
        let center = UNUserNotificationCenter.current()
        Task { @MainActor in
            _ = try? await center.requestAuthorization(options: [.alert, .sound])
        }
    }

    func toggle() {
        isRunning ? pause() : start()
    }

    func start() {
        guard !isRunning else { return }
        currentDuration = duration(for: mode)
        if remaining <= 0 || remaining > currentDuration {
            remaining = currentDuration
        }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.tick()
            }
        }
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        pause()
        currentDuration = duration(for: mode)
        remaining = currentDuration
    }

    func skip() {
        completeSession()
    }

    func switchMode(_ newMode: TimerMode) {
        pause()
        mode = newMode
        currentDuration = duration(for: mode)
        remaining = currentDuration
    }

    func reloadDurationIfIdle() {
        guard !isRunning else { return }
        currentDuration = duration(for: mode)
        remaining = currentDuration
    }

    private func tick() {
        remaining -= 1
        if remaining <= 0 {
            remaining = 0
            completeSession()
        }
    }

    private func completeSession() {
        pause()
        let finishedMode = mode

        if finishedMode == .focus {
            completedFocusSessions += 1
            defaults.set(completedFocusSessions, forKey: SettingsKeys.completedToday)
            let interval = defaults.integer(forKey: SettingsKeys.longBreakInterval)
            mode = (completedFocusSessions % interval == 0) ? .longBreak : .shortBreak
        } else {
            mode = .focus
        }

        currentDuration = duration(for: mode)
        remaining = currentDuration

        if defaults.bool(forKey: SettingsKeys.soundEnabled) {
            NSSound(named: NSSound.Name("Glass"))?.play()
        }
        if defaults.bool(forKey: SettingsKeys.notificationsEnabled) {
            postCompletionNotification(for: finishedMode)
        }

        let autoStartBreaks = defaults.bool(forKey: SettingsKeys.autoStartBreaks)
        let autoStartFocus = defaults.bool(forKey: SettingsKeys.autoStartFocus)
        if (finishedMode == .focus && autoStartBreaks) || (finishedMode != .focus && autoStartFocus) {
            start()
        }
    }

    private func postCompletionNotification(for finishedMode: TimerMode) {
        let content = UNMutableNotificationContent()
        content.title = finishedMode == .focus ? "Focus complete" : "Break over"
        content.body = finishedMode == .focus
            ? "Great work. Time for a break."
            : "Ready for the next focus session?"
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        Task { @MainActor in
            try? await UNUserNotificationCenter.current().add(request)
        }
    }

    private func duration(for mode: TimerMode) -> TimeInterval {
        let minutes: Int
        switch mode {
        case .focus: minutes = defaults.integer(forKey: SettingsKeys.focusMinutes)
        case .shortBreak: minutes = defaults.integer(forKey: SettingsKeys.shortBreakMinutes)
        case .longBreak: minutes = defaults.integer(forKey: SettingsKeys.longBreakMinutes)
        }
        return TimeInterval(max(1, minutes) * 60)
    }
}
