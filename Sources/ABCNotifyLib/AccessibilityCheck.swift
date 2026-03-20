import ApplicationServices

/// Check if the application has accessibility permissions.
/// If `prompt` is true, macOS will show the permission dialog.
public func checkAccessibilityPermission(prompt: Bool) -> Bool {
    let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): prompt] as CFDictionary
    return AXIsProcessTrustedWithOptions(options)
}
