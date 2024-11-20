//
//  Untitled.swift
//  EssentialFeed
//
//  Created by Anthony on 19/10/24.
//

import Foundation
import XCTest
import EssentialFeed

final class EssentialFeedTests: FeedCacheTests {
    func test_init_doesNotMessageStoreUponCreation() {
        let (store, _) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deleteCacheOnRetrieveError() {
        let (store, sut) = makeSUT()
        let expectedError = makeAnyError()
        
        sut.validateCache(completion: {_ in })
        store.completeRetrieval(error: expectedError)
        
        XCTAssertEqual(store.receivedMessages, [.retrieved, .deletedCache])
    }
    
    func test_validateCache_deleteCacheWithCacheOnMoreThanExpireDate() {
        let sevenDaysBeforeToday = Date().minusCacheMaxAgeInDays.addingSeconds(-1)
        let (store, sut) = makeSUT(timestamp: Date.init)
    
        sut.validateCache(completion: {_ in })
        store.completeRetrieval(with: [], timestamp: sevenDaysBeforeToday)
        
        XCTAssertEqual(store.receivedMessages, [.retrieved, .deletedCache])
    }
    
    func test_load_doesNotDeleteCacheOnRetrieveSuccess() {
        let (store, sut) = makeSUT()
        
        sut.validateCache(completion: {_ in })
        store.completeRetrievalWithEmptyFeedSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.retrieved])
    }
    
    func test_load_doesNotDeleteCacheOnLessThenExpireDate() {
        let (store, sut) = makeSUT()
        let expectedFeed = uniqueItem()
        let sevenDaysBeforeToday = Date().minusCacheMaxAgeInDays.addingSeconds(1)
        
        sut.validateCache(completion: {_ in })
        store.completeRetrieval(with: [expectedFeed.localModel], timestamp: sevenDaysBeforeToday)
        
        XCTAssertEqual(store.receivedMessages, [.retrieved])
    }
    
    func test_load_doesNotDeleteCacheWhenInstanceDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, timestamp: Date.init)
        
        sut?.validateCache(completion: {_ in })
        sut = nil
        store.completeRetrievalWithEmptyFeedSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.retrieved])
    }
    
    func test_validateCache_failsOnDeletionErrorOfFailedRetrieval() {
        let (store, sut) = makeSUT()
        let deletionError = makeAnyError()
        
        expectValidationResult(.failure(deletionError), on: sut) {
            store.completeRetrieval(error: deletionError)
            store.completeDeletion(error: deletionError)
        }
    }
    
   func test_validateCache_succeedsOnDeletionSuccessOfFailedRetrieval() {
        let (store, sut) = makeSUT()
        
       expectValidationResult(.success(()), on: sut) {
            store.completeRetrieval(error: makeAnyError())
            store.completeDeletionSuccessfully()
        }
    }
    
    func test_validateCache_succeedsOnEmptyCache() {
        let (store, sut) = makeSUT()
        
       expectValidationResult(.success(()), on: sut) {
           store.completeRetrievalWithEmptyFeedSuccessfully()
        }
    }
    
    func test_validateCache_succeedsOnNonExpiredCache() {
        let (store, sut) = makeSUT()
        let expectedFeed = uniqueItem()
        
        let nonExpiredTimestamp = Date().minusCacheMaxAgeInDays.addingSeconds(1)
        
        expectValidationResult(.success(()), on: sut) {
            store.completeRetrieval(with: [expectedFeed.localModel], timestamp: nonExpiredTimestamp)
        }
    }
}

extension EssentialFeedTests {
    func expectValidationResult(_ expectedResult: LocalFeedLoader.ValidateResult, on sut: LocalFeedLoader, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "validateCache")
        sut.validateCache { actualResult in
            switch(actualResult, expectedResult) {
            case (.success, .success):
                break
            case let (.failure(actualError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(actualError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult) but got \(actualResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
}
