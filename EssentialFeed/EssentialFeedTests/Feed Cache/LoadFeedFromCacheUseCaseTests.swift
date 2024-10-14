//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeed
//
//  Created by Anthony on 13/10/24.
//
import XCTest
import EssentialFeed
import Foundation

class LoadFeedFromCacheUseCaseTests: XCTestCase {
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
        let exp = expectation(description: "Load completion")
        
        var capturedError: Error?
        sut.load { result in
            if case let .failure(error) = result {
                capturedError = error
            } else {
                XCTFail("Expected .failure, got \(result)")
            }
            exp.fulfill()
        }
        store.completeRetrieval(error: expectedError)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(capturedError as NSError?, expectedError)
    }
    
//    func test_load_deliverNoImageOnEmptyCache() {
//        let (store, sut) = makeSUT()
//        let exp = expectation(description: "Load completion")
//        
//        var capturedResult = [FeedImage]()
//        sut.load { result in
//            
//            exp.fulfill()
//        }
//        store.completeRetrieval(feed: .empty)
//        
//        
//    }
}

// MARK: - Helpers
extension LoadFeedFromCacheUseCaseTests {
    func makeSUT(timestamp: @escaping (() -> Date) = Date.init) -> (store: FeedStoreSpy, feedLoader: LocalFeedLoader) {
        
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, timestamp: timestamp)
        
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        
        return (store: store, feedLoader: sut)
    }
}
