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
        
        sut.validateCache()
        store.completeRetrieval(error: expectedError)
        
        XCTAssertEqual(store.receivedMessages, [.retrieved, .deletedCache])
    }
}
