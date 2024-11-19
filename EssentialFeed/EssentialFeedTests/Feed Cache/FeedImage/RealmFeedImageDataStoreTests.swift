//
//  RealmFeedImageDataStoreTests.swift
//  EssentialFeed
//
//  Created by Anthony on 18/11/24.
//

import Foundation
@testable import EssentialFeed
import XCTest
import RealmSwift

extension RealmFeedStore: LocalFeedImageStoreProtocol {
    public func retrieveData(for url: URL, completion: @escaping (RetrievalResult) -> Void) {
        do {
            let realm = try makeRealm()
            
            let realmImage = realm
                .objects(RealmFeedImage.self)
                .where({ $0.url == url.absoluteString })
                .first
            
            completion(.success(realmImage?.data))
        } catch {
            completion(.failure(error))
        }
    }
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        do {
            let realm = try makeRealm()
            
            guard let realmImage = realm
                .objects(RealmFeedImage.self)
                .where({ $0.url == url.absoluteString })
                .first
            else { return completion(.success(.none)) }
            
            if realm.isInWriteTransaction {
                realmImage.data = data
            } else {
                try realm.write {
                    realmImage.data = data
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
}

class RealmFeedImageDataStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        clearCache()
    }
    
    override func tearDown() {
        super.tearDown()
        
        clearCache()
    }
    
    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let store = makeSUT()
        
        expect(sut: store, toCompleteRetrievalWith: notFoundResult(), for: makeAnyUrl())
    }
    
    func test_retrieveImageData_deliversNotFoundWhenURLNotMatched() {
        let store = makeSUT()
        let imageData = makeAnyData()
        
        let url = makeAnyUrl()
        let nonMatchingURL = makeAnyUrl()
        
        insert(imageData, url: url, into: store)
        expect(sut: store, toCompleteRetrievalWith: notFoundResult(), for: nonMatchingURL)
    }
    
    func test_retrieveImageData_deliversImageDataWhenMatched() {
        let store = makeSUT()
        let imageData = makeAnyData()
        let url = makeAnyUrl()
        
        insert(imageData, url: url, into: store)
        expect(sut: store, toCompleteRetrievalWith: foundResult(data: imageData), for: url)
    }
}

// MARK: - Helpers
extension RealmFeedImageDataStoreTests {
    
    func expect(sut: RealmFeedStore, toCompleteRetrievalWith expectedResult: FeedImageLoaderProtocol.Result, for url: URL, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Retrieval completed")
        
        sut.retrieveData(for: url, completion: { capturedResult in
            switch (capturedResult, expectedResult) {
            case let (.success(actualResult), .success(expectedResult)):
                XCTAssertEqual(actualResult, expectedResult, file: file, line: line)
            default:
                XCTFail("expected \(expectedResult) but got \(capturedResult) instrad", file: file, line: line)
            }
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func insert(_ data: Data, url: URL, into sut: RealmFeedStore, file: StaticString = #file, line: UInt = #line) {
        let image = localImage(url: url)
        sut.insertCache([image], timestamp: Date()) { error in
            if let error {
                XCTFail("Failed to save \(image) with error = \(error)", file: file, line: line)
            } else {
                sut.insert(data, for: url) { result in
                    if case let .failure(error) = result {
                        XCTFail("Failed to insert data with error = \(error)",file: file, line: line)
                    }
                }
            }
        }
    }
    
    private func makeSUT(
        configuration: Realm.Configuration = RealmFeedImageDataStoreTests.realmTestConfiguration,
        file: StaticString = #file,
        line: UInt = #line
    ) -> RealmFeedStore {
        
        let sut = RealmFeedStore(realmConfig: configuration)
        trackForMemoryLeaks(sut)
        
        return sut
    }
    
    private func clearCache() {
        if let fileURL = RealmFeedImageDataStoreTests.realmTestConfiguration.fileURL {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
    
    private static var realmTestConfiguration: Realm.Configuration {
        Realm.Configuration(
            fileURL: FileManager.default.temporaryDirectory.appendingPathComponent("\(type(of: self)).realm"),
            inMemoryIdentifier: nil,
            schemaVersion: 1,
            migrationBlock: nil,
            deleteRealmIfMigrationNeeded: true
        )
    }
    
    private func notFoundResult() -> FeedImageLoaderProtocol.Result {
        .success(.none)
    }
    
    private func foundResult(data: Data) -> FeedImageLoaderProtocol.Result {
        .success(data)
    }
    
    private func localImage(url: URL) -> LocalFeedImage {
        LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)
    }
}
