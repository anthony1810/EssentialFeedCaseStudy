//
//  FeedCacheIntegrationTests.swift
//  FeedCacheIntegrationTests
//
//  Created by Anthony on 24/10/24.
//

import XCTest
import EssentialFeed
import RealmSwift

final class FeedCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.tearDown()
        
        clearStoreArtifacts()
    }
    
    override func tearDown() {
        super.tearDown()
        
        clearStoreArtifacts()
    }

    func test_load_deliversNoItemsOnEmptyCache() throws {
        let sut = makeSUT()
        
        expect(sut: sut, toCompleteLoadWith: .success([]))
    }
    
    func test_load_deliversItemsSavedOnSeperateInstance() {
        let sutToSave = makeSUT()
        let sutToLoad = makeSUT()
        let expectedItem = uniqueItem().domainModel
        
        expect(sut: sutToSave, withExpectedItems: [expectedItem], toCompleteSaveWith: nil)
        expect(sut: sutToLoad, toCompleteLoadWith: .success([expectedItem]))
    }

}

extension FeedCacheIntegrationTests {
    
    private func expect(sut: FeedLoader, toCompleteLoadWith expectedResult: LoadFeedResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        var actualResult: LoadFeedResult?
        sut.load { result in
            actualResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        switch (actualResult, expectedResult) {
        case (.success(let actualFeeds), .success(let expectedFeed)):
            XCTAssertEqual(actualFeeds, expectedFeed, file: file, line: line)
        case (.failure(let actualError), .failure):
            XCTAssertNotNil(actualError, file: file, line: line)
        default:
            XCTFail("Expected success or failure, got nothing")
        }
    }
    
    private func expect(sut: LocalFeedLoader, withExpectedItems items: [FeedImage], toCompleteSaveWith expectedError: Error?) {
        let sutToSave = makeSUT()
        
        var capturedError: Error?
        sutToSave.save(items, completion: { error in
            capturedError = error
        })
        
        switch (capturedError, expectedError) {
        case (.some, .some):
            break
        case (.none, .none):
            break
        default:
            XCTFail("expect \(String(describing: capturedError)) and \(String(describing: expectedError)) to be equal but they are not")
        }
    }
    
    private func makeSUT() -> LocalFeedLoader {
        let cacheStore = RealmFeedStore()
        let feedloader = LocalFeedLoader(store: cacheStore, timestamp: Date.init)
        
        trackForMemoryLeaks(feedloader)
        trackForMemoryLeaks(cacheStore)
        
        return feedloader
    }
    
    func uniqueItem() -> (domainModel: FeedImage, localModel: LocalFeedImage) {
        let domain = FeedImage(id: UUID(), description: nil, location: nil, imageURL: makeAnyUrl())
        let local = LocalFeedImage(id: domain.id, description: domain.description, location: domain.location, url: domain.imageURL)
        
        return (domain, local)
    }
    
    func clearStoreArtifacts() {
        if try! Realm().isInWriteTransaction {
            try? Realm().deleteAll()
        } else {
            try? Realm().write({
                try? Realm().deleteAll()
            })
        }
    }
}
