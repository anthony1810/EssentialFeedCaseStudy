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
        let sut = makeSUT()
        let expectedItem = uniqueItem().localModel
        let timeStamp = Date()
        
        expect(sut: sut, toInsertFeed: [expectedItem], timestamp: timeStamp, WithError: nil)
        expect(sut: sut, toRetrieve: .success([expectedItem], timeStamp))
    }
    
    func test_insert_deliversErrorWhenEncounterFailure() {
        let invalidConfig = Realm.Configuration(fileURL: URL(string: "/dev/null"))
        let sut = makeSUT(configuration: invalidConfig)
        
        expect(sut: sut, toInsertFeed: [], timestamp: Date(), WithError: makeAnyError())
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut: sut, toDeleteWithError: nil)
        expect(sut: sut, toDeleteWithError: nil)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        let expectedItem = uniqueItem().localModel
        let timestamp = Date()
        
        expect(sut: sut, toInsertFeed: [expectedItem], timestamp: timestamp, WithError: nil)
        expect(sut: sut, toDeleteWithError: nil)
        expect(sut: sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionFailure() {
        let invalidConfig = Realm.Configuration(fileURL: URL(string: "/dev/null"))
        let sut = makeSUT(configuration: invalidConfig)
        let expectedError = makeAnyError()
        
        expect(sut: sut, toDeleteWithError: expectedError)
    }

    func test_runSerially_executesTasksInOrder() {
        let sut = makeSUT()
        let timestamp = Date()
        let expectedItem = uniqueItem().localModel
        
        var completionExpectations = [XCTestExpectation]()
        
        let op1 = expectation(description: "inserted")
        sut.insertCache([expectedItem], timestamp: timestamp) { _ in
            completionExpectations.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "deleted")
        sut.deleteCache(completion: { _ in
            completionExpectations.append(op2)
            op2.fulfill()
        })
        
        let op3 = expectation(description: "inserted 2")
        sut.insertCache([expectedItem], timestamp: timestamp) { _ in
            completionExpectations.append(op3)
            op3.fulfill()
        }
        
        let op4 = expectation(description: "retrieved")
        sut.retrieve { _ in
            completionExpectations.append(op4)
            op4.fulfill()
        }
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(completionExpectations, [op1, op2, op3, op4])
    }
    
}

extension RealmFeedStoreUseCaseTests {
    func makeSUT(configuration: Realm.Configuration = .defaultConfiguration) -> FeedStoreProtocol {
        let sut = RealmFeedStore(realmConfig: configuration)
        trackForMemoryLeaks(sut)
        return sut
    }
}
