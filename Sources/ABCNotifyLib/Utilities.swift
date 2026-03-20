import Foundation

/// Parse a named argument from a command-line argument array.
/// Returns the value following `name`, or nil if not found.
public func parseArg(args: [String], name: String) -> String? {
    guard let index = args.firstIndex(of: name),
          index + 1 < args.count
    else { return nil }
    return args[index + 1]
}

/// Escape special characters for JSON string embedding.
public func escapeJSON(_ string: String) -> String {
    string
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "\"", with: "\\\"")
        .replacingOccurrences(of: "\n", with: "\\n")
        .replacingOccurrences(of: "\r", with: "\\r")
        .replacingOccurrences(of: "\t", with: "\\t")
}
