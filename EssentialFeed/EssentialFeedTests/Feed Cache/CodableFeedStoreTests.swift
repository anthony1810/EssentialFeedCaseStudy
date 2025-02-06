//
//  CodableFeedStoreTests.swift
//  EssentialFeed
//
//  Created by Anthony on 3/2/25.
//

import Foundation
import XCTest
import EssentialFeed

final class CodableFeedStoreTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        
        deleteStoreArtifacts()
    }
    
    override func setUp() {
        super.setUp()
        
        deleteStoreArtifacts()
    }
    
    func test_retrieve_deliversEmptyCacheOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toReceive: .empty)
    }
    
    func test_retrieveTwice_deliversSameEmptyCacheOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toReceive: .empty)
        expect(sut, toReceive: .empty)
    }

    
    func test_retrieve_deliversNonEmptyCacheOnNonEmptyCache() {
        let expectedItems = [uniqueFeed().local]
        let expectedDate = Date()
        let sut = makeSUT()
        
        let error = insert(items: expectedItems, timestamp: expectedDate, to: sut)
        XCTAssertNil(error, "expected no error when insert cache")
        expect(sut, toReceive: .found(feed: expectedItems, timestamp: expectedDate))
    }
    
    func test_retrieve_deliversFoundCacheHasNoSideEffects() {
        let expectedItems = [uniqueFeed().local]
        let expectedDate = Date()
        let sut = makeSUT()
        
        let error = insert(items: expectedItems, timestamp: expectedDate, to: sut)
        XCTAssertNil(error, "expected no error when insert cache")
        
        expect(sut, toReceiveTwice: .found(feed: expectedItems, timestamp: expectedDate))
    }
    
    func test_retrieve_deliversErrorWhenThereIsError() {
        let sut = makeSUT()
        let expectedError = anyNSError()
        let invalidData = Data("invalidData".utf8)
        
        try! invalidData.write(to: Self.testingURLSpecific)
        
        expect(sut, toReceive: .failure(expectedError))
    }
    
    func test_retrieve_deliversErrorWhenThereIsErrorHasNoSideEffect() {
        let sut = makeSUT()
        let expectedError = anyNSError()
        let invalidData = Data("invalidData".utf8)
        
        try! invalidData.write(to: Self.testingURLSpecific)
        
        expect(sut, toReceiveTwice: .failure(expectedError))
    }
    
    func test_insert_overridesExistingCacheOnNonEmptyCache() {
        let sut = makeSUT()
      
        let firstExpectedItems = [uniqueFeed().local]
        let firstExpectedDate = Date()
        insert(items: firstExpectedItems, timestamp: firstExpectedDate, to: sut)
        
        let lastExpectedItems = [uniqueFeed().local]
        let lastExpectedDate = Date()
        insert(items: lastExpectedItems, timestamp: lastExpectedDate, to: sut)
        
        expect(sut, toReceive: .found(feed: lastExpectedItems, timestamp: lastExpectedDate))
    }
    
    func test_insert_overridesExistingCacheOnNonEmptyCacheHasNoSideEffect() {
        let sut = makeSUT()
      
        let firstExpectedItems = [uniqueFeed().local]
        let firstExpectedDate = Date()
        insert(items: firstExpectedItems, timestamp: firstExpectedDate, to: sut)
        
        let lastExpectedItems = [uniqueFeed().local]
        let lastExpectedDate = Date()
        insertTwice(items: lastExpectedItems, timestamp: lastExpectedDate, to: sut)
        
        expect(sut, toReceive: .found(feed: lastExpectedItems, timestamp: lastExpectedDate))
    }
    
    func test_insert_deliversErrorWhenThereIsError() {
        let invalidStoreURL = URL(string: "/invalid/path")!
        let sut = makeSUT(storeUrl: invalidStoreURL)
        
        let expectedItems = [uniqueFeed().local]
        let expectedDate = Date()
        
        let receiveError = insert(items: expectedItems, timestamp: expectedDate, to: sut)
        
        XCTAssertNotNil(receiveError, "Expected error when insertion encounter error")
    }
    
    func test_delete_deliversSuccessOnEmptyCache() {
        let sut = makeSUT()
        
        let receivedError = deleteCache(from: sut)
        XCTAssertNil(receivedError, "Expect no error when delete an empty cache")
    }
    
    func test_delete_deliversSuccessOnNonEmptyCache() {
        let sut = makeSUT()
        
        let expectedItems = [uniqueFeed().local]
        let expectedDate = Date()
        
        insert(items: expectedItems, timestamp: expectedDate, to: sut)
        let receivedError = deleteCache(from: sut)
        expect(sut, toReceive: .empty)
        
        XCTAssertNil(receivedError, "Expect no error when delete an empty cache")
    }
    
    func test_delete_deliversErrorWhenThereIsError() {
        let uneditableURLPath = Self.cacheDirectory
        let sut = makeSUT(storeUrl: uneditableURLPath)
        
        let receivedError = deleteCache(from: sut)
        XCTAssertNotNil(receivedError, "Expect no error when delete an empty cache")
    }
    
    // MARK: - Helpers
    func makeSUT(storeUrl: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeUrl: storeUrl ?? Self.testingURLSpecific)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
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
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: Self.testingURLSpecific)
    }
    
    private static var testingURLSpecific: URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("\(type(of: self)).store")
    }
    
    private static var cacheDirectory: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
