import CoreGraphics
import AppKit

public struct CapturedWindow {
    public let windowID: CGWindowID
    public let ownerPID: pid_t
    public let ownerName: String

    public init(windowID: CGWindowID, ownerPID: pid_t, ownerName: String) {
        self.windowID = windowID
        self.ownerPID = ownerPID
        self.ownerName = ownerName
    }
}

/// Find the terminal window that owns the calling process by walking the
/// ancestor PID chain and matching against on-screen windows.
public func captureTerminalWindow() -> CapturedWindow? {
    let callerPID = getppid()  // parent of this helper = the shell calling us
    let ancestors = ancestorPIDs(from: callerPID)

    guard !ancestors.isEmpty else { return nil }

    // Get all on-screen, normal-layer windows
    guard let windowList = CGWindowListCopyWindowInfo(
        [.optionOnScreenOnly, .excludeDesktopElements],
        kCGNullWindowID
    ) as? [[String: Any]] else {
        return nil
    }

    // Filter to layer-0 (normal) windows
    let normalWindows = windowList.filter { info in
        (info[kCGWindowLayer as String] as? Int) == 0
    }

    // Walk ancestors from nearest to farthest; first one that owns a window wins
    for ancestorPID in ancestors {
        for win in normalWindows {
            guard let ownerPID = win[kCGWindowOwnerPID as String] as? pid_t,
                  ownerPID == ancestorPID,
                  let windowID = win[kCGWindowNumber as String] as? CGWindowID
            else { continue }

            let ownerName = win[kCGWindowOwnerName as String] as? String ?? "Unknown"
            return CapturedWindow(
                windowID: windowID,
                ownerPID: ownerPID,
                ownerName: ownerName
            )
        }
    }

    return nil
}

/// Fallback: use NSWorkspace.frontmostApplication
public func captureFrontmostApp() -> CapturedWindow? {
    guard let app = NSWorkspace.shared.frontmostApplication else { return nil }

    let pid = app.processIdentifier
    let name = app.localizedName ?? "Unknown"

    // Find that app's topmost window
    guard let windowList = CGWindowListCopyWindowInfo(
        [.optionOnScreenOnly, .excludeDesktopElements],
        kCGNullWindowID
    ) as? [[String: Any]] else {
        return CapturedWindow(windowID: 0, ownerPID: pid, ownerName: name)
    }

    for win in windowList {
        guard let ownerPID = win[kCGWindowOwnerPID as String] as? pid_t,
              ownerPID == pid,
              (win[kCGWindowLayer as String] as? Int) == 0,
              let windowID = win[kCGWindowNumber as String] as? CGWindowID
        else { continue }

        return CapturedWindow(windowID: windowID, ownerPID: pid, ownerName: name)
    }

    return CapturedWindow(windowID: 0, ownerPID: pid, ownerName: name)
}
