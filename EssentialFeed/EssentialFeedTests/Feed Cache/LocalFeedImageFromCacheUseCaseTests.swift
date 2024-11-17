//
//  LocalFeedImageFromCacheUseCaseTests.swift
//  EssentialFeed
//
//  Created by Anthony on 17/11/24.
//

import Foundation
import EssentialFeed
import XCTest

class RealmFeedImageStoreSpy {
    var receivedMessages: [Any] = []
}

class LocalFeedImageDataLoader {
    let store: RealmFeedImageStoreSpy
    
    init(store: RealmFeedImageStoreSpy) {
        self.store = store
    }
}

class LocalFeedImageFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreating() {
        let (store, _) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
}

extension LocalFeedImageFromCacheUseCaseTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (store: RealmFeedImageStoreSpy, sut: LocalFeedImageDataLoader) {
        
        let store = RealmFeedImageStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(store)
        
        return (store, sut)
    }
}
