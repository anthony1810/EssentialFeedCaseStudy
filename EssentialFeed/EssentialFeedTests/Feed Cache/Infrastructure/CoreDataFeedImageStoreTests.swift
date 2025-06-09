//
//  CoreDataFeedImageStoreTests.swift
//  EssentialFeed
//
//  Created by Anthony on 16/4/25.
//

import XCTest
import EssentialFeed

final class CoreDataFeedImageStoreTests: XCTestCase {
    
    func test_retrieveImageData_deliversNotFoundWhenEmpty() throws {
        let sut = try makeSUT()
       
        expect(sut, toCompleteRetrieveWith: notFound(), for: anyURL())
    }
    
    func test_retrieveImageData_deliversNotFoundWhenStoredDataURLNotMatch() throws {
        let sut = try makeSUT()
        
        let url = URL(string: "https://a-url.com")!
        let aNonMatchingURL = URL(string: "https://example.com/2")!
        
        insert(anydata(), for: url, into: sut)
        expect(sut, toCompleteRetrieveWith: notFound(), for: aNonMatchingURL)
    }
    
    func test_retrieveImageData_deliversFoundDataWhenThereIsStoredImageDataMatchingTheURL() throws {
        let sut = try makeSUT()
        let storedData = anydata()
        let url = URL(string: "https://a-url.com")!
        
        insert(anydata(), for: url, into: sut)
        expect(sut, toCompleteRetrieveWith: .success(storedData), for: url)
    }
    
    func test_retrieveImageData_deliversLastInsertedValue() throws {
        let sut = try makeSUT()
        let storedData = Data("first".utf8)
        let overrideStoredData = Data("second".utf8)
        let url = URL(string: "https://a-url.com")!
        
        insert(storedData, for: url, into: sut)
        insert(overrideStoredData, for: url, into: sut)
        expect(sut, toCompleteRetrieveWith: .success(overrideStoredData), for: url)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) throws -> CoreDataFeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func expect(
        _ sut: FeedImageDataStore,
        toCompleteRetrieveWith expectedResult: FeedImageDataStore.RetrievalResult,
        for url: URL,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        let expectation = self.expectation(description: "waiting for completion")
        sut.retrieve(dataForURL: url) { actualResult in
            switch (actualResult, expectedResult) {
            case let (.success(actualData), .success(expectedData)):
                XCTAssertEqual(actualData, expectedData, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(actualResult) instead", file: file, line: line)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    private func insert(
        _ data: Data,
        for url: URL,
        into sut: CoreDataFeedStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        let expectation = self.expectation(description: "waiting for completion")
        let image = localImage(url: url)
        
        sut.insertCachedFeed([image], timestamp: Date()) { result in
            switch result {
            case let .failure(error):
                XCTFail("Failed to save \(image) with error = \(error)", file: file, line: line)
            case .success:
                sut.insert(data, for: url) { result in
                    if case let Result.failure(error) = result {
                        XCTFail("Failed to insert data for \(url) with error = \(error)")
                    }
                }
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    private func notFound() -> FeedImageDataStore.RetrievalResult {
        .success(.none)
    }
    
    private func localImage(url: URL) -> LocalFeedImage {
        LocalFeedImage(id: UUID(), description: nil, location: nil, imageURL: url)
    }
    
}
