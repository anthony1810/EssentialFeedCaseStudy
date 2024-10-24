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
        
        expect(sut: sut, toCompleteWith: .success([]))
    }

}

extension FeedCacheIntegrationTests {
    
    private func expect(sut: FeedLoader, toCompleteWith expectedResult: LoadFeedResult) {
        let exp = expectation(description: "Wait for load completion")
        
        var actualResult: LoadFeedResult?
        sut.load { result in
            actualResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        switch (actualResult, expectedResult) {
        case (.success(let actualFeeds), .success(let expectedFeed)):
            XCTAssertEqual(actualFeeds, expectedFeed)
        case (.failure(let actualError), .failure):
            XCTAssertNotNil(actualError)
        default:
            XCTFail("Expected success or failure, got nothing")
        }
    }
    
    private func makeSUT() -> FeedLoader {
        let cacheStore = RealmFeedStore()
        let feedloader = LocalFeedLoader(store: cacheStore, timestamp: Date.init)
        
        trackForMemoryLeaks(cacheStore)
        trackForMemoryLeaks(feedloader)
        
        return feedloader
    }
}
