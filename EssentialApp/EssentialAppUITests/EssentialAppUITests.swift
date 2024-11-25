//
//  EssentialAppUITests.swift
//  EssentialAppUITests
//
//  Created by Anthony on 25/11/24.
//

import XCTest

final class EssentialAppUITests: XCTestCase {
    
    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }
    
}
