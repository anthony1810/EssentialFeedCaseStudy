//
//  Untitled.swift
//  EssentialFeed
//
//  Created by Anthony on 20/10/24.
//
import Foundation
import XCTest
import EssentialFeed

typealias FailableFeedStore = FailableRetrieveFeedStoreSpec & FailableInsertFeedStoreSpec & FailableDeleteFeedStoreSpec

public protocol FeedStoreTestSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache()
    func test_retrieve_hasNoSideEffectsOnEmptyCache()
    func test_retrieve_insertThenRetrieveExpectedvalue()
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache()

    func test_insert_overridePreviousValue()
    
    func test_delete_hasNoSideEffectsOnEmptyCache()
    func test_delete_emptiesPreviouslyInsertedCache()

    func test_runSerially_executesTasksInOrder()
}

protocol FailableRetrieveFeedStoreSpec: FeedStoreTestSpecs {
    func test_retrieve_deliversFailureOnRetrievalError()
    func test_retrieve_hasNoSideEffectsOnRetrievalError()
}

protocol FailableInsertFeedStoreSpec: FeedStoreTestSpecs {
    func test_insert_deliversErrorWhenEncounterFailure()
}

protocol FailableDeleteFeedStoreSpec: FeedStoreTestSpecs {
    func test_delete_deliversErrorOnDeletionFailure()
}

extension FeedStoreTestSpecs where Self: XCTestCase {
    func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStoreProtocol {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    func expect(sut: FeedStoreProtocol, toRetrieve expectedResult: RetrievalResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        var capturedResult: RetrievalResult?
        
        sut.retrieve { result in
            capturedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        switch (capturedResult, expectedResult) {
        case (.empty, .empty):
            break
        case let (.success(actualFeedItems, actualTimestamp), (.success(expectedFeedItems, expectedTimestamp))):
            XCTAssertEqual(actualFeedItems, expectedFeedItems, file: file, line: line)
            XCTAssertEqual(actualTimestamp, expectedTimestamp, file: file, line: line)
        case (.failure, (.failure)):
            break
        default:
            XCTAssertNotNil(capturedResult, "expected \(expectedResult)", file: file, line: line)
        }
    }
    
    func expect(sut: FeedStoreProtocol, toInsertFeed feeds: [LocalFeedImage], timestamp: Date, WithError expectedError: Error?, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
      
        var capturedError: Error?
        sut.insertCache(feeds, timestamp: timestamp) { error in
            capturedError = error
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        if expectedError != nil {
            XCTAssertNotNil(capturedError, file: file, line: line)
        } else {
            XCTAssertNil(capturedError, file: file, line: line)
        }
    }
    
    func expect(sut: FeedStoreProtocol, toDeleteWithError expectedError: Error?, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
      
        var capturedError: Error?
        sut.deleteCache { error in
            capturedError = error
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        if expectedError != nil {
            XCTAssertNotNil(capturedError, file: file, line: line)
        } else {
            XCTAssertNil(capturedError, file: file, line: line)
        }
    }
    
    var testSpecificStoreURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self))")
    }
    
    var readOnlyStoreURL: URL {
        FileManager.default.urls(for: .adminApplicationDirectory, in: .systemDomainMask).first!
    }
}
