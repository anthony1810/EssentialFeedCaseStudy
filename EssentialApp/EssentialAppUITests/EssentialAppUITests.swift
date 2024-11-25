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
        let firstCell = feedCells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "No feed cells appeared within the timeout.")
        XCTAssertEqual(feedCells.count, 22, "Unexpected number of feed cells.")
        
        let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch.waitForExistence(timeout: 5.0)
        XCTAssertTrue(firstImage)
    }
    
    func test_onLaunch_displaysCachedFeedWhenCustomerHasNoConnectivity() throws {
        let onlineApp = XCUIApplication()
        onlineApp.launch()
        
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-connectivity", "offline"]
        offlineApp.launch()
        
        let feedCells = offlineApp.cells.matching(identifier: "feed-image-cell")
        let firstCell = feedCells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "No feed cells appeared within the timeout.")
        XCTAssertEqual(feedCells.count, 22, "Unexpected number of feed cells.")
        
        let firstImage = offlineApp.images.matching(identifier: "feed-image-view").firstMatch.waitForExistence(timeout: 5.0)
        XCTAssertTrue(firstImage)
    }
    
}
