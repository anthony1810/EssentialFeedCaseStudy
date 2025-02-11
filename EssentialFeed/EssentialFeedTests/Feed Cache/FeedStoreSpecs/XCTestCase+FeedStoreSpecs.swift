//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeed
//
//  Created by Anthony on 6/2/25.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversEmptyCacheOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toReceive: .empty, file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectOnDeliversEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toReceiveTwice: .empty, file: file, line: line)
    }
    
    func assertThatRetrieveDeliversFoundCacheOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let expectedItems = [uniqueFeed().local]
        let expectedDate = Date()
        
        let error = insert(items: expectedItems, timestamp: expectedDate, to: sut, file: file, line: line)
        XCTAssertNil(error, "expected no error when insert cache")
        expect(sut, toReceive: .found(feed: expectedItems, timestamp: expectedDate), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectOnDeliversFoundCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let expectedItems = [uniqueFeed().local]
        let expectedDate = Date()
        
        let error = insert(items: expectedItems, timestamp: expectedDate, to: sut, file: file, line: line)
        XCTAssertNil(error, "expected no error when insert cache")
        
        expect(sut, toReceiveTwice: .found(feed: expectedItems, timestamp: expectedDate), file: file, line: line)
    }
    
    func assertThatInsertOverridesExistingCacheOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let firstExpectedItems = [uniqueFeed().local]
        let firstExpectedDate = Date()
        insert(items: firstExpectedItems, timestamp: firstExpectedDate, to: sut, file: file, line: line)
        
        let lastExpectedItems = [uniqueFeed().local]
        let lastExpectedDate = Date()
        insert(items: lastExpectedItems, timestamp: lastExpectedDate, to: sut, file: file, line: line)
        
        expect(sut, toReceive: .found(feed: lastExpectedItems, timestamp: lastExpectedDate), file: file, line: line)
    }
    
    func assertThatInsertHasNoSideEffectOverridesExistingCacheOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let firstExpectedItems = [uniqueFeed().local]
        let firstExpectedDate = Date()
        insert(items: firstExpectedItems, timestamp: firstExpectedDate, to: sut, file: file, line: line)
        
        let lastExpectedItems = [uniqueFeed().local]
        let lastExpectedDate = Date()
        insertTwice(items: lastExpectedItems, timestamp: lastExpectedDate, to: sut, file: file, line: line)
        
        expect(sut, toReceive: .found(feed: lastExpectedItems, timestamp: lastExpectedDate), file: file, line: line)
    }
    
    func assertThatDeleteDeliversSuccessOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let expectedItems = [uniqueFeed().local]
        let expectedDate = Date()
        
        insert(items: expectedItems, timestamp: expectedDate, to: sut, file: file, line: line)
        let receivedError = deleteCache(from: sut)
        expect(sut, toReceive: .empty, file: file, line: line)
        
        XCTAssertNil(receivedError, "Expect no error when delete an empty cache")
    }
    
    func assertThatSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        var operations = [XCTestExpectation]()
        
        let op1 = expectation(description: "First operation")
        sut.insertCachedFeed([uniqueFeed().local], timestamp: Date(), completion: { _ in
            operations.append(op1)
            op1.fulfill()
        })
        
        let op2 = expectation(description: "Second operation")
        sut.deleteCachedFeed(completion: { _ in
            operations.append(op2)
            op2.fulfill()
        })
        
        let op3 = expectation(description: "third operation")
        sut.insertCachedFeed([uniqueFeed().local], timestamp: Date(), completion: { _ in
            operations.append(op3)
            op3.fulfill()
        })
        
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(operations, [op1, op2, op3], file: file, line: line)
    }
    
}

extension FeedStoreSpecs where Self: XCTestCase {
    func expect(_ sut: FeedStore, toReceive expectedResult: RetrieveCacheFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Waiting for completion")
        
        sut.retrievalCachedFeed { result in
            switch (result, expectedResult) {
            case (.empty, .empty): break
            case let (.found(receivedItems, receivedTimestamp), .found(expectedItems, expectedTimestamp)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                XCTAssertEqual(receivedTimestamp, expectedTimestamp, file: file, line: line)
            case (.failure, .failure): break
            default: XCTFail("Expect \(expectedResult) got \(result)", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func expect(_ sut: FeedStore, toReceiveTwice expectedResult: RetrieveCacheFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toReceive: expectedResult)
        expect(sut, toReceive: expectedResult)
    }
    
    @discardableResult
    func insert(
        items: [LocalFeedImage],
        timestamp: Date,
        to sut: FeedStore,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Error? {
        let exp = expectation(description: "Waiting for completion")
        
        var receivedError: Error?
        sut.insertCachedFeed(items, timestamp: timestamp) { receivedError = $0; exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
        
        return receivedError
    }
    
    func insertTwice(
        items: [LocalFeedImage],
        timestamp: Date,
        to sut: FeedStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        insert(items: items, timestamp: timestamp, to: sut, file: file, line: line)
        insert(items: items, timestamp: timestamp, to: sut, file: file, line: line)
    }
    
    func deleteCache(from sut: FeedStore, file: StaticString = #file, line: UInt = #line) -> Error? {
        let exp = expectation(description: "Wait for completion")
        var receivedError: Error?
        sut.deleteCachedFeed { receivedError = $0; exp.fulfill() }
        
        wait(for: [exp], timeout: 1.0)
        
        return receivedError
    }
    
}
