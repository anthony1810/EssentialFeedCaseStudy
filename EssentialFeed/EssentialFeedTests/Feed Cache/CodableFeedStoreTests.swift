//
//  CodableFeedStoreTests.swift
//  EssentialFeed
//
//  Created by Anthony on 3/2/25.
//

import Foundation
import XCTest
import EssentialFeed

final class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpecs {
    
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
        
        assertThatRetrieveDeliversEmptyCacheOnEmptyCache(on: sut)
    }
    
    func test_retrieveTwice_deliversSameEmptyCacheOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectOnDeliversEmptyCache(on: sut)
    }

    
    func test_retrieve_deliversNonEmptyCacheOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveDeliversFoundCacheOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFoundCacheHasNoSideEffects() {
        let sut = makeSUT()
       
        assertThatRetrieveHasNoSideEffectOnDeliversFoundCache(on: sut)
    }
    
    func test_retrieve_deliversErrorWhenThereIsError() {
        let sut = makeSUT()
        let invalidData = Data("invalidData".utf8)
        
        try! invalidData.write(to: Self.testingURLSpecific)
        
        assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
    }
    
    func test_retrieve_deliversErrorWhenThereIsErrorHasNoSideEffect() {
        let sut = makeSUT()
        let invalidData = Data("invalidData".utf8)
        
        try! invalidData.write(to: Self.testingURLSpecific)
        
        assertThatRetrieveDeliversFailureHasNoSideEffectsOnRetrievalError(on: sut)
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
      
        assertThatInsertOverridesExistingCacheOnNonEmptyCache(on: sut)
    }
    
    func test_insert_deliversErrorWhenThereIsError() {
        let invalidStoreURL = URL(string: "/invalid/path")!
        let sut = makeSUT(storeUrl: invalidStoreURL)
        
        assertThatInsertDeliversErrorOnInsertionError(on: sut)
    }
    
    func test_delete_deliversSuccessOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatDeleteDeliversSuccessOnNonEmptyCache(on: sut)
    }
    
    func test_delete_deliversSuccessOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatDeleteDeliversSuccessOnNonEmptyCache(on: sut)
    }
    
    func test_delete_deliversErrorWhenThereIsError() {
        let uneditableURLPath = Self.cacheDirectory
        let sut = makeSUT(storeUrl: uneditableURLPath)
        
        assertThatDeleteDeliversErrorWhenDeletionError(on: sut)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
       
        assertThatSideEffectsRunSerially(on: sut)
    }
    
    // MARK: - Helpers
    func makeSUT(storeUrl: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeUrl: storeUrl ?? Self.testingURLSpecific)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return sut
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
