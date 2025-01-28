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
    var insertionCacheCount: Int = 0
    
    func deleteCachedFeed() {
        deletionCacheCount += 1
    }
    
    func insertCachedFeed(_ items: [FeedItem]) {
        insertionCacheCount += 1
    }
    
    func completeDeletion(with result: Result<Void, Error>, at index: Int = 0) {
        if case .success = result {
            insertionCacheCount += 1
        }
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
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deletionCacheCount, 0)
    }
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        
        let uniqueFeeds = [uniqueFeed(), uniqueFeed()]
        
        sut.save(uniqueFeeds)
        
        XCTAssertEqual(store.deletionCacheCount, 1)
    }
    
    func test_save_doesNotInsertionCacheWhenDeletionFails() {
        let (sut, store) = makeSUT()
        
        sut.save([uniqueFeed(), uniqueFeed()])
        store.completeDeletion(with: .failure(anyError()))
        
        XCTAssertEqual(store.insertionCacheCount, 0)
    }
    
    func test_save_requestsCacheInsertionWhenDeletionSucceeds() {
        let (sut, store) = makeSUT()
        
        let feeds = [uniqueFeed(), uniqueFeed()]
        sut.save(feeds)
        store.completeDeletion(with: .success(()))
        
        XCTAssertEqual(store.insertionCacheCount, 1)
    }
    
    // MARK: - Helper
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let loader = LocalFeedLoader(store: store)
        
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(loader, file: file, line: line)
        
        return (loader, store)
    }
}
