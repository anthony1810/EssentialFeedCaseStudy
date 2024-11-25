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
       
        expectFeedsCount(22, in: app)
        expectFeedImagesExisted(true, in: app)
    }
    
    func test_onLaunch_displaysCachedFeedWhenCustomerHasNoConnectivity() throws {
        let onlineApp = XCUIApplication()
        onlineApp.launch()
        
        waitUntilIdleByDelay(seconds: 3)
        
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-connectivity", "offline"]
        offlineApp.launch()
        
        expectFeedsCount(22, in: offlineApp)
        expectFeedImagesExisted(true, in: offlineApp)
    }
    
    func test_onLaunch_displayEmptyFeedsOnNoCachedAndNoConnectivity() throws {
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-reset", "-connectivity", "offline"]
        offlineApp.launch()
        
        expectFeedsCount(0, in: offlineApp)
        expectFeedImagesExisted(false, in: offlineApp)
    }
}

extension EssentialAppUITests {
    func expectFeedsCount(_ count: Int, in app: XCUIApplication, file: StaticString = #file, line: UInt = #line) {
        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        let firstCell = feedCells.element(boundBy: 0)
        
        if count > 0 {
            XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "No feed cells appeared within the timeout.", file: file, line: line)
        }
       
        XCTAssertEqual(feedCells.count, count, "Unexpected number of feed cells.", file: file, line: line)
    }
    
    func expectFeedImagesExisted(_ existed: Bool, in app: XCUIApplication, file: StaticString = #file, line: UInt = #line) {
        let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch.waitForExistence(timeout: 5.0)
        XCTAssertTrue(existed ? firstImage : !firstImage, "Unexpected number of feed images.", file: file, line: line)
    }
    
    func waitUntilIdleByDelay(seconds: Double) {
        let expectation = XCTestExpectation(description: "Wait before launching offline app")
        let result = XCTWaiter.wait(for: [expectation], timeout: seconds)
        XCTAssertEqual(result, .timedOut, "Delay interrupted before launching offline app")
    }
}
