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
    typealias InsertionCompletion = (Result<Void, Error>) -> Void
    
    var deletionCacheCount: Int {
        deletionCompletions.count
    }
    var deletionCompletions = [DeletionCompletion]()
    var insertionCompletions = [InsertionCompletion]()
    
    var receivedMessages: [ReceivedMessage] = []
    
    
    func deleteCachedFeed(completion: @escaping (Result<Void, Error>) -> Void) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deletion)
    }
    
    func insertCachedFeed(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insertion(items, timestamp))
    }
    
    func completeDeletion(with result: Result<Void, Error>, at index: Int = 0) {
        deletionCompletions[index](result)
    }
    
    func completionInsertion(with result: Result<Void, Error>, at index: Int = 0) {
        insertionCompletions[index](result)
    }
}

final class LocalFeedLoader {
    let store: FeedStore
    let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed(completion: { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success:
                self.store.insertCachedFeed(items, timestamp: self.currentDate()) { result in
                    if case let .failure(error) = result {
                        return completion(error)
                    }
                    return completion(nil)
                }
            case .failure(let error):
                completion(error)
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
        
        sut.save(uniqueFeeds) {_ in }
        
        XCTAssertEqual(store.deletionCacheCount, 1)
    }
    
    func test_save_doesNotInsertionCacheWhenDeletionFails() {
        let (sut, store) = makeSUT()
        
        sut.save([uniqueFeed(), uniqueFeed()]) {_ in }
        store.completeDeletion(with: .failure(anyNSError()))
        
        XCTAssertEqual(store.receivedMessages, [.deletion])
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfullyDeletion() {
        let currentDate = Date()
        let (sut, store) = makeSUT(currentDate: { currentDate })
        
        let feeds = [uniqueFeed()]
        sut.save(feeds) {_ in }
        store.completeDeletion(with: .success(()))
        
        XCTAssertEqual(store.receivedMessages, [.deletion, .insertion(feeds, currentDate)])
    }
    
    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with: .failure(deletionError))
        }
    }
    
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWithError: insertionError) {
            store.completeDeletion(with: .success(()))
            store.completionInsertion(with: .failure(insertionError))
        }
    }
    
    func test_save_successOnInsertionSuccess() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWithError: nil) {
            store.completeDeletion(with: .success(()))
            store.completionInsertion(with: .success(()))
        }
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
    
    func expect(
        _ sut: LocalFeedLoader,
        toCompleteWithError expectedError: Error?,
        when action: @escaping () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "waiting for save command to finish")
        let feeds = [uniqueFeed(), uniqueFeed()]
        var receivedError: Error?
        sut.save(feeds) { receivedError = $0; exp.fulfill() }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    
        XCTAssertEqual(receivedError as NSError?, expectedError as NSError?, file: file, line: line)
    }
}
