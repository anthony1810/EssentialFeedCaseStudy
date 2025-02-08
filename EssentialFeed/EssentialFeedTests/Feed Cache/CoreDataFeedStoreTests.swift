//
//  CoreDataFeedStoreTests.swift
//  EssentialFeed
//
//  Created by Anthony on 7/2/25.
//

import Foundation
import XCTest
import EssentialFeed

final class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    func test_retrieve_deliversEmptyCacheOnEmptyCache() throws {
        let sut = try makeSUT()
        
        assertThatRetrieveDeliversEmptyCacheOnEmptyCache(on: sut)
    }
    
    func test_retrieveTwice_deliversSameEmptyCacheOnEmptyCache() throws {
        let sut = try makeSUT()
        
        assertThatRetrieveHasNoSideEffectOnDeliversEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversNonEmptyCacheOnNonEmptyCache() throws {
        let sut = try makeSUT()
        
        assertThatRetrieveDeliversFoundCacheOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFoundCacheHasNoSideEffects() throws {
        let sut = try makeSUT()
        
        assertThatRetrieveHasNoSideEffectOnDeliversFoundCache(on: sut)
    }
    
    func test_insert_overridesExistingCacheOnNonEmptyCache() throws {
        let sut = try makeSUT()
        
        assertThatInsertOverridesExistingCacheOnNonEmptyCache(on: sut)
    }
    
    func test_insert_overridesExistingCacheOnNonEmptyCacheHasNoSideEffect() throws {
        let sut = try makeSUT()
        
        assertThatInsertHasNoSideEffectOverridesExistingCacheOnNonEmptyCache(on: sut)
    }
    
    func test_delete_deliversSuccessOnEmptyCache() throws {
        
    }
    
    func test_delete_deliversSuccessOnNonEmptyCache() throws {
        
    }
    
    func test_storeSideEffects_runSerially() throws {
        
    }
    
    // MARK: - Helpers
    func makeSUT(file: StaticString = #file, line: UInt = #line) throws -> FeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
