//
//  EssentialAppUITests.swift
//  EssentialAppUITests
//
//  Created by Anthony on 25/11/24.
//

import XCTest

final class EssentialAppUITests: XCTestCase {
    
    @MainActor
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() throws {
        let app = XCUIApplication()
        app.launch()
        
        let feedCells = app.cells.matching(identifier: "feed-image-cell")

        // Wait for at least one feed cell to appear
        let firstCell = feedCells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "No feed cells appeared within the timeout.")

        // Now assert the count if needed
        XCTAssertEqual(feedCells.count, 22, "Unexpected number of feed cells.")
        
        let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch.waitForExistence(timeout: 10.0)
        XCTAssertTrue(firstImage)
    }
    
}
