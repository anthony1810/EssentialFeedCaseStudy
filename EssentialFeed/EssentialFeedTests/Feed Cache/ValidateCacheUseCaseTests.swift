//
//  ValidateCacheUseCaseTests.swift
//  EssentialFeed
//
//  Created by Anthony on 2/2/25.
//

import XCTest
import EssentialFeed

class ValidateCacheUseCaseTests: XCTestCase {
    func test_load_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_deleteCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        let expectedError = anyNSError()
        
        sut.validate()
        
        store.completionRetrieval(with: .failure(expectedError))
        
        XCTAssertEqual(store.receivedMessages, [.retrieval, .deletion])
    }
    
    func test_load_doesNotDeleteCacheLessThanSevenDaysOld() {
        let feed = uniqueFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDayTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        let expectation = expectation(description: "waiting for completion")
        sut.load(completion: { _ in expectation.fulfill() })
        
        store.completionRetrieval(with: .found(feed: [feed.local], timestamp: lessThanSevenDayTimestamp))
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertFalse(store.receivedMessages.contains(.deletion))
    }
    
    func test_load_doesNotDeleteCacheWhenCacheIsAlreadyEmpty() {
        let (sut, store) = makeSUT()
        
        let expectation = expectation(description: "waiting for completion")
        sut.load(completion: { _ in expectation.fulfill() })
        
        store.completionRetrieval(with: .empty)
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertFalse(store.receivedMessages.contains(.deletion))
    }
    
    func test_load_deleteCacheOnSevenDaysOld() {
        let feed = uniqueFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDayTimestamp = fixedCurrentDate.adding(days: -7)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validate()
        
        store.completionRetrieval(with: .found(feed: [feed.local], timestamp: lessThanSevenDayTimestamp))
        
        XCTAssertEqual(store.receivedMessages, [.retrieval, .deletion])
    }
    
    func test_load_deleteCacheOnMoreThanSevenDaysOld() {
        let feed = uniqueFeed()
        let fixedCurrentDate = Date()
        let moreThanSevenDayTimestamp = fixedCurrentDate.adding(days: -7).addingTimeInterval(-1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validate()
        
        store.completionRetrieval(with: .found(feed: [feed.local], timestamp: moreThanSevenDayTimestamp))
        
        XCTAssertEqual(store.receivedMessages, [.retrieval, .deletion])
    }

    func test_load_doesNotMessageStoreWhenSUTHasAlreadyDeallocated() {
        let feed = uniqueFeed()
        let fixedCurrentDate = Date()
        let moreThanSevenDayTimestamp = fixedCurrentDate.adding(days: -7).addingTimeInterval(-1)
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: { fixedCurrentDate })

        sut?.validate()
        sut = nil
        
        store.completionRetrieval(with: .found(feed: [feed.local], timestamp: moreThanSevenDayTimestamp))
        
        XCTAssertEqual(store.receivedMessages, [.retrieval])
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
