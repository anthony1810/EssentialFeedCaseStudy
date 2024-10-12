//
//  CacheFeedUseCaseTests.swift
//  EssentialFeed
//
//  Created by Anthony on 12/10/24.
//
import XCTest
import EssentialFeed
import Foundation

public struct LocalFeedLoader {
    private let store: FeedStore
    
    public init(store: FeedStore) {
        self.store = store
    }
}

public struct FeedStore {
    var cacheDeletionCount: Int = 0
}

class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponInit() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.cacheDeletionCount, 0)
    }
}
