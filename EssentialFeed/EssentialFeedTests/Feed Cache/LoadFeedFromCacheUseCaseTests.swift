//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeed
//
//  Created by Anthony on 13/10/24.
//
import XCTest
import EssentialFeed
import Foundation

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotReceiveAnyMessage() {
        let (store, _) = makeSUT()
          
          XCTAssertEqual(store.receivedMessages, [])
    }
}

// MARK: - Helpers
extension LoadFeedFromCacheUseCaseTests {
    func makeSUT(timestamp: @escaping (() -> Date) = Date.init) -> (store: FeedStoreSpy, feedLoader: LocalFeedLoader) {
        
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, timestamp: timestamp)
        
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        
        return (store: store, feedLoader: sut)
    }
}
