//
//  FeedLoaderWithFallbackCompositeTests.swift
//  EssentialApp
//
//  Created by Anthony on 21/11/24.
//
import Foundation
import XCTest
import EssentialFeed

final class FeedLoaderWithFallbackComposite: FeedLoader {
    let primary: FeedLoader
    let fallback: FeedLoader
    
    init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load(completion: completion)
    }
}

class FeedLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_loadFeed_deliversSuccessWhenPrimarySuccess() {
        let uniqueFeed = uniqueItem().domainModel
        
        let remoteFeedLoader = FeedLoaderStub(result: FeedLoader.Result.success([uniqueFeed]))
        let localFeedLoader = FeedLoaderStub(result: FeedLoader.Result.success([]))
        
        let sut = FeedLoaderWithFallbackComposite(primary: remoteFeedLoader, fallback: localFeedLoader)
        
        let exp = expectation(description: "waiting for load")
        sut.load { result in
            switch result {
                case .success(let feeds):
                XCTAssertEqual(feeds, [uniqueFeed])
            default:
                XCTFail("Expect \(uniqueFeed), got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}

extension FeedLoaderWithFallbackCompositeTests {
    private struct FeedLoaderStub: FeedLoader {
        var result: FeedLoader.Result
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }
}
