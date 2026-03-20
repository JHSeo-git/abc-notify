import Foundation
import CoreGraphics
import ABCNotifyLib

// MARK: - Subcommand dispatch

let args = CommandLine.arguments
let command = args.count > 1 ? args[1] : "help"

switch command {
case "capture":
    runCapture()
case "focus":
    runFocus(args: Array(args.dropFirst(2)))
case "is-focused":
    runIsFocused(args: Array(args.dropFirst(2)))
case "check-access":
    runCheckAccess(args: Array(args.dropFirst(2)))
case "help", "--help", "-h":
    printUsage()
case "version", "--version":
    print("abc-notify \(currentVersion())")
default:
    fputs("Error: Unknown command '\(command)'\n", stderr)
    printUsage()
    exit(1)
}

// MARK: - Subcommand implementations

func runCapture() {
    if let window = captureTerminalWindow() {
        let json = """
        {"window_id":\(window.windowID),"owner_pid":\(window.ownerPID),"owner_name":"\(escapeJSON(window.ownerName))"}
        """
        print(json)
        exit(0)
    }

    // Fallback to frontmost app
    if let window = captureFrontmostApp() {
        let json = """
        {"window_id":\(window.windowID),"owner_pid":\(window.ownerPID),"owner_name":"\(escapeJSON(window.ownerName))"}
        """
        print(json)
        exit(0)
    }

    fputs("Error: Could not capture terminal window\n", stderr)
    exit(1)
}

func runFocus(args: [String]) {
    guard let windowID = parseArg(args: args, name: "--window-id"),
          let pid = parseArg(args: args, name: "--pid"),
          let wid = UInt32(windowID),
          let pidVal = Int32(pid)
    else {
        fputs("Usage: abc-notify focus --window-id <id> --pid <pid>\n", stderr)
        exit(1)
    }

    let success = focusWindow(windowID: CGWindowID(wid), pid: pidVal)
    exit(success ? 0 : 1)
}

func runIsFocused(args: [String]) {
    guard let windowID = parseArg(args: args, name: "--window-id"),
          let pid = parseArg(args: args, name: "--pid"),
          let wid = UInt32(windowID),
          let pidVal = Int32(pid)
    else {
        fputs("Usage: abc-notify is-focused --window-id <id> --pid <pid>\n", stderr)
        exit(1)
    }

    let focused = isWindowFocused(windowID: CGWindowID(wid), pid: pidVal)
    if focused {
        print("true")
        exit(0)
    } else {
        print("false")
        exit(1)
    }
}

func runCheckAccess(args: [String]) {
    let shouldPrompt = args.contains("--prompt")
    let trusted = checkAccessibilityPermission(prompt: shouldPrompt)

    if trusted {
        print("Accessibility permission: granted")
        exit(0)
    } else {
        print("Accessibility permission: denied")
        if !shouldPrompt {
            print("Run with --prompt to request permission")
        }
        exit(1)
    }
}

func printUsage() {
    let usage = """
    abc-notify — Native window helper for abc-notify

    Usage:
      abc-notify <command> [options]

    Commands:
      capture                                  Capture current terminal window info (JSON)
      focus --window-id <id> --pid <pid>       Focus a specific window
      is-focused --window-id <id> --pid <pid>  Check if window is focused
      check-access [--prompt]                  Check accessibility permission
      version                                  Show version
      help                                     Show this help
    """
    print(usage)
}
