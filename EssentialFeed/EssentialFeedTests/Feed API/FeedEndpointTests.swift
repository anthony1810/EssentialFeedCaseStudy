//
//  FeedEndpointTests.swift
//  EssentialFeed
//
//  Created by Anthony on 25/8/25.
//

import Foundation
import XCTest
import EssentialFeed

final class FeedEndpointTests: XCTestCase {
    func test_feed_endpointURL() {
        let baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
        let expected = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        
        let actual = FeedEndpoint.get.url(baseURL: baseURL)
        
        XCTAssertEqual(actual, expected)
    }
}
