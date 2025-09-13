//
//  CacheFeedUseCaseTests.swift
//  EssentialFeed
//
//  Created by Anthony on 28/1/25.
//

import XCTest
import EssentialFeed

final class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }

    
    func test_save_doesNotInsertionCacheWhenDeletionFails() {
        let (sut, store) = makeSUT()
        
        let uniqueFeeds = [uniqueFeed(), uniqueFeed()]
        store.completeDeletion(with: .failure(anyNSError()))
        
        sut.save(uniqueFeeds.map(\.model)) {_ in }
        
        XCTAssertEqual(store.receivedMessages, [.deletion])
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfullyDeletion() {
        let currentDate = Date()
        let (sut, store) = makeSUT(currentDate: { currentDate })
        
        let feeds = [uniqueFeed()]
        
        store.completeDeletion(with: .success(()))
        sut.save(feeds.map(\.model)) {_ in }
        
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
        
        action()
        
        sut.save(feeds.map(\.model)) { receivedError = $0; exp.fulfill() }
        
        wait(for: [exp], timeout: 1.0)
    
        XCTAssertEqual(receivedError as NSError?, expectedError as NSError?, file: file, line: line)
    }

}
