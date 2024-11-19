//
//  RealmFeedImageDataStoreTests.swift
//  EssentialFeed
//
//  Created by Anthony on 18/11/24.
//

import Foundation
import EssentialFeed
import XCTest
import RealmSwift

extension RealmFeedStore: LocalFeedImageStoreProtocol {
    public func retrieveData(for url: URL, completion: @escaping (RetrievalResult) -> Void) {
        completion(.success(.none))
    }
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        
    }
}

class RealmFeedImageDataStoreTests: XCTestCase {
    
    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let store = RealmFeedStore()
        
        expect(sut: store, toCompleteRetrievalWith: .success(.none), for: makeAnyUrl())
    }
    
}

// MARK: - Helpers
extension RealmFeedImageDataStoreTests {
    
    func expect(sut: RealmFeedStore, toCompleteRetrievalWith expectedResult: FeedImageLoaderProtocol.Result, for url: URL, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Retrieval completed")
      
        sut.retrieveData(for: url, completion: { capturedResult in
            switch (capturedResult, expectedResult) {
            case let (.success(actualResult), .success(expectedResult)):
                XCTAssertEqual(actualResult, expectedResult)
            default:
                XCTFail("expected \(expectedResult) but got \(capturedResult) instrad")
            }
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT(
        configuration: Realm.Configuration = RealmFeedImageDataStoreTests.realmTestConfiguration,
        file: StaticString = #file,
        line: UInt = #line
    ) -> FeedStoreProtocol {
        
        let sut = RealmFeedStore(realmConfig: configuration)
        trackForMemoryLeaks(sut)

        return sut
    }
    
    private func clearCache() {
        try! FileManager.default.removeItem(at: RealmFeedImageDataStoreTests.realmTestConfiguration.fileURL!)
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
}
