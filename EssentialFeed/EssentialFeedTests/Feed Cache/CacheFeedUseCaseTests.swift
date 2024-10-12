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
                self.store.insertCache(items, timestamp: timestamp(), completion: completion)
            } else {
                completion(error)
            }
        })
    }
}

public protocol FeedStore {
    typealias DeletionCacheCompletion = (Error?) -> Void
    typealias InsertionCacheCompletion = (Error?) -> Void
    
    func deleteCache(completion: @escaping DeletionCacheCompletion)
    func insertCache(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCacheCompletion)
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
        let error = makeAnyError()
        
        expect(sut: sut, toCompleteWith: error) {
            store.completeDeletion(error: error, at: 0)
        }
    }
    
    func test_save_failsWithInsertionError() {
        let (store, sut) = makeSUT()
        let error = makeAnyError()
        
        expect(sut: sut, toCompleteWith: error) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(error: error)
        }
    }
    
    func test_save_successfullyWithCacheInsertionAndDeletionSuccess() {
      
        let (store, sut) = makeSUT()
        
        expect(sut: sut, toCompleteWith: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }
}

extension CacheFeedUseCaseTests {
    func makeSUT(timestamp: @escaping (() -> Date) = Date.init) -> (store: FeedStoreSpy, feedLoader: LocalFeedLoader) {
        
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, timestamp: timestamp)
        
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        
        return (store: store, feedLoader: sut)
    }
    
    func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: nil, location: nil, imageURL: makeAnyUrl())
    }
    
    func expect(sut: LocalFeedLoader, toCompleteWith error: Error?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let items: [FeedItem] = [uniqueItem(), uniqueItem()]
        
        var capturedError: Error?
        let exp = expectation(description: "save completion")
        sut.save(items) { error in
            capturedError = error
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(capturedError as? NSError, error as? NSError)
    }
    
    public class FeedStoreSpy: FeedStore {
        
        enum ReceiveMessage: Equatable {
            case deletedCache
            case insertedCache([FeedItem], Date)
        }
        
        private(set) var deletionCompletions = [DeletionCacheCompletion]()
        private(set) var insertionCompletions = [InsertionCacheCompletion]()
        
        private(set) var receivedMessages = [ReceiveMessage]()
        
        public func deleteCache(completion: @escaping DeletionCacheCompletion) {
            deletionCompletions.append(completion)
            receivedMessages.append(.deletedCache)
        }
        
        public func insertCache(_ items: [FeedItem], timestamp: Date, completion: @escaping (Error?) -> Void) {
            insertionCompletions.append(completion)
            receivedMessages.append(.insertedCache(items, timestamp))
        }
        
        func completeDeletion(error: Error, at index: Int = 0) {
            deletionCompletions[index](error)
        }
        
        func completeDeletionSuccessfully(at index: Int = 0) {
            deletionCompletions[index](nil)
        }
        
        func completeInsertion(error: Error, at index: Int = 0) {
            insertionCompletions[index](error)
        }
        
        func completeInsertionSuccessfully(at index: Int = 0) {
            insertionCompletions[index](nil)
        }
    }
}
