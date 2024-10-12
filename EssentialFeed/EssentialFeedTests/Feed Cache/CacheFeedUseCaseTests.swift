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
    
    public func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCache(completion: { [unowned self] error in
            if error == nil {
                self.store.insertCache(items, timestamp: timestamp())
            }
            completion(error)
        })
    }
}

public class FeedStore {
    
    enum ReceiveMessage: Equatable {
        case deletedCache
        case insertedCache([FeedItem], Date)
    }
    
    typealias DeletionCacheCompletion = (Error?) -> Void
    
    private(set) var deletionCompletions = [DeletionCacheCompletion]()
    private(set) var receivedMessages = [ReceiveMessage]()
    
    func deleteCache(completion: @escaping DeletionCacheCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deletedCache)
    }
    
    func insertCache(_ items: [FeedItem], timestamp: Date) {
        receivedMessages.append(.insertedCache(items, timestamp))
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
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
       let (store, sut) = makeSUT()
        
        let items: [FeedItem] = [uniqueItem(), uniqueItem()]
        
        sut.save(items) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deletedCache])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (store, sut) = makeSUT()
        
        let items: [FeedItem] = [uniqueItem(), uniqueItem()]
        let deletionError = makeAnyError()
        
        sut.save(items) { _ in }
        store.completeDeletion(error: deletionError, at: 0)
        
        XCTAssertEqual(store.receivedMessages, [.deletedCache])
    }
    
    func test_save_requestsCacheInsertionWithValidTimestampOnSuccessDeletion() {
        let timestamp = Date()
        let (store, sut) = makeSUT(timestamp: { timestamp })
        
        let items: [FeedItem] = [uniqueItem(), uniqueItem()]
        
        sut.save(items) { _ in }
        store.completeDeletionSuccessfully(at: 0)
        
        XCTAssertEqual(store.receivedMessages, [.deletedCache, .insertedCache(items, timestamp)])
    }
    
    func test_save_failsWithDeletionError() {
        let (store, sut) = makeSUT()
        
        let items: [FeedItem] = [uniqueItem(), uniqueItem()]
        let error = makeAnyError()
        
        var capturedError: Error?
        let exp = expectation(description: "save completion")
        sut.save(items) { error in
            capturedError = error
            exp.fulfill()
        }
        store.completeDeletion(error: error, at: 0)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(capturedError as? NSError, error)
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
