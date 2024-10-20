//
//  CoreDataFeedStoreUseCaseTests.swift
//  EssentialFeed
//
//  Created by Anthony on 20/10/24.
//

import Foundation
import XCTest
import EssentialFeed

class CoreDataFeedStore: FeedStore {
    func deleteCache(completion: @escaping DeletionCacheCompletion) {
        
    }
    
    func insertCache(_ items: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCacheCompletion) {
        
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
}

class CoreDataFeedStoreUseCaseTests: FeedCacheTests, FailableFeedStore {
   
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        expect(sut: sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        expect(sut: sut, toRetrieve: .empty)
        expect(sut: sut, toRetrieve: .empty)
    }
    
    func test_retrieve_insertThenRetrieveExpectedvalue() {
        
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        
    }
    
    func test_retrieve_hasNoSideEffectsOnRetrievalError() {
        
    }

    func test_insert_overridePreviousValue() {
        
    }
    
    func test_insert_deliversErrorWhenEncounterFailure() {
        
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        
    }
    func test_delete_emptiesPreviouslyInsertedCache() {
        
    }
    
    func test_delete_deliversErrorOnDeletionFailure() {
        
    }

    func test_runSerially_executesTasksInOrder() {
        
    }
    
}

extension CoreDataFeedStoreUseCaseTests {
    func makeSUT() -> FeedStore {
        let sut = CoreDataFeedStore()
        
        return sut
    }
}
