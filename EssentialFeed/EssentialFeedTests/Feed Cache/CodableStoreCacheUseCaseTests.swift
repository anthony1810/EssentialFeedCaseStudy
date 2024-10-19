//
//  CodableFeedCacheUseCaseTests.swift
//  EssentialFeed
//
//  Created by Anthony on 19/10/24.
//

import Foundation
import XCTest
import EssentialFeed

class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.empty)
    }
}

class CodableStoreCacheUseCaseTests: XCTestCase {
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for cache retrieval")
        var capturedResult: RetrievalResult?
        sut.retrieve { result in
            capturedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        switch capturedResult {
        case .empty: break
        default: XCTFail("expected empty cache, got result: \(capturedResult!)")
        }
    }
}
