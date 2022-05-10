//
//  FormatAndLintExampleUITests.swift
//  FormatAndLintExampleUITests
//
//  Created by Kevin Munc on 5/9/22.
//

import XCTest

class FormatAndLintExampleUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
