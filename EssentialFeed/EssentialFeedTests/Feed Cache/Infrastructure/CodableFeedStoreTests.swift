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
    
    func test_retrieve_deliversEmptyCacheOnEmptyCache() throws {
        let sut = makeSUT()
        
        assertThatRetrieveDeliversEmptyCacheOnEmptyCache(on: sut)
    }
    
    func test_retrieveTwice_deliversSameEmptyCacheOnEmptyCache() throws {
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectOnDeliversEmptyCache(on: sut)
    }

    
    func test_retrieve_deliversNonEmptyCacheOnNonEmptyCache() throws {
        let sut = makeSUT()
        
        assertThatRetrieveDeliversFoundCacheOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFoundCacheHasNoSideEffects() throws {
        let sut = makeSUT()
       
        assertThatRetrieveHasNoSideEffectOnDeliversFoundCache(on: sut)
    }
    
    func test_retrieve_deliversErrorWhenThereIsError() throws {
        let sut = makeSUT()
        let invalidData = Data("invalidData".utf8)
        
        try! invalidData.write(to: Self.testingURLSpecific)
        
        assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
    }
    
    func test_retrieve_deliversErrorWhenThereIsErrorHasNoSideEffect() throws {
        let sut = makeSUT()
        let invalidData = Data("invalidData".utf8)
        
        try! invalidData.write(to: Self.testingURLSpecific)
        
        assertThatRetrieveDeliversFailureHasNoSideEffectsOnRetrievalError(on: sut)
    }
    
    func test_insert_overridesExistingCacheOnNonEmptyCache() throws {
        let sut = makeSUT()
      
        assertThatInsertOverridesExistingCacheOnNonEmptyCache(on: sut)
    }
    
    func test_insert_overridesExistingCacheOnNonEmptyCacheHasNoSideEffect() throws {
        let sut = makeSUT()
      
        assertThatInsertOverridesExistingCacheOnNonEmptyCache(on: sut)
    }
    
    func test_insert_deliversErrorWhenThereIsError() throws {
        let invalidStoreURL = URL(string: "/invalid/path")!
        let sut = makeSUT(storeUrl: invalidStoreURL)
        
        assertThatInsertDeliversErrorOnInsertionError(on: sut)
    }
    
    func test_delete_deliversSuccessOnEmptyCache() throws {
        let sut = makeSUT()
        
        assertThatDeleteDeliversSuccessOnNonEmptyCache(on: sut)
    }
    
    func test_delete_deliversSuccessOnNonEmptyCache() throws {
        let sut = makeSUT()
        
        assertThatDeleteDeliversSuccessOnNonEmptyCache(on: sut)
    }
    
    func test_delete_deliversErrorWhenThereIsError() throws {
        let uneditableURLPath = URL(fileURLWithPath: "/")
        let sut = makeSUT(storeUrl: uneditableURLPath)
        
        assertThatDeleteDeliversErrorWhenDeletionError(on: sut)
    }
    
    // MARK: - Helpers
    func makeSUT(storeUrl: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeUrl: storeUrl ?? Self.testingURLSpecific, queue: .main)
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
