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
        let baseURL = URL(string: "https://base-url.com")!
        
        let actual = FeedEndpoint.get().url(baseURL: baseURL)
        
        XCTAssertEqual(actual.scheme, "https")
        XCTAssertEqual(actual.host, "base-url.com")
        XCTAssertEqual(actual.path, "/v1/feed")
    }
    
    func test_feed_endpointURLLimitTo10() {
        let baseURL = URL(string: "https://base-url.com")!
        let afterGivenImageURL = FeedEndpoint.get().url(baseURL: baseURL)
        
        XCTAssertEqual(afterGivenImageURL.query?.contains("limit=10"), true)
    }
    
    func test_feed_endpointURLAfterGivenImage() {
        let image = uniqueFeed().model
        
        let baseURL = URL(string: "https://base-url.com")!
        let afterGivenImageURL = FeedEndpoint.get(after: image.id).url(baseURL: baseURL)
        
        XCTAssertEqual(afterGivenImageURL.query?.contains("after_id=\(image.id)"), true)
    }
}
