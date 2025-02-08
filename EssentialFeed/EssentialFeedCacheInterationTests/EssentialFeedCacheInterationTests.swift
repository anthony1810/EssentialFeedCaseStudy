//
//  EssentialFeedCacheInterationTests.swift
//  EssentialFeedCacheInterationTests
//
//  Created by Anthony on 8/2/25.
//

import XCTest
import EssentialFeed

final class EssentialFeedCacheInterationTests: XCTestCase {
    func test_load_deliversNoItemsOnEmptyCache() throws {
        let sut = try makeSUT()
        
        let exp = expectation(description: "Waiting for cache to load")
        sut.load { result in
            switch result {
            case .success(let items):
                XCTAssertEqual(items, [], "Expect empty items got \(items)")
            case .failure(let error):
                XCTFail("Expect success but got \(error)")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) throws -> LocalFeedLoader {
        let storeURL = testSpecificStoreURL()
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let store = try CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(store, file: file, line: line)
        
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        cacheDirectoryURL().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cacheDirectoryURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
}
