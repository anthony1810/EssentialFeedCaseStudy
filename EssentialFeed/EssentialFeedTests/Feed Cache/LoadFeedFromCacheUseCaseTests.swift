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
}

// MARK: - Helpers
extension LoadFeedFromCacheUseCaseTests {
    func makeSUT(timestamp: @escaping (() -> Date) = Date.init, file: StaticString = #file, line: UInt = #line) -> (store: FeedStoreSpy, feedLoader: LocalFeedLoader) {
        
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, timestamp: timestamp)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (store: store, feedLoader: sut)
    }
    
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
