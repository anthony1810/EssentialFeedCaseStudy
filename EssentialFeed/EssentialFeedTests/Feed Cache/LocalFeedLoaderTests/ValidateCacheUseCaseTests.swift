//
//  ValidateCacheUseCaseTests.swift
//  EssentialFeed
//
//  Created by Anthony on 2/2/25.
//

import XCTest
import EssentialFeed

class ValidateCacheUseCaseTests: XCTestCase {
    func test_validate_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validate_deleteCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        let expectedError = anyNSError()
        
        sut.validate(completion: {_ in })
        
        store.completionRetrieval(with: .failure(expectedError))
        
        XCTAssertEqual(store.receivedMessages, [.retrieval, .deletion])
    }
    
    func test_validate_doesNotDeleteCacheLessThanExpireDay() {
        let feed = uniqueFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDayTimestamp = fixedCurrentDate.minusMaxCacheAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        let expectation = expectation(description: "waiting for completion")
        sut.load(completion: { _ in expectation.fulfill() })
        
        store.completionRetrieval(with: .success((feed: [feed.local], timestamp: lessThanSevenDayTimestamp)))
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertFalse(store.receivedMessages.contains(.deletion))
    }
    
    func test_validate_doesNotDeleteCacheWhenCacheIsAlreadyEmpty() {
        let (sut, store) = makeSUT()
        
        let expectation = expectation(description: "waiting for completion")
        sut.load(completion: { _ in expectation.fulfill() })
        
        store.completionRetrieval(with: .success(.none))
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertFalse(store.receivedMessages.contains(.deletion))
    }
    
    func test_validate_deleteCacheOnExpireDay() {
        let feed = uniqueFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDayTimestamp = fixedCurrentDate.minusMaxCacheAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validate(completion: {_ in })
        
        store.completionRetrieval(with: .success((feed: [feed.local], timestamp: lessThanSevenDayTimestamp)))
        
        XCTAssertEqual(store.receivedMessages, [.retrieval, .deletion])
    }
    
    func test_validate_deleteCacheOnMoreThanExpireDay() {
        let feed = uniqueFeed()
        let fixedCurrentDate = Date()
        let moreThanSevenDayTimestamp = fixedCurrentDate.minusMaxCacheAge().addingTimeInterval(-1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validate(completion: {_ in })
        
        store.completionRetrieval(with: .success((feed: [feed.local], timestamp: moreThanSevenDayTimestamp)))
        
        XCTAssertEqual(store.receivedMessages, [.retrieval, .deletion])
    }

    func test_validate_doesNotMessageStoreWhenSUTHasAlreadyDeallocated() {
        let feed = uniqueFeed()
        let fixedCurrentDate = Date()
        let moreThanSevenDayTimestamp = fixedCurrentDate.minusMaxCacheAge().addingTimeInterval(-1)
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: { fixedCurrentDate })

        sut?.validate(completion: {_ in })
        sut = nil
        
        store.completionRetrieval(with: .success((feed: [feed.local], timestamp: moreThanSevenDayTimestamp)))
        
        XCTAssertEqual(store.receivedMessages, [.retrieval])
    }
    
    func test_validateCache_failsOnDeletionErrorOfFailedRetrieval() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(deletionError)) {
            store.completionRetrieval(with: .failure(anyNSError()))
            store.completeDeletion(with: .failure(deletionError))
        }
    }
    
    func test_validateCache_succeedsOnSuccessfulDeletionOfFailedRetrieval() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success(())) {
            store.completionRetrieval(with: .failure(anyNSError()))
            store.completeDeletion(with: .success(()))
        }
    }
    
    func test_validateCache_succeedsOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success(())) {
            store.completionRetrieval(with: .success((feed: [], timestamp: Date())))
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
    
    private func expect(
        _ sut: LocalFeedLoader,
        toCompleteWith expectedResult: LocalFeedLoader.ValidationResult,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        let expectation = expectation(description: "Waiting for validation completion")
        sut.validate(completion: { actualResult in
            switch (actualResult, expectedResult) {
            case (.success, .success):
                break
            case let (.failure(receivedError as NSError), .failure(actualError as NSError)):
                XCTAssertEqual(receivedError, actualError, file: file, line: line)
            default:
                XCTFail("Expect result \(expectedResult), got result \(actualResult)", file: file, line: line)
            }
            expectation.fulfill()
        })
        
        action()
        wait(for: [expectation], timeout: 1.0)
        
    }
}
