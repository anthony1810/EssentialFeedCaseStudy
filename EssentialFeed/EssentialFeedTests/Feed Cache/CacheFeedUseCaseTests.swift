//
//  CacheFeedUseCaseTests.swift
//  EssentialFeed
//
//  Created by Anthony on 12/10/24.
//
import XCTest
import EssentialFeed
import Foundation

public class LocalFeedLoader {
    private let store: FeedStore
    private let timestamp: () -> Date
    
    public init(store: FeedStore, timestamp: @escaping () -> Date) {
        self.store = store
        self.timestamp = timestamp
    }
    
    public func save(_ items: [FeedItem]) {
        store.deleteCache(completion: { [unowned self] error in
            if error == nil {
                self.store.insertCache(items, timestamp: timestamp())
            }
        })
    }
}

public class FeedStore {
    
    typealias DeletionCacheCompletion = (Error?) -> Void
    
    private(set) var cacheDeletionCount: Int = 0
    private(set) var cacheInsertionCount: Int = 0
    
    private(set) var deletionCompletions = [DeletionCacheCompletion]()
    private(set) var insertionCompletions = [(items: [FeedItem], timestamp: Date)]()
    
    func deleteCache(completion: @escaping DeletionCacheCompletion) {
        cacheDeletionCount += 1
        deletionCompletions.append(completion)
    }
    
    func insertCache(_ items: [FeedItem], timestamp: Date) {
        cacheInsertionCount += 1
        insertionCompletions.append((items, timestamp))
    }
    
    func completeDeletion(error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponInit() {
      let (store, _) = makeSUT()
        
        XCTAssertEqual(store.cacheDeletionCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
       let (store, sut) = makeSUT()
        
        let items: [FeedItem] = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.cacheDeletionCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (store, sut) = makeSUT()
        
        let items: [FeedItem] = [uniqueItem(), uniqueItem()]
        let deletionError = makeAnyError()
        
        sut.save(items)
        store.completeDeletion(error: deletionError, at: 0)
        
        XCTAssertEqual(store.cacheInsertionCount, 0)
    }
    
    func test_save_requestsCacheInsertionOnSuccessDeletion() {
        let (store, sut) = makeSUT()
        
        let items: [FeedItem] = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        store.completeDeletionSuccessfully(at: 0)
        
        XCTAssertEqual(store.cacheInsertionCount, 1)
    }
    
    func test_save_requestsCacheInsertionWithValidTimestampOnSuccessDeletion() {
        let timestamp = Date()
        let (store, sut) = makeSUT(timestamp: { timestamp })
        
        let items: [FeedItem] = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        store.completeDeletionSuccessfully(at: 0)
        
        XCTAssertEqual(store.insertionCompletions.count, 1)
        XCTAssertEqual(store.insertionCompletions.first?.items, items)
        XCTAssertEqual(store.insertionCompletions.first?.timestamp, timestamp)
    }
}

extension CacheFeedUseCaseTests {
    func makeSUT(timestamp: @escaping (() -> Date) = Date.init) -> (store: FeedStore, feedLoader: LocalFeedLoader) {
        
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, timestamp: timestamp)
        
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        
        return (store: store, feedLoader: sut)
    }
    
    func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: nil, location: nil, imageURL: makeAnyUrl())
    }
}
