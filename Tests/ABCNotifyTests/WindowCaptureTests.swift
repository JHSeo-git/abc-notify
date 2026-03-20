import XCTest
import CoreGraphics
@testable import ABCNotifyLib

final class WindowCaptureTests: XCTestCase {

    func testCapturedWindowStructCreation() {
        let w = CapturedWindow(windowID: 42, ownerPID: 100, ownerName: "Test")
        XCTAssertEqual(w.windowID, 42)
        XCTAssertEqual(w.ownerPID, 100)
        XCTAssertEqual(w.ownerName, "Test")
    }

    func testCapturedWindowStructCreationWithZeroValues() {
        let w = CapturedWindow(windowID: 0, ownerPID: 0, ownerName: "")
        XCTAssertEqual(w.windowID, 0)
        XCTAssertEqual(w.ownerPID, 0)
        XCTAssertEqual(w.ownerName, "")
    }

    func testCaptureTerminalWindowDoesNotCrash() {
        // May return nil in a test environment — just verify it does not crash.
        _ = captureTerminalWindow()
    }

    func testCaptureFrontmostAppDoesNotCrash() {
        // May return nil in a headless test environment — just verify it does not crash.
        _ = captureFrontmostApp()
    }
}
