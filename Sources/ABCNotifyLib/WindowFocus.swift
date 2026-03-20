import AppKit
import ApplicationServices

// Private API type for _AXUIElementGetWindow
private typealias AXUIElementGetWindowFunc = @convention(c) (AXUIElement, UnsafeMutablePointer<CGWindowID>) -> AXError

/// Cached dlsym lookup for _AXUIElementGetWindow
private let axGetWindow: AXUIElementGetWindowFunc? = {
    guard let handle = dlopen(nil, RTLD_LAZY),
          let sym = dlsym(handle, "_AXUIElementGetWindow")
    else { return nil }
    return unsafeBitCast(sym, to: AXUIElementGetWindowFunc.self)
}()

/// Focus a specific window identified by its CGWindowID and owner PID.
/// Returns true on success.
@discardableResult
public func focusWindow(windowID: CGWindowID, pid: pid_t) -> Bool {
    // 1. Activate the application
    guard let app = NSRunningApplication(processIdentifier: pid) else {
        return false
    }
    app.activate(options: [.activateIgnoringOtherApps])

    // 2. If no specific window, we're done
    guard windowID != 0 else { return true }

    // 3. Try to raise the specific window via AXUIElement
    let axApp = AXUIElementCreateApplication(pid)

    var windowsRef: CFTypeRef?
    let result = AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, &windowsRef)
    guard result == .success, let windows = windowsRef as? [AXUIElement] else {
        return true  // app activated but can't enumerate windows
    }

    // Try matching by CGWindowID using private API
    if let getWindow = axGetWindow {
        for axWindow in windows {
            var wid: CGWindowID = 0
            if getWindow(axWindow, &wid) == .success && wid == windowID {
                AXUIElementPerformAction(axWindow, kAXRaiseAction as CFString)
                AXUIElementSetAttributeValue(axWindow, kAXMainAttribute as CFString, true as CFTypeRef)
                return true
            }
        }
    }

    // Fallback: match by window bounds from CGWindowList
    if let targetBounds = boundsForWindow(windowID: windowID) {
        for axWindow in windows {
            if let axBounds = boundsForAXElement(axWindow),
               boundsMatch(targetBounds, axBounds) {
                AXUIElementPerformAction(axWindow, kAXRaiseAction as CFString)
                AXUIElementSetAttributeValue(axWindow, kAXMainAttribute as CFString, true as CFTypeRef)
                return true
            }
        }
    }

    // Couldn't match specific window, but app is activated
    return true
}

/// Check if a specific window is currently focused.
public func isWindowFocused(windowID: CGWindowID, pid: pid_t) -> Bool {
    // 1. Check if the app is frontmost
    guard let frontApp = NSWorkspace.shared.frontmostApplication,
          frontApp.processIdentifier == pid
    else {
        return false
    }

    // 2. Check if the specific window is topmost
    guard windowID != 0 else { return true }

    guard let windowList = CGWindowListCopyWindowInfo(
        [.optionOnScreenOnly, .excludeDesktopElements],
        kCGNullWindowID
    ) as? [[String: Any]] else {
        return false
    }

    // Find the first layer-0 window — it should be our target
    for win in windowList {
        guard (win[kCGWindowLayer as String] as? Int) == 0,
              let wid = win[kCGWindowNumber as String] as? CGWindowID
        else { continue }

        return wid == windowID
    }

    return false
}

// MARK: - Bounds matching helpers

private struct WindowBounds {
    let x: Double
    let y: Double
    let width: Double
    let height: Double
}

private func boundsForWindow(windowID: CGWindowID) -> WindowBounds? {
    guard let windowList = CGWindowListCopyWindowInfo(
        [.optionOnScreenOnly, .excludeDesktopElements],
        kCGNullWindowID
    ) as? [[String: Any]] else {
        return nil
    }

    for win in windowList {
        guard let wid = win[kCGWindowNumber as String] as? CGWindowID,
              wid == windowID,
              let bounds = win[kCGWindowBounds as String] as? [String: Double],
              let x = bounds["X"], let y = bounds["Y"],
              let w = bounds["Width"], let h = bounds["Height"]
        else { continue }

        return WindowBounds(x: x, y: y, width: w, height: h)
    }
    return nil
}

private func boundsForAXElement(_ element: AXUIElement) -> WindowBounds? {
    var posRef: CFTypeRef?
    var sizeRef: CFTypeRef?

    guard AXUIElementCopyAttributeValue(element, kAXPositionAttribute as CFString, &posRef) == .success,
          AXUIElementCopyAttributeValue(element, kAXSizeAttribute as CFString, &sizeRef) == .success
    else { return nil }

    var point = CGPoint.zero
    var size = CGSize.zero
    AXValueGetValue(posRef as! AXValue, .cgPoint, &point)
    AXValueGetValue(sizeRef as! AXValue, .cgSize, &size)

    return WindowBounds(x: point.x, y: point.y, width: size.width, height: size.height)
}

private func boundsMatch(_ a: WindowBounds, _ b: WindowBounds, tolerance: Double = 5.0) -> Bool {
    abs(a.x - b.x) <= tolerance &&
    abs(a.y - b.y) <= tolerance &&
    abs(a.width - b.width) <= tolerance &&
    abs(a.height - b.height) <= tolerance
}
