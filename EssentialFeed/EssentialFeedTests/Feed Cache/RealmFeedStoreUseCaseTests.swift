//
//  CoreDataFeedStoreUseCaseTests.swift
//  EssentialFeed
//
//  Created by Anthony on 20/10/24.
//

import Foundation
import XCTest
import EssentialFeed


class RealmFeedStoreUseCaseTests: FeedCacheTests, FailableFeedStore, FeedStoreTestSpecs {

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
        let sut = makeSUT()
        let expectedItem = uniqueItem().localModel
        let timeStamp = Date()
        
        expect(sut: sut, toInsertFeed: [expectedItem], timestamp: timeStamp, WithError: nil)
        expect(sut: sut, toRetrieve: .success([expectedItem], timeStamp))
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

extension RealmFeedStoreUseCaseTests {
    func makeSUT() -> FeedStoreProtocol {
        let sut = RealmFeedStore()
        trackForMemoryLeaks(sut)
        return sut
    }
}
