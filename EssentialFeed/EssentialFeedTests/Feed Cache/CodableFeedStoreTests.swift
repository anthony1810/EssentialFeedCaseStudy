//
//  CodableFeedStoreTests.swift
//  EssentialFeed
//
//  Created by Anthony on 3/2/25.
//

import Foundation
import XCTest
import EssentialFeed

final class CodableFeedStore {
    
    func retrievalCachedFeed(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.empty)
    }
}

final class CodableFeedStoreTests: XCTestCase {
    func test_retrieve_deliversEmptyCacheOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "Waitng for completion")
        
        sut.retrievalCachedFeed { result in
            switch result {
            case .empty: break
            default: XCTFail("Expect empty cache got \(result)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveTwice_deliversSameEmptyCacheOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "Waitng for completion")
        
        sut.retrievalCachedFeed { result in
            sut.retrievalCachedFeed { result in
                switch result {
                case .empty: break
                default: XCTFail("Expect empty cache got \(result)")
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
