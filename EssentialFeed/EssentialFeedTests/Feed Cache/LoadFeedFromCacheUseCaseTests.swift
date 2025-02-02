//
//  LoadFeedFromCacheUseCaseTests.swift.swift
//  EssentialFeed
//
//  Created by Anthony on 2/2/25.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    func test_load_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestCacheRetrieval() {
        let (sut, store) = makeSUT()
        
        sut.load() { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieval])
    }
    
    func test_load_deliversErrorIfStoreRetrievalFails() {
        let (sut, store) = makeSUT()
        let exp = expectation(description: "Waiting for load")
        let expectedError = anyNSError()
        
        var capturedError: Swift.Error?
        sut.load() { receivedError in
            capturedError = receivedError
            exp.fulfill()
        }
        
        store.completionRetrieval(with: .failure(expectedError))
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(capturedError as? NSError, expectedError)
    }
    
    // MARK: - Helpers
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
}
