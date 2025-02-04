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
        let exp = expectation(description: "Waitng for completion")
        
        sut.retrievalCachedFeed { result in
            switch result {
            case .empty: break
            default: XCTFail("Expect empty cache got \(result)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveTwice_deliversSameEmptyCacheOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Waitng for completion")
        
        sut.retrievalCachedFeed { result in
            sut.retrievalCachedFeed { result in
                switch result {
                case .empty: break
                default: XCTFail("Expect empty cache got \(result)")
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_deliversNonEmptyCacheOnNonEmptyCache() {
        let expectedItems = [uniqueFeed().local]
        let expectedDate = Date()
        let sut = makeSUT()
        let exp = expectation(description: "Waiting for completion")
        
        sut.insertCachedFeed(expectedItems, timestamp: expectedDate) { error in
            XCTAssertNil(error, "expected no error when insert cache")
            sut.retrievalCachedFeed { result in
                switch result {
                case let .found(receivedItems, receivedTimestamp):
                    XCTAssertEqual(receivedItems, expectedItems)
                    XCTAssertEqual(receivedTimestamp, expectedDate)
                default: XCTFail("Expect non empty cache got \(result)")
                }
                
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeUrl: Self.testingURLSpecific)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: Self.testingURLSpecific)
    }
    
    private static var testingURLSpecific: URL {
        return FileManager.default.temporaryDirectory
            .appendingPathComponent("\(type(of: self)).store")
    }
}
