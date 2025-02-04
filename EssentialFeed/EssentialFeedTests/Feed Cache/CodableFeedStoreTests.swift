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
    
    let storeUrl: URL
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    init(storeUrl: URL) {
        self.storeUrl = storeUrl
    }
    
    private struct Cache: Codable {
        let items: [CodableFeedImage]
        let timestamp: Date
        var localFeedImages: [LocalFeedImage] {
            items.map(\.localFeedImage)
        }
    }
    
    private struct CodableFeedImage: Codable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let url: URL
        
        public init(id: UUID, description: String?, location: String?, imageURL: URL) {
            self.id = id
            self.description = description
            self.location = location
            self.url = imageURL
        }
        
        public init(from localFeedImage: LocalFeedImage) {
            self.id = localFeedImage.id
            self.description = localFeedImage.description
            self.location = localFeedImage.location
            self.url = localFeedImage.url
        }
        
        public var localFeedImage: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, imageURL: url)
        }
    }
    
    func retrievalCachedFeed(completion: @escaping FeedStore.RetrievalCompletion) {
        do {
            if let encoded = try? Data(contentsOf: storeUrl) {
                let decoded = try decoder.decode(Cache.self, from: encoded)
                completion(.found(feed: decoded.localFeedImages, timestamp: decoded.timestamp))
            } else {
                completion(.empty)
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func insertCachedFeed(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let cache = Cache(items: items.map(CodableFeedImage.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeUrl)
        
        completion(nil)
    }
}

final class CodableFeedStoreTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        
        deleteStoreArtifacts()
    }
    
    override func setUp() {
        super.setUp()
        
        deleteStoreArtifacts()
    }
    
    func test_retrieve_deliversEmptyCacheOnEmptyCache() {
        let sut = makeSUT()
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
        let sut = makeSUT()
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
    
    func test_retrieve_deliversNonEmptyCacheOnNonEmptyCache() {
        let expectedItems = [uniqueFeed().local]
        let expectedDate = Date()
        let sut = makeSUT()
        let exp = expectation(description: "Waiting for completion")
        
        sut.insertCachedFeed(expectedItems, timestamp: expectedDate) { error in
            XCTAssertNil(error, "expected no error when insert cache")
            sut.retrievalCachedFeed { result in
                switch result {
                case let .found(receivedItems, receivedTimestamp):
                    XCTAssertEqual(receivedItems, expectedItems)
                    XCTAssertEqual(receivedTimestamp, expectedDate)
                default: XCTFail("Expect non empty cache got \(result)")
                }
                
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeUrl: Self.testingURLSpecific)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: Self.testingURLSpecific)
    }
    
    private static var testingURLSpecific: URL {
        return FileManager.default.temporaryDirectory
            .appendingPathComponent("\(type(of: self)).store")
    }
}
