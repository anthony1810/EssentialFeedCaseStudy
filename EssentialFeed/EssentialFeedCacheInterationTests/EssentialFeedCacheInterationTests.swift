//
//  EssentialFeedCacheInterationTests.swift
//  EssentialFeedCacheInterationTests
//
//  Created by Anthony on 8/2/25.
//

import XCTest
import EssentialFeed

final class EssentialFeedCacheInterationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        deleteStoreArtifacts()
    }
    
    override func tearDown() {
        super.tearDown()
        
        deleteStoreArtifacts()
    }
    
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
    
    func test_load_deliversItemsOnNonEmptyCache() throws {
        let sutToSave = try makeSUT()
        let sutToLoad = try makeSUT()
        
        let expectectedItems: [FeedImage] = [uniqueFeed().model]
        
        let exp = expectation(description: "Waiting for cache to save")
        sutToSave.save(expectectedItems) { error in
            if let error {
                XCTFail("Expect success but got \(error)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        let exp2 = expectation(description: "Waiting for cache to load")
        sutToLoad.load { result in
            switch result {
            case .success(let items):
                XCTAssertEqual(items, expectectedItems, "Expect \(expectectedItems) got \(items)")
            case .failure(let error):
                XCTFail("Expect success but got \(error)")
            }
            exp2.fulfill()
        }
        wait(for: [exp2], timeout: 1.0)
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
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: self.testSpecificStoreURL())
    }
    
}
