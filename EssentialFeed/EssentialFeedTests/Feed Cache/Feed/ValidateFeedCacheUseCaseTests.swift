//
//  Untitled.swift
//  EssentialFeed
//
//  Created by Anthony on 19/10/24.
//

import Foundation
import XCTest
import EssentialFeed

final class EssentialFeedTests: FeedCacheTests {
    func test_init_doesNotMessageStoreUponCreation() {
        let (store, _) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deleteCacheOnRetrieveError() {
        let (store, sut) = makeSUT()
        let expectedError = makeAnyError()
        
        sut.validateCache(completion: {_ in })
        store.completeRetrieval(error: expectedError)
        
        XCTAssertEqual(store.receivedMessages, [.retrieved, .deletedCache])
    }
    
    func test_validateCache_deleteCacheWithCacheOnMoreThanExpireDate() {
        let sevenDaysBeforeToday = Date().minusCacheMaxAgeInDays.addingSeconds(-1)
        let (store, sut) = makeSUT(timestamp: Date.init)
    
        sut.validateCache(completion: {_ in })
        store.completeRetrieval(with: [], timestamp: sevenDaysBeforeToday)
        
        XCTAssertEqual(store.receivedMessages, [.retrieved, .deletedCache])
    }
    
    func test_load_doesNotDeleteCacheOnRetrieveSuccess() {
        let (store, sut) = makeSUT()
        
        sut.validateCache(completion: {_ in })
        store.completeRetrievalSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.retrieved])
    }
    
    func test_load_doesNotDeleteCacheOnLessThenExpireDate() {
        let (store, sut) = makeSUT()
        let expectedFeed = uniqueItem()
        let sevenDaysBeforeToday = Date().minusCacheMaxAgeInDays.addingSeconds(1)
        
        sut.validateCache(completion: {_ in })
        store.completeRetrieval(with: [expectedFeed.localModel], timestamp: sevenDaysBeforeToday)
        
        XCTAssertEqual(store.receivedMessages, [.retrieved])
    }
    
    func test_load_doesNotDeleteCacheWhenInstanceDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, timestamp: Date.init)
        
        sut?.validateCache(completion: {_ in })
        sut = nil
        store.completeRetrievalSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.retrieved])
    }
}
