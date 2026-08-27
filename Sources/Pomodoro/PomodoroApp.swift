import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate()

        // SwiftUI creates windows lazily, so hide the system title bar
        // buttons whenever a window becomes key (this fires after the window
        // is fully set up, when the buttons definitely exist).
        NotificationCenter.default.addObserver(
            forName: NSWindow.didBecomeKeyNotification,
            object: nil,
            queue: .main
        ) { note in
            let window = note.object as? NSWindow
            MainActor.assumeIsolated {
                hideStandardWindowButtons(window)
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}

@MainActor
@main
struct PomodoroApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model = TimerModel()

    var body: some Scene {
        WindowGroup(id: "main") {
            ContentView()
                .environmentObject(model)
                .onAppear { model.requestNotificationPermissionIfNeeded() }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)

        MenuBarExtra {
            MenuBarView()
                .environmentObject(model)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "timer")
                Text(model.timeString)
            }
        }
        .menuBarExtraStyle(.menu)
    }
}
