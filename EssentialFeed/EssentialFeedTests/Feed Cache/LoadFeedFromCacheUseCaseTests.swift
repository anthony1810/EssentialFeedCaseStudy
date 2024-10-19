//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeed
//
//  Created by Anthony on 13/10/24.
//
import XCTest
import EssentialFeed
import Foundation

class LoadFeedFromCacheUseCaseTests: FeedCacheTests {
    func test_init_doesNotReceiveAnyMessage() {
        let (store, _) = makeSUT()
          
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_receiveRetrieveMessage() {
        let (store, sut) = makeSUT()
        
        sut.load(completion: { _ in })
        
        XCTAssertEqual(store.receivedMessages, [.retrieved])
    }
    
    func test_load_failsOnErrorRetrieveErrorMessage() {
        let (store, sut) = makeSUT()
        let expectedError = makeAnyError()

        expect(sut: sut, toCompleteWith: .failure(expectedError)) {
            store.completeRetrieval(error: expectedError)
        }
    }
    
    func test_load_deliverNoImageOnEmptyCache() {
        let (store, sut) = makeSUT()
        expect(sut: sut, toCompleteWith: .success([])) {
            store.completeRetrievalSuccessfully()
        }
    }
    
    func test_load_deliversImagesFromCacheLessThen7DaysOld() {
        let (store, sut) = makeSUT()
        let expectedFeed = uniqueItem()
        let sevenDaysBeforeToday = Date().sevenDaysBeforeToday.addingSeconds(-1)
        
        expect(sut: sut, toCompleteWith: .success([expectedFeed.domainModel])) {
            store.completeRetrieval(with: [expectedFeed.localModel], timestamp: sevenDaysBeforeToday)
        }
    }
    
    func test_load_deliversImagesFromCacheEqual7DaysOld() {
        let (store, sut) = makeSUT()
        let expectedFeed = uniqueItem()
        let sevenDaysBeforeToday = Date().sevenDaysBeforeToday
        
        expect(sut: sut, toCompleteWith: .success([expectedFeed.domainModel])) {
            store.completeRetrieval(with: [expectedFeed.localModel], timestamp: sevenDaysBeforeToday)
        }
    }
    
    func test_load_deliversNoImagesFromCacheMoreThan7DaysOld() {
        let (store, sut) = makeSUT()
        let sevenDaysBeforeToday = Date().sevenDaysBeforeToday.addingSeconds(1)
        
        expect(sut: sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: [], timestamp: sevenDaysBeforeToday)
        }
    }
    
    func test_load_hasNoSideEffectOnRetrieveError() {
        let (store, sut) = makeSUT()
        let expectedError = makeAnyError()
        
        expect(sut: sut, toCompleteWith: .failure(expectedError)) {
            store.completeRetrieval(error: expectedError)
        }
        
        XCTAssertEqual(store.receivedMessages, [.retrieved])
    }
    
    func test_load_hasNoSideEffectOnRetrieveSuccess() {
        let (store, sut) = makeSUT()
        
        expect(sut: sut, toCompleteWith: .success([])) {
            store.completeRetrievalSuccessfully()
        }
        
        XCTAssertEqual(store.receivedMessages, [.retrieved])
    }
    
    func test_load_hasNoSideEffectOnLessThen7DaysOld() {
        let (store, sut) = makeSUT()
        let expectedFeed = uniqueItem()
        let sevenDaysBeforeToday = Date().sevenDaysBeforeToday.addingSeconds(-1)
        
        expect(sut: sut, toCompleteWith: .success([expectedFeed.domainModel])) {
            store.completeRetrieval(with: [expectedFeed.localModel], timestamp: sevenDaysBeforeToday)
        }
        
        XCTAssertEqual(store.receivedMessages, [.retrieved])
    }
    
    func test_load_hasNoSideEffectWithCacheOnMoreThan7DaysOld() {
        let (store, sut) = makeSUT()
        let sevenDaysBeforeToday = Date().sevenDaysBeforeToday.addingSeconds(1)
        
        expect(sut: sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: [], timestamp: sevenDaysBeforeToday)
        }
        
        XCTAssertEqual(store.receivedMessages, [.retrieved])
    }
    
    func test_load_doesNotPerformAnyOperationAfterInstanceDeallocation() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, timestamp: Date.init)
        
        var captureResult = [LocalFeedLoader.LoadResult]()
        sut?.load(completion: { captureResult.append($0) })
        
        sut = nil
        store.completeRetrievalSuccessfully()
        
        XCTAssertTrue(captureResult.isEmpty)
    }
}

// MARK: - Helpers
extension LoadFeedFromCacheUseCaseTests {
    func expect(sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Load completion")
            
        sut.load { actualResult in
            switch (actualResult, expectedResult) {
            case let (.success(feed), .success(expectedFeed)):
                XCTAssertEqual(feed, expectedFeed, file: file, line: line)
            case let (.failure(error as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(error, expectedError, file: file, line: line)
            default: XCTFail("Unexpected result: \(actualResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}


