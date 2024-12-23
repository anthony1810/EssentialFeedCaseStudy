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

    func test_loadFeed_deliversNoItemsOnEmptyCache() throws {
        let sut = makeFeedLoader()
        
        expect(sut: sut, toCompleteLoadWith: .success([]))
    }
    
    func test_loadFeed_deliversItemsSavedOnSeperateInstance() {
        let sutToSave = makeFeedLoader()
        let sutToLoad = makeFeedLoader()
        let expectedItem = uniqueItem().domainModel
        
        expect(sut: sutToSave, withExpectedItems: [expectedItem], toCompleteSaveWith: nil)
        expect(sut: sutToLoad, toCompleteLoadWith: .success([expectedItem]))
    }
    
    func test_saveFeed_overridesItemsSavedOnSeperateInstance() {
        let sutToPerformFirstSave = makeFeedLoader()
        let sutToPerformSecondSave = makeFeedLoader()
        let sutToLoad = makeFeedLoader()
        let expectedItem = uniqueItem().domainModel
        let latestFeed = uniqueItem().domainModel
        
        expect(sut: sutToPerformFirstSave, withExpectedItems: [expectedItem], toCompleteSaveWith: nil)
        expect(sut: sutToPerformSecondSave, withExpectedItems: [latestFeed], toCompleteSaveWith: nil)
        expect(sut: sutToLoad, toCompleteLoadWith: .success([latestFeed]))
    }
    
    func test_loadFeedImageData_deliversSaveDataOnSeperateInstance() {
        let sutToSave = makeFeedImageLoader()
        let sutToLoad = makeFeedImageLoader()
        
        let feedLoader = makeFeedLoader()
        let feedItem = uniqueItem().domainModel
        
        let expectedImageData = makeAnyData()
        
        expect(sut: feedLoader, withExpectedItems: [feedItem], toCompleteSaveWith: nil)
        save(expectedImageData, with: feedItem.imageURL, with: sutToSave)
        expect(sut: sutToLoad, toLoad: .success(expectedImageData), for: feedItem.imageURL)
    }
    
    func test_loadFeedImageData_deliversOverrideSavedImageOnSeparateInstance() {
        let sutToPerformFirstSave = makeFeedImageLoader()
        let sutToPerformSecondSave = makeFeedImageLoader()
        let sutToLoad = makeFeedImageLoader()
        
        let feedLoader = makeFeedLoader()
        let feedItem = uniqueItem().domainModel
        
        let firstFeedImageData = makeAnyData()
        let lastFeedImageData = makeAnyData()
        
        expect(sut: feedLoader, withExpectedItems: [feedItem], toCompleteSaveWith: nil)
        save(firstFeedImageData, with: feedItem.imageURL, with: sutToPerformFirstSave)
        save(lastFeedImageData, with: feedItem.imageURL, with: sutToPerformSecondSave)
        
        expect(sut: sutToLoad, toLoad: .success(lastFeedImageData), for: feedItem.imageURL)
    }
    
    func test_saveFeedImageData_doesNotDeleteRecentSavedImageOnValidatingCache() {
        let feedLoader = makeFeedLoader()
        let feedImageLoader = makeFeedImageLoader()
        
        let feedItem = uniqueItem().domainModel
        
        let expectedImageData = makeAnyData()
        
        expect(sut: feedLoader, withExpectedItems: [feedItem], toCompleteSaveWith: nil)
        save(expectedImageData, with: feedItem.imageURL, with: feedImageLoader)
        validateCache(with: feedLoader)
        
        expect(sut: feedImageLoader, toLoad: .success(expectedImageData), for: feedItem.imageURL)
    }
    
    func test_saveFeedImageData_deletesDistancePastSavedImageOnInvalidatingCache() {
        let feedLoader = makeFeedLoader(currentDate: .distantPast)
        let feedImageLoader = makeFeedImageLoader()
        
        let feedItem = uniqueItem().domainModel
        
        let expectedImageData = makeAnyData()
        
        expect(sut: feedLoader, withExpectedItems: [feedItem], toCompleteSaveWith: nil)
        save(expectedImageData, with: feedItem.imageURL, with: feedImageLoader)
        validateCache(with: feedLoader)
        
        expect(sut: feedImageLoader, toLoad: notFoundImageData(), for: feedItem.imageURL)
    }
}

// MARK: - FeedImageDataLoaer
extension FeedCacheIntegrationTests {
    private func makeFeedImageLoader() -> LocalFeedImageDataLoader {
        let cacheStore = RealmFeedStore(realmConfig: FeedCacheIntegrationTests.realmTestConfiguration)
        let feedImageLoader = LocalFeedImageDataLoader(store: cacheStore)
        
        trackForMemoryLeaks(feedImageLoader)
        trackForMemoryLeaks(cacheStore)
        
        return feedImageLoader
    }
    
    private func save(_ data: Data, with url: URL, with sut: LocalFeedImageDataLoader, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for save completion")
        sut.save(data, for: url) { result in
            if case let .failure(error) = result {
                XCTFail("Unexpected error: \(error)", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(sut: LocalFeedImageDataLoader, toLoad expectedResult: LocalFeedImageDataLoader.Result, for url: URL, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for save completion")
        _ = sut.loadImageData(from: url) { actualResult in
            switch (actualResult, expectedResult) {
            case let (.failure(actualError as LocalFeedImageDataLoader.LoadError), .failure(expectedError as LocalFeedImageDataLoader.LoadError)):
                XCTAssertEqual(actualError, expectedError, file: file, line: line)
            case let (.success(actualData), .success(expectedData)):
                XCTAssertEqual(actualData, expectedData, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(actualResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func notFoundImageData() -> LocalFeedImageDataLoader.Result {
        .failure(LocalFeedImageDataLoader.LoadError.notFound)
    }
}

// MARK: - FeedLoader
extension FeedCacheIntegrationTests {
    
    private func makeFeedLoader(currentDate: Date = Date(), file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let cacheStore = RealmFeedStore(realmConfig: FeedCacheIntegrationTests.realmTestConfiguration)
        let feedloader = LocalFeedLoader(store: cacheStore, timestamp: { currentDate })
        
        trackForMemoryLeaks(feedloader, file: file, line: line)
        trackForMemoryLeaks(cacheStore, file: file, line: line)
        
        return feedloader
    }
    
    private func validateCache(with loader: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        loader.validateCache { result in
            if case let .failure(error) = result {
                XCTFail("Unexpected error: \(error)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(sut: FeedLoaderProtocol, toCompleteLoadWith expectedResult: FeedLoaderProtocol.Result, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        var actualResult: FeedLoaderProtocol.Result?
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
        
        var capturedError: Error?
        sut.save(items, completion: { error in
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
    
    func uniqueItem() -> (domainModel: FeedImage, localModel: LocalFeedImage) {
        let domain = FeedImage(id: UUID(), description: nil, location: nil, imageURL: makeAnyUrl())
        let local = LocalFeedImage(id: domain.id, description: domain.description, location: domain.location, url: domain.imageURL)
        
        return (domain, local)
    }
    
    func clearStoreArtifacts() {
       if let fileURL = FeedCacheIntegrationTests.realmTestConfiguration.fileURL {
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
}
