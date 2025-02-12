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
        
        expect(sut, toFinishWith: .success([]))
    }
    
    func test_load_deliversItemsOnNonEmptyCache() throws {
        let sutToSave = try makeSUT()
        let sutToLoad = try makeSUT()
        
        let expectectedItems: [FeedImage] = [uniqueFeed().model]
        
        expect(sutToSave, toFinishSaveItems: expectectedItems, withError: nil)
        expect(sutToLoad, toFinishWith: .success(expectectedItems))
    }
    
    func test_save_overridesItemsSavedOnASeparateInstance() throws {
        let sutToPerformFirstSave = try makeSUT()
        let sutToPerformSecondSave = try makeSUT()
        let sutToPerformLoadAfterSecondSave = try makeSUT()
        
        let firstExpectectedItems: [FeedImage] = [uniqueFeed().model]
        let secondExpectectedItems: [FeedImage] = [uniqueFeed().model, uniqueFeed().model]
        
        expect(sutToPerformFirstSave, toFinishSaveItems: firstExpectectedItems, withError: nil)
        expect(sutToPerformSecondSave, toFinishSaveItems: secondExpectectedItems, withError: nil)
        expect(sutToPerformLoadAfterSecondSave, toFinishWith: .success(secondExpectectedItems))
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
     
    private func expect(_ sut: LocalFeedLoader, toFinishSaveItems items: [FeedImage], withError expectedError: Error?, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waiting for cache to save")
        sut.save(items) { receivedError in
            XCTAssertEqual(receivedError as NSError?, expectedError as NSError?, "Expected error \(String(describing: expectedError)), got \(String(describing: receivedError))", file: file, line: line)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: LocalFeedLoader, toFinishWith expectedResult: LocalFeedLoader.LoadResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waiting for cache to save")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as NSError?), .failure(expectedError as NSError?)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
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
