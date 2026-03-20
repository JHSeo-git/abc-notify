import XCTest
@testable import ABCNotifyLib

final class VersionTests: XCTestCase {

    func testCurrentVersionMatchesRepositoryVersionFile() throws {
        let testsDir = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let repoRoot = testsDir.deletingLastPathComponent()
        let versionFile = repoRoot.appendingPathComponent("VERSION")
        let expected = try String(contentsOf: versionFile, encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        XCTAssertEqual(currentVersion(), expected)
    }
}
