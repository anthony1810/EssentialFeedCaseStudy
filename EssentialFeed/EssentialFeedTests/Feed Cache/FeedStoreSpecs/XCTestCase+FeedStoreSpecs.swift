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
        expect(sut, toReceive: .success(.none), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectOnDeliversEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toReceiveTwice: .success(.none), file: file, line: line)
    }
    
    func assertThatRetrieveDeliversFoundCacheOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let expectedItems = [uniqueFeed().local]
        let expectedDate = Date()
        
        let error = insert(items: expectedItems, timestamp: expectedDate, to: sut, file: file, line: line)
        XCTAssertNil(error, "expected no error when insert cache")
        expect(sut, toReceive: .success((feed: expectedItems, timestamp: expectedDate)), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectOnDeliversFoundCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let expectedItems = [uniqueFeed().local]
        let expectedDate = Date()
        
        let error = insert(items: expectedItems, timestamp: expectedDate, to: sut, file: file, line: line)
        XCTAssertNil(error, "expected no error when insert cache")
        
        expect(sut, toReceiveTwice: .success((feed: expectedItems, timestamp: expectedDate)), file: file, line: line)
    }
    
    func assertThatInsertOverridesExistingCacheOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let firstExpectedItems = [uniqueFeed().local]
        let firstExpectedDate = Date()
        insert(items: firstExpectedItems, timestamp: firstExpectedDate, to: sut, file: file, line: line)
        
        let lastExpectedItems = [uniqueFeed().local]
        let lastExpectedDate = Date()
        insert(items: lastExpectedItems, timestamp: lastExpectedDate, to: sut, file: file, line: line)
        
        expect(sut, toReceive: .success((feed: lastExpectedItems, timestamp: lastExpectedDate)), file: file, line: line)
    }
    
    func assertThatInsertHasNoSideEffectOverridesExistingCacheOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let firstExpectedItems = [uniqueFeed().local]
        let firstExpectedDate = Date()
        insert(items: firstExpectedItems, timestamp: firstExpectedDate, to: sut, file: file, line: line)
        
        let lastExpectedItems = [uniqueFeed().local]
        let lastExpectedDate = Date()
        insertTwice(items: lastExpectedItems, timestamp: lastExpectedDate, to: sut, file: file, line: line)
        
        expect(sut, toReceive: .success((feed: lastExpectedItems, timestamp: lastExpectedDate)), file: file, line: line)
    }
    
    func assertThatDeleteDeliversSuccessOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let expectedItems = [uniqueFeed().local]
        let expectedDate = Date()
        
        insert(items: expectedItems, timestamp: expectedDate, to: sut, file: file, line: line)
        let receivedError = deleteCache(from: sut)
        expect(sut, toReceive: .success(.none), file: file, line: line)
        
        XCTAssertNil(receivedError, "Expect no error when delete an empty cache")
    }
    
}

extension FeedStoreSpecs where Self: XCTestCase {
    func expect(_ sut: FeedStore, toReceive expectedResult: FeedStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        
        let result = Result { try sut.retrievalCachedFeed() }
        switch (result, expectedResult) {
        case (.success(.none), .success(.none)): break
        case let (.success(.some((receivedItems, receivedTimestamp))), .success(.some((expectedItems, expectedTimestamp)))):
            XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            XCTAssertEqual(receivedTimestamp, expectedTimestamp, file: file, line: line)
        case (.failure, .failure): break
        default: XCTFail("Expect \(expectedResult) got \(result)", file: file, line: line)
        }
    }
    
    func expect(_ sut: FeedStore, toReceiveTwice expectedResult: FeedStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
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
        do {
            try sut.insertCachedFeed(items, timestamp: timestamp)
            return nil
        } catch {
            return error
        }
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
        do {
            try sut.deleteCachedFeed()
            return nil
        } catch {
            return error
        }
    }
    
}
