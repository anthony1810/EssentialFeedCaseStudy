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
    
    public init(store: FeedStore) {
        self.store = store
    }
    
    public func save(_ items: [FeedItem]) {
        store.deleteCache(completion: { [unowned self] error in
            if error == nil {
                self.store.insertCache(items)
            }
        })
    }
}

public class FeedStore {
    
    typealias DeletionCacheCompletion = (Error?) -> Void
    
    private(set) var cacheDeletionCount: Int = 0
    private(set) var cacheInsertionCount: Int = 0
    
    private var deletionCompletions = [DeletionCacheCompletion]()
    
    func deleteCache(completion: @escaping DeletionCacheCompletion) {
        cacheDeletionCount += 1
        deletionCompletions.append(completion)
    }
    
    func insertCache(_ items: [FeedItem]) {
        cacheInsertionCount += 1
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
    
    func test_save_requestsCacheInsertionOnSuccess() {
        let (store, sut) = makeSUT()
        
        let items: [FeedItem] = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        store.completeDeletionSuccessfully(at: 0)
        
        XCTAssertEqual(store.cacheInsertionCount, 1)
    }
}

extension CacheFeedUseCaseTests {
    func makeSUT() -> (store: FeedStore, feedLoader: LocalFeedLoader) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        
        return (store: store, feedLoader: sut)
    }
    
    func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: nil, location: nil, imageURL: makeAnyUrl())
    }
}
