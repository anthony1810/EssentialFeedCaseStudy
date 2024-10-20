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
    
    private struct CodableFeedImage: Equatable, Codable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let url: URL
        
        public init(id: UUID, description: String?, location: String?, url: URL) {
            self.id = id
            self.description = description
            self.location = location
            self.url = url
        }
        
        init(feedImage: LocalFeedImage) {
            self.id = feedImage.id
            self.description = feedImage.description
            self.location = feedImage.location
            self.url = feedImage.url
        }
        
        func toLocalFeedImage() -> LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    private struct Cache: Codable {
        let items: [CodableFeedImage]
        let timestamp: Date
        
        var feedImages: [LocalFeedImage] {
            items.map { $0.toLocalFeedImage() }
        }
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        do {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.empty)
            }
            let cache = try JSONDecoder().decode(Cache.self, from: data)
            completion(.success(cache.feedImages, cache.timestamp))
        } catch {
            completion(.failure(error))
        }
        
    }
    
    func insertCache(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCacheCompletion) {
        
        let encoder = JSONEncoder()
        let cache = Cache(items: items.map { CodableFeedImage(feedImage: $0) }, timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        
        completion(nil)
    }
}

class CodableStoreCacheUseCaseTests: FeedCacheTests {
    
    override func setUp() {
        super.setUp()
        
        setUpState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        clearUpState()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        
        let sut = makeSUT(storeURL: nil)
        
        expect(sut: sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT(storeURL: nil)
    
        expect(sut: sut, toRetrieve: .empty)
        expect(sut: sut, toRetrieve: .empty)
    }
    
    func test_retrieve_insertThenRetrieveExpectedvalue() {
        let sut = makeSUT(storeURL: nil)
        let expectedItem = uniqueItem().localModel
        let timeStamp = Date()
        
        expect(sut: sut, toInsertFeed: [expectedItem], timestamp: timeStamp, WithError: nil)
        expect(sut: sut, toRetrieve: .success([expectedItem], timeStamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT(storeURL: nil)
        let expectedItem = uniqueItem().localModel
        let expectedTimeStamp = Date()
        
        expect(sut: sut, toInsertFeed: [expectedItem], timestamp: expectedTimeStamp, WithError: nil)
        expect(sut: sut, toRetrieve: .success([expectedItem], expectedTimeStamp))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let testStoreURL = testSpecificStoreURL
        let sut = makeSUT(storeURL: testStoreURL)
        let expectedError = makeAnyError()
        
        try! "invalidData".write(to: testStoreURL, atomically: false, encoding: .utf8)
        
        expect(sut: sut, toRetrieve: .failure(expectedError))
    }
    
    func test_retrieve_hasNoSideEffectsOnRetrievalError() {
        let testStoreURL = testSpecificStoreURL
        let sut = makeSUT(storeURL: testStoreURL)
        let expectedError = makeAnyError()
        
        try! "invalidData".write(to: testStoreURL, atomically: false, encoding: .utf8)
        
        expect(sut: sut, toRetrieve: .failure(expectedError))
        expect(sut: sut, toRetrieve: .failure(expectedError))
    }
    
    func test_insert_overridePreviousValue() {
        let sut = makeSUT(storeURL: nil)
        
        let expectedItem = uniqueItem().localModel
        let expectedItem2 = uniqueItem().localModel
        let expectedTimeStamp = Date()
        
        expect(sut: sut, toInsertFeed: [expectedItem], timestamp: expectedTimeStamp, WithError: nil)
        expect(sut: sut, toInsertFeed: [expectedItem2], timestamp: expectedTimeStamp, WithError: nil)
        expect(sut: sut, toInsertFeed: [expectedItem2], timestamp: expectedTimeStamp, WithError: nil)
    }
}

// MARK: - Helpers
extension CodableStoreCacheUseCaseTests {
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    func expect(sut: CodableFeedStore, toRetrieve expectedResult: RetrievalResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        var capturedResult: RetrievalResult?
        
        sut.retrieve { result in
            capturedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        switch (capturedResult, expectedResult) {
        case (.empty, .empty):
            break
        case let (.success(actualFeedItems, actualTimestamp), (.success(expectedFeedItems, expectedTimestamp))):
            XCTAssertEqual(actualFeedItems, expectedFeedItems, file: file, line: line)
            XCTAssertEqual(actualTimestamp, expectedTimestamp, file: file, line: line)
        case (.failure, (.failure)):
            break
        default:
            XCTFail("expected \(expectedResult), got result: \(capturedResult!)", file: file, line: line)
        }
    }
    
    func expect(sut: CodableFeedStore, toInsertFeed feeds: [LocalFeedImage], timestamp: Date, WithError expectedError: Error?, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
      
        var capturedError: Error?
        sut.insertCache(feeds, timestamp: timestamp) { error in
            capturedError = error
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(capturedError as NSError?, expectedError as NSError?, file: file, line: line)
    }
    
    
    var testSpecificStoreURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self))")
    }
    
    func setUpState() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL)
    }
    
    func clearUpState() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL)
    }
}
