//
//  LoadFeedFromCacheUseCase.swift
//  EssentialFeed
//
//  Created by Anthony on 28/1/25.
//

import XCTest
import EssentialFeed

final class LoadFeedFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        let uniqueFeeds = [uniqueFeed(), uniqueFeed()]
        
        sut.save(uniqueFeeds.map(\.model)) {_ in }
        
        XCTAssertEqual(store.receivedMessages, [.deletion])
    }
    
    func test_save_doesNotInsertionCacheWhenDeletionFails() {
        let (sut, store) = makeSUT()
        
        let uniqueFeeds = [uniqueFeed(), uniqueFeed()]
        sut.save(uniqueFeeds.map(\.model)) {_ in }
        store.completeDeletion(with: .failure(anyNSError()))
        
        XCTAssertEqual(store.receivedMessages, [.deletion])
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfullyDeletion() {
        let currentDate = Date()
        let (sut, store) = makeSUT(currentDate: { currentDate })
        
        let feeds = [uniqueFeed()]
        sut.save(feeds.map(\.model)) {_ in }
        store.completeDeletion(with: .success(()))
        
        
        XCTAssertEqual(store.receivedMessages, [.deletion, .insertion(feeds.map(\.local), currentDate)])
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
    
    func test_save_doesNotDeliversDeletionErrorAfterSUTDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receiveResults = [LocalFeedLoader.SaveResult]()
        sut?.save([], completion: { receiveResults.append($0) })
        
        sut = nil
        store.completeDeletion(with: .failure(anyNSError()))
        
        XCTAssertTrue(receiveResults.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receiveResults: [LocalFeedLoader.SaveResult] = []
        sut?.save([], completion: { receiveResults.append($0) })
        store.completeDeletion(with: .success(()))
        
        sut = nil
        store.completionInsertion(with: .failure(anyNSError()))
        
        XCTAssertTrue(receiveResults.isEmpty)
    }
    
    // MARK: - Helper
    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #filePath,
        line: UInt = #line)
    -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
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
        sut.save(feeds.map(\.model)) { receivedError = $0; exp.fulfill() }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    
        XCTAssertEqual(receivedError as NSError?, expectedError as NSError?, file: file, line: line)
    }
    
    private final class FeedStoreSpy: FeedStore {
        struct InsertionMessage {
            let items: [LocalFeedItem]
            let timestamp: Date
        }
        
        enum ReceivedMessage: Equatable {
            case deletion
            case insertion([LocalFeedItem], Date)
        }
        
        var deletionCompletions = [DeletionCompletion]()
        var insertionCompletions = [InsertionCompletion]()
        
        var receivedMessages: [ReceivedMessage] = []
        
        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            deletionCompletions.append(completion)
            receivedMessages.append(.deletion)
        }
        
        func insertCachedFeed(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
            insertionCompletions.append(completion)
            receivedMessages.append(.insertion(items, timestamp))
        }
        
        func completeDeletion(with result: Result<Void, Error>, at index: Int = 0) {
            if case let .failure(error) = result {
                deletionCompletions[index](error)
            } else {
                deletionCompletions[index](nil)
            }
        }
        
        func completionInsertion(with result: Result<Void, Error>, at index: Int = 0) {
            if case let .failure(error) = result {
                insertionCompletions[index](error)
            } else {
                insertionCompletions[index](nil)
            }
        }
    }
}
