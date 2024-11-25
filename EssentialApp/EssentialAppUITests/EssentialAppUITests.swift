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
       
        expectFeedsExisted(in: app)
        expectFeedImagesExisted(in: app)
    }
    
    func test_onLaunch_displaysCachedFeedWhenCustomerHasNoConnectivity() throws {
        let onlineApp = XCUIApplication()
        onlineApp.launch()
        
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-connectivity", "offline"]
        offlineApp.launch()
        
        expectFeedsExisted(in: offlineApp)
        expectFeedImagesExisted(in: offlineApp)
    }
}

extension EssentialAppUITests {
    func expectFeedsExisted(in app: XCUIApplication, file: StaticString = #file, line: UInt = #line) {
        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        let firstCell = feedCells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "No feed cells appeared within the timeout.")
        XCTAssertEqual(feedCells.count, 22, "Unexpected number of feed cells.", file: file, line: line)
    }
    
    func expectFeedImagesExisted(in app: XCUIApplication, file: StaticString = #file, line: UInt = #line) {
        let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch.waitForExistence(timeout: 5.0)
        XCTAssertTrue(firstImage, "Unexpected number of feed images.", file: file, line: line)
    }
}
