/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2026 the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import XCTest
import Markdown

final class StrikethroughOptionsTests: XCTestCase {
    func testDefaultStillAcceptsSingleTildes() {
        let document = Document(parsing: "~single~ and ~~double~~")
        XCTAssertEqual(struckText(in: document), ["single", "double"])
    }

    func testDoubleTildeOptionPreservesSingleTildes() {
        let document = Document(parsing: "~single~ and ~~double~~", options: [.strikethroughDoubleTilde])
        XCTAssertEqual(struckText(in: document), ["double"])
        XCTAssertEqual((document.child(at: 0)?.child(at: 0) as? Text)?.string, "~single~ and ")
    }

    func testOptionAppliesInsideContainersWithoutSourceOffsetChecks() {
        for source in [
            "- item\n\t~single~ ~~double~~",
            "| Value |\n| --- |\n| a\\|b ~single~ ~~double~~ |",
            "before\r\r~single~ ~~double~~",
            "~single **bold**~ ~~double~~",
        ] {
            let document = Document(parsing: source, options: [.strikethroughDoubleTilde])
            XCTAssertEqual(struckText(in: document), ["double"], source)
        }
    }

    private func struckText(in node: Markup) -> [String] {
        if let strike = node as? Strikethrough {
            return [strike.children.compactMap { ($0 as? InlineMarkup)?.plainText }.joined()]
        }
        return node.children.flatMap { struckText(in: $0) }
    }
}
