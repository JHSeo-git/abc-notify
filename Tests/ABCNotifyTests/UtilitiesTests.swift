import XCTest
@testable import ABCNotifyLib

final class UtilitiesTests: XCTestCase {

    // MARK: - parseArg tests

    func testParseArgFindsValue() {
        let args = ["--window-id", "123"]
        XCTAssertEqual(parseArg(args: args, name: "--window-id"), "123")
    }

    func testParseArgReturnsNilForMissingName() {
        let args = ["--foo", "bar"]
        XCTAssertNil(parseArg(args: args, name: "--window-id"))
    }

    func testParseArgReturnsNilWhenNameAtEnd() {
        let args = ["--window-id"]
        XCTAssertNil(parseArg(args: args, name: "--window-id"))
    }

    func testParseArgReturnsNilForEmptyArgs() {
        XCTAssertNil(parseArg(args: [], name: "--window-id"))
    }

    func testParseArgMultipleFlags() {
        let args = ["--pid", "42", "--window-id", "99", "--name", "Terminal"]
        XCTAssertEqual(parseArg(args: args, name: "--pid"), "42")
        XCTAssertEqual(parseArg(args: args, name: "--window-id"), "99")
        XCTAssertEqual(parseArg(args: args, name: "--name"), "Terminal")
    }

    // MARK: - escapeJSON tests

    func testEscapeJSONPlainString() {
        XCTAssertEqual(escapeJSON("hello world"), "hello world")
    }

    func testEscapeJSONBackslash() {
        XCTAssertEqual(escapeJSON("a\\b"), "a\\\\b")
    }

    func testEscapeJSONQuotes() {
        XCTAssertEqual(escapeJSON("say \"hi\""), "say \\\"hi\\\"")
    }

    func testEscapeJSONNewline() {
        XCTAssertEqual(escapeJSON("line1\nline2"), "line1\\nline2")
    }

    func testEscapeJSONTab() {
        XCTAssertEqual(escapeJSON("col1\tcol2"), "col1\\tcol2")
    }

    func testEscapeJSONCarriageReturn() {
        XCTAssertEqual(escapeJSON("line\r\n"), "line\\r\\n")
    }

    func testEscapeJSONCombined() {
        let input = "path\\to\t\"file\"\nend"
        let expected = "path\\\\to\\t\\\"file\\\"\\nend"
        XCTAssertEqual(escapeJSON(input), expected)
    }
}
