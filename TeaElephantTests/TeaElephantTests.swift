//
//  TeaElephantTests.swift
//  TeaElephantTests
//
//  Created by Andrew Khasanov on 16.07.2020.
//

import XCTest
@testable import TeaElephant
import SwiftUI

class TeaElephantTests: XCTestCase {

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testprocessQRCode() async throws {
        let reader = Reader(infoReader: NFCReader(), extender: RecordGetter())
        await reader.processQRCode("3c252497-9d87-44f0-b3de-2822c6b94df5")
        XCTAssertEqual(
            reader.error,
            "qr code is free, write some info for this qr code first",
            "incorrect error"
        )
    }
    
    func testColorIsDark() {
        let colorview = Color(hex: "#BE000000")
        XCTAssertTrue(colorview.isDark())
    }
    
    func testColorIsDarkNegative() {
        let colorview = Color(hex: "#FFFFFFFF")
        XCTAssertFalse(colorview.isDark())
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
