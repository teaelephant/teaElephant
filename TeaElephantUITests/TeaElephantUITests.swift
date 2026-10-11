//
//  TeaElephantUITests.swift
//  TeaElephantUITests
//
//  Created by Andrew Khasanov on 16.07.2020.
//

import XCTest

class TeaElephantUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testWhitespaceOnlyNameCannotAdvance() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-hasCompletedOnboarding", "YES", "-hasSeenOnboarding", "YES"]
        app.launch()
        let addTea = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Add New Tea")).firstMatch
        XCTAssertTrue(addTea.waitForExistence(timeout: 10))
        addTea.tap()

        let name = app.textFields.firstMatch
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.tap()
        name.typeText("   ")

        let next = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Continue")).firstMatch
        XCTAssertTrue(next.waitForExistence(timeout: 5))
        XCTAssertFalse(next.isEnabled, "A required name consisting only of spaces must not allow the next step")
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
