import AppKit
import SwiftUI

/// Exposes the hosting NSWindow so we can tweak standard window chrome.
struct WindowAccessor: NSViewRepresentable {
    var onWindowChange: @MainActor (NSWindow?) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async { [weak view] in
            MainActor.assumeIsolated {
                onWindowChange(view?.window)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async { [weak nsView] in
            MainActor.assumeIsolated {
                onWindowChange(nsView?.window)
            }
        }
    }
}

/// Hides the standard close / minimize / zoom buttons so the window chrome
/// stays clean. The style-mask bits are removed first so the system cannot
/// render the buttons at all; hiding the button views is a fallback.
@MainActor
func hideStandardWindowButtons(_ window: NSWindow?) {
    guard let window else { return }

    var style: NSWindow.StyleMask = window.styleMask
    style.remove(.closable)
    style.remove(.miniaturizable)
    style.remove(.resizable)
    window.styleMask = style

    window.standardWindowButton(.closeButton)?.isHidden = true
    window.standardWindowButton(.miniaturizeButton)?.isHidden = true
    window.standardWindowButton(.zoomButton)?.isHidden = true

    print("hideStandardWindowButtons: window='\(window.title)' styleMask=\(window.styleMask.rawValue)")
}
