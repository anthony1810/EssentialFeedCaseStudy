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
    
    let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    struct Cache: Codable {
        let items: [LocalFeedImage]
        let timestamp: Date
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        do {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.empty)
            }
            let cache = try JSONDecoder().decode(Cache.self, from: data)
            completion(.success(cache.items, cache.timestamp))
        } catch {
            completion(.failure(error))
        }
       
    }
    
    func insertCache(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCacheCompletion) {
        
        let encoder = JSONEncoder()
        let cache = Cache(items: items, timestamp: timestamp)
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
    
    func setUpState() {
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    func clearUpState() {
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
       
        let sut = makeSUT()
        
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
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for cache retrieval")
        var firstCapturedResult: RetrievalResult?
        var secondCapturedResult: RetrievalResult?
        sut.retrieve { firstResult in
            firstCapturedResult = firstResult
            sut.retrieve { secondResult in
                secondCapturedResult = secondResult
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
        
        switch (firstCapturedResult, secondCapturedResult) {
        case (.empty, .empty): break
        default: XCTFail("expected empty cache, got different result)")
        }
    }
    
    func test_retrieve_insertThenRetrieveExpectedvalue() {
        let sut = makeSUT()
        let expectedItem = uniqueItem().localModel
        let timeStamp = Date()
        
        var capturedInsertedError: Error?
        var capturedRetrievedResult: RetrievalResult?
        let exp = expectation(description: "Wait for cache retrieval")
      
        sut.insertCache([expectedItem], timestamp: timeStamp) { insertedError in
            capturedInsertedError = insertedError
            sut.retrieve { result in
                capturedRetrievedResult = result
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNil(capturedInsertedError)
        
        switch capturedRetrievedResult {
        case .success(let feedItems,  _):
            XCTAssertEqual(feedItems, [expectedItem])
        default: XCTFail("expected success, got different result)")
        }
    }
}

// MARK: - Helpers
extension CodableStoreCacheUseCaseTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: storeURL)
        return sut
    }
    
    var storeURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self))")
    }
}
