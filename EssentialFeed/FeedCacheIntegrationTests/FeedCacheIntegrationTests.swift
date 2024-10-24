//
//  FeedCacheIntegrationTests.swift
//  FeedCacheIntegrationTests
//
//  Created by Anthony on 24/10/24.
//

import XCTest
import EssentialFeed
import RealmSwift

final class FeedCacheIntegrationTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        
    }

    override func tearDown() {
        super.tearDown()
        
    }

    func test_load_deliversNoItemsOnEmptyCache() throws {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for load completion")
        
        var actualResult: LoadFeedResult?
        sut.load { result in
            actualResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        switch actualResult {
        case .success(let feeds):
            XCTAssertEqual(feeds, [])
        case .failure(let error):
            XCTFail("Expected success, got \(error)")
        default:
            XCTFail("Expected success or failure, got nothing")
        }
    }

}

extension FeedCacheIntegrationTests {
    private func makeSUT() -> FeedLoader {
        let cacheStore = RealmFeedStore()
        let feedloader = LocalFeedLoader(store: cacheStore, timestamp: Date.init)
        
        return feedloader
    }
}
