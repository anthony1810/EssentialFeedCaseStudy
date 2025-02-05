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

    
    // MARK: - Helpers
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeUrl: Self.testingURLSpecific)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    func expect(_ sut: CodableFeedStore, toReceive expectedResult: RetrieveCacheFeedResult, file: StaticString = #filePath, line: UInt = #line) {
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
    
    @discardableResult
    func insert(
        items: [LocalFeedImage],
        timestamp: Date,
        to sut: CodableFeedStore,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Error? {
        let exp = expectation(description: "Waiting for completion")
        
        var receivedError: Error?
        sut.insertCachedFeed(items, timestamp: timestamp) { receivedError = $0; exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
        
        return receivedError
    }
    
    func expect(_ sut: CodableFeedStore, toReceiveTwice expectedResult: RetrieveCacheFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toReceive: expectedResult)
        expect(sut, toReceive: expectedResult)
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: Self.testingURLSpecific)
    }
    
    private static var testingURLSpecific: URL {
        return FileManager.default.temporaryDirectory
            .appendingPathComponent("\(type(of: self)).store")
    }
}
