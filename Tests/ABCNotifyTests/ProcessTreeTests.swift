import XCTest
import Darwin
@testable import ABCNotifyLib

final class ProcessTreeTests: XCTestCase {

    func testAncestorPIDsFromCurrentProcess() {
        let chain = ancestorPIDs(from: getpid())
        XCTAssertFalse(chain.isEmpty)
        XCTAssertEqual(chain.first, getpid())
        XCTAssertEqual(chain.last, 1)
    }

    func testAncestorPIDsStartsWithGivenPID() {
        let pid = getpid()
        let chain = ancestorPIDs(from: pid)
        XCTAssertFalse(chain.isEmpty)
        XCTAssertEqual(chain.first, pid)
    }

    func testAncestorPIDsNoDuplicates() {
        let chain = ancestorPIDs(from: getpid())
        let unique = Set(chain)
        XCTAssertEqual(chain.count, unique.count, "Ancestor PID chain should have no duplicates")
    }

    func testAncestorPIDsFromPID1() {
        let chain = ancestorPIDs(from: 1)
        XCTAssertEqual(chain, [1])
    }

    func testAncestorPIDsFromInvalidPID() {
        // An invalid/non-existent PID should return an empty array or at most [pid]
        // because sysctl will fail to find the process.
        let chain = ancestorPIDs(from: 99_999_999)
        XCTAssertTrue(chain.count <= 1, "Invalid PID should produce an empty or single-element chain")
    }
}
