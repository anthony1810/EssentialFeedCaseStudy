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
}

final class LocalFeedLoader {
    let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func load() {}
}

final class LoadFeedFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deletionCacheCount, 0)
    }
}
