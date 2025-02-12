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
        
        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieval])
    }
    
    func test_load_deliversErrorIfStoreRetrievalFails() {
        let (sut, store) = makeSUT()
        let expectedError = anyNSError()
        
        expect(sut, toFinishWithResult: .failure(expectedError)) {
            store.completionRetrieval(with: .failure(expectedError))
        }
    }
    
    func test_load_deliversNoImageOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        expect(sut, toFinishWithResult: .success([])) {
            store.completionRetrieval(with: .empty)
        }
    }
    
    func test_load_deliversCachedImageOnLessThanExpiredDay() {
        let feed = uniqueFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDayTimestamp = fixedCurrentDate.minusMaxCacheAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toFinishWithResult: .success([feed.model])) {
            store.completionRetrieval(with: .found(feed: [feed.local], timestamp: lessThanSevenDayTimestamp))
        }
    }
    
    func test_load_deliversNoImageOnExpireDays() {
        let feed = uniqueFeed()
        let fixedCurrentDate = Date()
        let sevenDayTimestamp = fixedCurrentDate.minusMaxCacheAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toFinishWithResult: .success([])) {
            store.completionRetrieval(with: .found(feed: [feed.local], timestamp: sevenDayTimestamp))
        }
    }
    
    func test_load_deliversNoImageOnMoreThanExpireDays() {
        let feed = uniqueFeed()
        let fixedCurrentDate = Date()
        let moreThanSevenDayTimestamp = fixedCurrentDate.minusMaxCacheAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toFinishWithResult: .success([])) {
            store.completionRetrieval(with: .found(feed: [feed.local], timestamp: moreThanSevenDayTimestamp))
        }
    }
    
    func test_load_hasNoSideEffectOnRetrievalError() {
        let (sut, store) = makeSUT()
        let expectedError = anyNSError()
        
        let expectation = expectation(description: "waiting for completion")
        sut.load(completion: { _ in expectation.fulfill() })
        
        store.completionRetrieval(with: .failure(expectedError))
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(store.receivedMessages, [.retrieval])
    }
    
    func test_load_hasNoSideEffectOnLessThanExpireDay() {
        let feed = uniqueFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDayTimestamp = fixedCurrentDate.minusMaxCacheAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        let expectation = expectation(description: "waiting for completion")
        sut.load(completion: { _ in expectation.fulfill() })
        
        store.completionRetrieval(with: .found(feed: [feed.local], timestamp: lessThanSevenDayTimestamp))
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(store.receivedMessages, [.retrieval])
    }
    
    func test_load_hasNoSideEffectWhenCacheIsAlreadyEmpty() {
        let (sut, store) = makeSUT()
        
        let expectation = expectation(description: "waiting for completion")
        sut.load(completion: { _ in expectation.fulfill() })
        
        store.completionRetrieval(with: .empty)
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(store.receivedMessages, [.retrieval])
    }
    
    func test_load_hasNoSideEffectOnCacheExpireDay() {
        let feed = uniqueFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDayTimestamp = fixedCurrentDate.minusMaxCacheAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        let expectation = expectation(description: "waiting for completion")
        sut.load(completion: { _ in expectation.fulfill() })
        
        store.completionRetrieval(with: .found(feed: [feed.local], timestamp: lessThanSevenDayTimestamp))
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(store.receivedMessages, [.retrieval])
    }
    
    func test_load_hasNoSideEffectOnCacheMoreThanExpiredDay() {
        let feed = uniqueFeed()
        let fixedCurrentDate = Date()
        let moreThanSevenDayTimestamp = fixedCurrentDate.minusMaxCacheAge().addingTimeInterval(-1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        let expectation = expectation(description: "waiting for completion")
        sut.load(completion: { _ in expectation.fulfill() })
        
        store.completionRetrieval(with: .found(feed: [feed.local], timestamp: moreThanSevenDayTimestamp))
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(store.receivedMessages, [.retrieval])
    }

    func test_load_doesNotMessageStoreWhenSUTHasAlreadyDeallocated() {
        let fixedCurrentDate = Date()
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: { fixedCurrentDate })

        var result: LocalFeedLoader.LoadResult?
        sut?.load(completion: {
            result = $0
        })
        sut = nil
        
        store.completionRetrieval(with: .empty)
        
        XCTAssertNil(result)
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
    
    func expect(
        _ sut: LocalFeedLoader,
        toFinishWithResult expectedResult: FeedLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Waiting for load")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receiveFeeds), .success(expectedFeeds)):
                XCTAssertEqual(receiveFeeds, expectedFeeds, file: file, line: line)
            case let (.failure(receivedError as NSError?), (.failure(expectedError as NSError?))):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Got unexpected result: \(receivedResult), expected: \(expectedResult)")
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
