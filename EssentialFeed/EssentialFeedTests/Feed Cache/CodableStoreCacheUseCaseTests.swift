//
//  CodableFeedCacheUseCaseTests.swift
//  EssentialFeed
//
//  Created by Anthony on 19/10/24.
//

import Foundation
import XCTest
import EssentialFeed

class CodableStoreCacheUseCaseTests: FeedCacheTests, FeedStoreTestSpecs, FailableFeedStore {
    
    override func setUp() {
        super.setUp()
        
        setUpState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        clearUpState()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        
        let sut = makeSUT(storeURL: nil)
        
        expect(sut: sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT(storeURL: nil)
    
        expect(sut: sut, toRetrieve: .empty)
        expect(sut: sut, toRetrieve: .empty)
    }
    
    func test_retrieve_insertThenRetrieveExpectedvalue() {
        let sut = makeSUT(storeURL: nil)
        let expectedItem = uniqueItem().localModel
        let timeStamp = Date()
        
        expect(sut: sut, toInsertFeed: [expectedItem], timestamp: timeStamp, WithError: nil)
        expect(sut: sut, toRetrieve: .success([expectedItem], timeStamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT(storeURL: nil)
        let expectedItem = uniqueItem().localModel
        let expectedTimeStamp = Date()
        
        expect(sut: sut, toInsertFeed: [expectedItem], timestamp: expectedTimeStamp, WithError: nil)
        expect(sut: sut, toRetrieve: .success([expectedItem], expectedTimeStamp))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let testStoreURL = testSpecificStoreURL
        let sut = makeSUT(storeURL: testStoreURL)
        let expectedError = makeAnyError()
        
        try! "invalidData".write(to: testStoreURL, atomically: false, encoding: .utf8)
        
        expect(sut: sut, toRetrieve: .failure(expectedError))
    }
    
    func test_retrieve_hasNoSideEffectsOnRetrievalError() {
        let testStoreURL = testSpecificStoreURL
        let sut = makeSUT(storeURL: testStoreURL)
        let expectedError = makeAnyError()
        
        try! "invalidData".write(to: testStoreURL, atomically: false, encoding: .utf8)
        
        expect(sut: sut, toRetrieve: .failure(expectedError))
        expect(sut: sut, toRetrieve: .failure(expectedError))
    }
    
    func test_insert_overridePreviousValue() {
        let sut = makeSUT(storeURL: nil)
        
        let expectedItem = uniqueItem().localModel
        let expectedItem2 = uniqueItem().localModel
        let expectedTimeStamp = Date()
        
        expect(sut: sut, toInsertFeed: [expectedItem], timestamp: expectedTimeStamp, WithError: nil)
        expect(sut: sut, toInsertFeed: [expectedItem2], timestamp: expectedTimeStamp, WithError: nil)
        expect(sut: sut, toInsertFeed: [expectedItem2], timestamp: expectedTimeStamp, WithError: nil)
    }
    
    func test_insert_deliversErrorWhenEncounterFailure() {
        let invalidStoreURL = URL(fileURLWithPath: "/invalid/path")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let expectedError = makeAnyError()
        
        expect(sut: sut, toInsertFeed: [], timestamp: Date(), WithError: expectedError)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT(storeURL: nil)
        
        expect(sut: sut, toDeleteWithError: nil)
        expect(sut: sut, toDeleteWithError: nil)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT(storeURL: nil)
        let timestamp = Date()
        let expectedItem = uniqueItem().localModel
        
        expect(sut: sut, toInsertFeed: [expectedItem], timestamp: timestamp, WithError: nil)
        expect(sut: sut, toDeleteWithError: nil)
        expect(sut: sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionFailure() {
        let invalidStoreURL = readOnlyStoreURL
        let sut = makeSUT(storeURL: invalidStoreURL)
        let expectedError = makeAnyError()
        
        expect(sut: sut, toDeleteWithError: expectedError)
    }
    
    func test_runSerially_executesTasksInOrder() {
        let sut = makeSUT(storeURL: nil)
        let timestamp = Date()
        let expectedItem = uniqueItem().localModel
        
        var completionExpectations = [XCTestExpectation]()
        
        let op1 = expectation(description: "inserted")
        sut.insertCache([expectedItem], timestamp: timestamp) { _ in
            completionExpectations.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "deleted")
        sut.deleteCache(completion: { _ in
            completionExpectations.append(op2)
            op2.fulfill()
        })
        
        let op3 = expectation(description: "inserted 2")
        sut.insertCache([expectedItem], timestamp: timestamp) { _ in
            completionExpectations.append(op3)
            op3.fulfill()
        }
        
        let op4 = expectation(description: "retrieved")
        sut.retrieve { _ in
            completionExpectations.append(op4)
            op4.fulfill()
        }
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(completionExpectations, [op1, op2, op3, op4])
    }
}

// MARK: - Helpers
extension CodableStoreCacheUseCaseTests {
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    func expect(sut: FeedStore, toRetrieve expectedResult: RetrievalResult, file: StaticString = #file, line: UInt = #line) {
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
            XCTFail("expected \(expectedResult), got result: \(capturedResult!)", file: file, line: line)
        }
    }
    
    func expect(sut: FeedStore, toInsertFeed feeds: [LocalFeedImage], timestamp: Date, WithError expectedError: Error?, file: StaticString = #file, line: UInt = #line) {
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
    
    func expect(sut: FeedStore, toDeleteWithError expectedError: Error?, file: StaticString = #file, line: UInt = #line) {
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
    
    func setUpState() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL)
    }
    
    func clearUpState() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL)
    }
}
