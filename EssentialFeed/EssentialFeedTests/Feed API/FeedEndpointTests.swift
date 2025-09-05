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
        let sut = makeSUT()
        
        XCTAssertEqual(sut.scheme, "https")
        XCTAssertEqual(sut.host, "base-url.com")
        XCTAssertEqual(sut.path, "/v1/feed")
    }
    
    func test_feed_endpointURLLimitTo10() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.query?.contains("limit=10"), true)
    }
    
    func test_feed_endpointURLAfterGivenImage() {
        let image = uniqueFeed().model
        
        let sut = makeSUT(afterImage: image)
        
        XCTAssertEqual(sut.query?.contains("after_id=\(image.id)"), true)
    }
    
    func test_feed_endpointURLWithoutAfterImage() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.query?.contains("after_id"), false, "Do not include after_id param if there is no afterImage")
    }
    
    // MARK: - Helpers
    func makeSUT(afterImage: FeedImage? = nil) -> URL {
        let baseURL = URL(string: "https://base-url.com")!
        return FeedEndpoint.get(after: afterImage?.id).url(baseURL: baseURL)
    }
}
