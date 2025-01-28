//
//  LoadFeedFromCacheUseCase.swift
//  EssentialFeed
//
//  Created by Anthony on 28/1/25.
//

import XCTest
import EssentialFeed

final class FeedStore {
    struct InsertionMessage {
        let items: [FeedItem]
        let timestamp: Date
    }
    
    enum ReceivedMessage: Equatable {
        case deletion
        case insertion([FeedItem], Date)
    }
    
    typealias DeletionCompletion = (Result<Void, Error>) -> Void
    typealias InsertionCompletion = (Result<[InsertionMessage], Error>) -> Void
    
    var deletionCacheCount: Int {
        deletionCompletions.count
    }
    var deletionCompletions = [DeletionCompletion]()
    
    var receivedMessages: [ReceivedMessage] = []
    
    
    func deleteCachedFeed(completion: @escaping (Result<Void, Error>) -> Void) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deletion)
    }
    
    func insertCachedFeed(_ items: [FeedItem], timestamp: Date) {
        receivedMessages.append(.insertion(items, timestamp))
    }
    
    func completeDeletion(with result: Result<Void, Error>, at index: Int = 0) {
        deletionCompletions[index](result)
    }
}

final class LocalFeedLoader {
    let store: FeedStore
    let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed(completion: { [weak self] result in
            guard let self else { return }
            
            if case .success = result {
                self.store.insertCachedFeed(items, timestamp: self.currentDate())
            }
        })
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
        
        XCTAssertEqual(store.receivedMessages, [.deletion])
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfullyDeletion() {
        let currentDate = Date()
        let (sut, store) = makeSUT(currentDate: { currentDate })
        
        let feeds = [uniqueFeed()]
        sut.save(feeds)
        store.completeDeletion(with: .success(()))
        
        XCTAssertEqual(store.receivedMessages, [.deletion, .insertion(feeds, currentDate)])
    }
    
    // MARK: - Helper
    func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #filePath,
        line: UInt = #line)
    -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let loader = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(loader, file: file, line: line)
        
        return (loader, store)
    }
}
