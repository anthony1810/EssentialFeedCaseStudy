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
    
    func test_loadFeed_deliversNoItemsOnEmptyCache() throws {
        let sut = try makeFeedLoader()
        
        expect(sut, toFinishWith: .success([]))
    }
    
    func test_loadFeed_deliversItemsOnNonEmptyCache() throws {
        let sutToSave = try makeFeedLoader()
        let sutToLoad = try makeFeedLoader()
        
        let expectectedItems: [FeedImage] = [uniqueFeed().model]
        
        expect(sutToSave, toFinishSaveItems: expectectedItems, withError: nil)
        expect(sutToLoad, toFinishWith: .success(expectectedItems))
    }
    
    func test_saveFeed_overridesItemsSavedOnASeparateInstance() throws {
        let sutToPerformFirstSave = try makeFeedLoader()
        let sutToPerformSecondSave = try makeFeedLoader()
        let sutToPerformLoadAfterSecondSave = try makeFeedLoader()
        
        let firstExpectectedItems: [FeedImage] = [uniqueFeed().model]
        let secondExpectectedItems: [FeedImage] = [uniqueFeed().model, uniqueFeed().model]
        
        expect(sutToPerformFirstSave, toFinishSaveItems: firstExpectectedItems, withError: nil)
        expect(sutToPerformSecondSave, toFinishSaveItems: secondExpectectedItems, withError: nil)
        expect(sutToPerformLoadAfterSecondSave, toFinishWith: .success(secondExpectectedItems))
    }
    
    func test_loadImageData_deliversSaveDataOnASeparateInstance() throws {
        let imageLoaderToSave = try makeFeedImageLoader()
        let imageLoaderToLoad = try makeFeedImageLoader()
        let feedLoaderToSave = try makeFeedLoader()
        let image = uniqueFeed()
        let dataToSave = anydata()
        let url = anyURL()
        
        expect(feedLoaderToSave, toFinishSaveItems: [image.model], withError: nil)
        save(dataToSave, for: url, with: imageLoaderToSave)
        expect(imageLoaderToLoad, toLoad: dataToSave, for: url)
    }
    
    func test_saveImageData_overridesSavedImageDataOnASeparateInstance() throws {
        let imageLoaderToSaveFirst = try makeFeedImageLoader()
        let imageLoaderToSaveSecond = try makeFeedImageLoader()
        let imageLoaderToLoad = try makeFeedImageLoader()
        
        let feedLoader = try makeFeedLoader()
        let image = uniqueFeed()
        let urlToSave = anyURL()
        let dataToSaveFirst: Data = Data("first".utf8)
        let dataToSaveSecond: Data = Data("second".utf8)
        
        expect(feedLoader, toFinishSaveItems: [image.model], withError: nil)
        save(dataToSaveFirst, for: urlToSave, with: imageLoaderToSaveFirst)
        save(dataToSaveSecond, for: urlToSave, with: imageLoaderToSaveSecond)
        expect(imageLoaderToLoad, toLoad: dataToSaveSecond, for: urlToSave)
    }
    
    func test_validateCacheFeed_doesNotDeleteRecentlySaveFeed() throws {
        let feedLoaderToSave = try makeFeedLoader()
        let feedLoaderToPerformValidation = try makeFeedLoader()
        let image = uniqueFeed().model
        
        expect(feedLoaderToSave, toFinishSaveItems: [image], withError: nil)
        validateCache(with: feedLoaderToPerformValidation)
        expect(feedLoaderToSave, toFinishWith: .success([image]))
    }
    
    func test_validateFeedCache_deletesFeedSavedInADistantPast() throws {
        let feedLoaderToSave = try makeFeedLoader(
            currentDate: { Date.distantPast }
        )
        let feedLoaderToPerformValidation = try makeFeedLoader()
        let image = uniqueFeed().model
        
        expect(feedLoaderToSave, toFinishSaveItems: [image], withError: nil)
        validateCache(with: feedLoaderToPerformValidation)
        expect(feedLoaderToSave, toFinishWith: .success([]))
    }
    
    // MARK: - FeedLoader Helpers
    private func makeFeedLoader(
        currentDate: @escaping () -> Date = { Date.now },
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> LocalFeedLoader {
        let storeURL = testSpecificStoreURL()
        let store = try CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(store, file: file, line: line)
        
        return sut
    }
    
    private func expect(
        _ sut: LocalFeedLoader,
        toFinishSaveItems items: [FeedImage],
        withError expectedError: Error?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Waiting for cache to save")
        sut.save(items) { receivedError in
            XCTAssertEqual(receivedError as NSError?, expectedError as NSError?, "Expected error \(String(describing: expectedError)), got \(String(describing: receivedError))", file: file, line: line)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(
        _ sut: LocalFeedLoader,
        toFinishWith expectedResult: LocalFeedLoader.LoadResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
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
    
    func validateCache(with loader: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
        
        let saveExp = expectation(description: "Save expectation")
        loader.validate { completion in
            if case let .failure(error) = completion {
                XCTFail("Validation failed with error: \(error)", file: file, line: line)
            }
            saveExp.fulfill()
        }
        
        wait(for: [saveExp], timeout: 1.0)
    }
    
    // MARK: - FeedImageLoader Helpers
    private func makeFeedImageLoader(
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> LocalFeedImageDataLoader {
        let storeURL = testSpecificStoreURL()
        let store = try CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedImageDataLoader(store: store)
        
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(store, file: file, line: line)
        
        return sut
    }
    
    private func save(
        _ data: Data,
        for url: URL,
        with loader: LocalFeedImageDataLoader,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let result = Result { try loader.save(data, for: url) }
        if case let .failure(error) = result {
            XCTFail("Expect to save image data successfully, got error: \(error)", file: file, line: line)
        }
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toLoad expectedData: Data, for url: URL, file: StaticString = #file, line: UInt = #line) {

        let result = Result { try sut.loadImageData(from: url) }
        switch result {
        case let .success(loadedData):
            XCTAssertEqual(expectedData, loadedData, file: file, line: line)
        case let .failure(error):
            XCTFail("Expected to load image data successfully, got error: \(error)", file: file, line: line)
        }
    }
     
   
    // MARK: - Helpers
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
