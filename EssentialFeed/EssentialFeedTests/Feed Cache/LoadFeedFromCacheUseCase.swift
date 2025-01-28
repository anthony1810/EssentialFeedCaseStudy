//
//  LoadFeedFromCacheUseCase.swift
//  EssentialFeed
//
//  Created by Anthony on 28/1/25.
//

import XCTest
import EssentialFeed

final class FeedStore {
    var deletionCacheCount: Int = 0
    
    func deleteCachedFeed() {
        deletionCacheCount += 1
    }
}

final class LocalFeedLoader {
    let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed()
    }
}

final class LoadFeedFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deletionCacheCount, 0)
    }
    
    func test_save_requestCacheDeletion() {
        let store = FeedStore()
        let loader = LocalFeedLoader(store: store)
        
        let uniqueFeeds = [uniqueFeed(), uniqueFeed()]
        
        loader.save(uniqueFeeds)
        
        XCTAssertEqual(store.deletionCacheCount, 1)
    }
}
