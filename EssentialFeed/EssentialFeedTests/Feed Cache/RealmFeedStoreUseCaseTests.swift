//
//  CoreDataFeedStoreUseCaseTests.swift
//  EssentialFeed
//
//  Created by Anthony on 20/10/24.
//

import Foundation
import XCTest
import EssentialFeed
import RealmSwift


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
        let sut = makeSUT()
        let expectedItem = uniqueItem().localModel
        let timeStamp = Date()
        
        expect(sut: sut, toRetrieve: .success([expectedItem], timeStamp))
        expect(sut: sut, toRetrieve: .success([expectedItem], timeStamp))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let invalidConfig = Realm.Configuration(fileURL: URL(string: "/dev/null"))
        let sut = makeSUT(configuration: invalidConfig)
        
        expect(sut: sut, toRetrieve: .failure(makeAnyError()))
    }
    
    func test_retrieve_hasNoSideEffectsOnRetrievalError() {
        let invalidConfig = Realm.Configuration(fileURL: URL(string: "/dev/null"))
        let sut = makeSUT(configuration: invalidConfig)
        
        expect(sut: sut, toRetrieve: .failure(makeAnyError()))
        expect(sut: sut, toRetrieve: .failure(makeAnyError()))
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
    func makeSUT(configuration: Realm.Configuration = .defaultConfiguration) -> FeedStoreProtocol {
        let sut = RealmFeedStore(realmConfig: configuration)
        trackForMemoryLeaks(sut)
        return sut
    }
}
