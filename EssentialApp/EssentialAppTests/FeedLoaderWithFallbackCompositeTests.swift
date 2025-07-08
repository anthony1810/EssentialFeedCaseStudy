//
//  FeedLoaderWithFallbackCompositeTests.swift
//  EssentialApp
//
//  Created by Anthony on 8/7/25.
//

import XCTest
import EssentialFeed

final class FeedLoaderWithFallbackComposite: FeedLoader {
    private let primaryLoader: FeedLoader
    private let fallbackLoader: FeedLoader
    
    init(primaryLoader: FeedLoader, fallbackLoader: FeedLoader) {
        self.primaryLoader = primaryLoader
        self.fallbackLoader = fallbackLoader
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primaryLoader.load(completion: completion)
    }
}

final class FeedLoaderWithFallbackCompositeTests: XCTestCase {
    func test_load_deliversFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed().model
        let fallbackFeed = uniqueFeed().model
    
        let primaryLoader = LoaderStub(result: .success([primaryFeed]))
        let fallbackLoader = LoaderStub(result: .success([fallbackFeed]))
        let composite = FeedLoaderWithFallbackComposite(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)
        
        let expectation = XCTestExpectation(description: "Wait for load")
        composite.load { result in
            if case .success(let feed) = result {
                XCTAssertEqual(feed, [primaryFeed])
            } else {
                XCTFail("Expect success got \(result) instead")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Helpers
extension FeedLoaderWithFallbackCompositeTests {
    func uniqueFeed() -> (model: FeedImage, local: LocalFeedImage) {
        
        let model = FeedImage(id: UUID(), description: "any description", location: "any location", imageURL: anyURL())
        
        let local = LocalFeedImage(id: model.id, description: model.description, location: model.location, imageURL: model.url)
        
        return (model, local)
    }
    
    private class LoaderStub: FeedLoader {
        private let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }
    
    func anyNSError() -> NSError {
        NSError(domain: "Test", code: 0, userInfo: nil)
    }
    
    func anyURL() -> URL {
        URL(string: "https://example.com")!
    }
}
