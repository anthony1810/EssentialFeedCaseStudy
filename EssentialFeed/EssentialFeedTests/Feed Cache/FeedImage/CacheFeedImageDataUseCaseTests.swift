//
//  CacheFeedImageDataUseCaseTests.swift
//  EssentialFeed
//
//  Created by Anthony on 17/11/24.
//

import Foundation
import EssentialFeed
import XCTest

class CacheFeedImageDataUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreating() {
        let (store, _) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_saveImageData_requestsURLInsertionIntoStore() {
        let (store, sut) = makeSUT()
        let imageData = makeAnyData()
        let imageURL = makeAnyUrl()
        
        sut.save(imageData, for: imageURL){ _ in }
        
        XCTAssertEqual(store.receivedMessages, [.insert(imageData, for: imageURL)])
    }
}

extension CacheFeedImageDataUseCaseTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (store: LocalFeedImageStoreSpy, sut: LocalFeedImageDataLoader) {
        
        let store = LocalFeedImageStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (store, sut)
    }
}
