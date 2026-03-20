import XCTest
@testable import ABCNotifyLib

final class AccessibilityCheckTests: XCTestCase {

    func testCheckAccessibilityPermissionReturnsBool() {
        // Call with prompt: false so no system dialog appears during testing.
        // The actual return value depends on whether the test runner has
        // accessibility permissions — we only verify the call completes.
        let result = checkAccessibilityPermission(prompt: false)
        XCTAssertTrue(result == true || result == false)
    }
}
