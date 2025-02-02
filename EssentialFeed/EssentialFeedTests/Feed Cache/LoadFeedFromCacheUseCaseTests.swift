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
    
    func test_load_deliversCachedImageOnLessThanSevenDaysOld() {
        let feed = uniqueFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDayTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toFinishWithResult: .success([feed.model])) {
            store.completionRetrieval(with: .found(feed: [feed.local], timestamp: lessThanSevenDayTimestamp))
        }
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
        toFinishWithResult expectedResult: LoadFeedResult,
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
