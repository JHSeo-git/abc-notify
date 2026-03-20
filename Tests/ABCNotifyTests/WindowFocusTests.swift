import XCTest
import CoreGraphics
@testable import ABCNotifyLib

final class WindowFocusTests: XCTestCase {

    func testFocusWindowWithInvalidPIDReturnsFalse() {
        // NSRunningApplication(processIdentifier:) returns nil for a non-existent PID,
        // so focusWindow should return false immediately.
        let result = focusWindow(windowID: 99999, pid: 99_999_999)
        XCTAssertFalse(result)
    }

    func testFocusWindowWithZeroWindowID() {
        // windowID 0 with an invalid PID — the app lookup fails first, so result is false.
        let result = focusWindow(windowID: 0, pid: 99_999_999)
        XCTAssertFalse(result)
    }

    func testIsWindowFocusedWithInvalidPID() {
        // Frontmost app PID won't match an invalid PID, so result is false.
        let result = isWindowFocused(windowID: 99999, pid: 99_999_999)
        XCTAssertFalse(result)
    }

    func testIsWindowFocusedWithZeroWindowIDAndInvalidPID() {
        let result = isWindowFocused(windowID: 0, pid: 99_999_999)
        XCTAssertFalse(result)
    }
}
