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
        primary.load { [weak self] primaryResult in
            switch primaryResult {
            case .success:
                completion(primaryResult)
            case .failure:
                self?.fallback.load(completion: completion)
            }
        }
    }
}

class FeedLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_loadFeed_deliversSuccessWhenPrimarySuccess() {
        let expectedFeed = uniqueItem().domainModel
        
        let sut = makeSUT(primaryResult: .success([expectedFeed]), fallbackResult: .success([]))
        
        expect(sut: sut, toFinishWith: .success([expectedFeed]))
    }
    
    func test_loadFeed_deliversFallbackFeedOnPrimaryLoaderFailure() {
        let expectedFeed = uniqueItem().domainModel
        
        let sut = makeSUT(primaryResult: .failure(makeAnyError()), fallbackResult: .success([expectedFeed]))
        expect(sut: sut, toFinishWith: .success([expectedFeed]))
    }
}

extension FeedLoaderWithFallbackCompositeTests {
    func makeSUT(
        primaryResult: FeedLoader.Result,
        fallbackResult: FeedLoader.Result,
        file: StaticString = #file,
        line: UInt = #line
    ) -> FeedLoaderWithFallbackComposite {
        let remoteFeedLoader = FeedLoaderStub(result: primaryResult)
        let localFeedLoader = FeedLoaderStub(result: fallbackResult)
        
        let sut = FeedLoaderWithFallbackComposite(primary: remoteFeedLoader, fallback: localFeedLoader)
        
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(remoteFeedLoader)
        trackForMemoryLeaks(localFeedLoader)
        
        return sut
    }
    
    func expect(sut: FeedLoaderWithFallbackComposite, toFinishWith expectedResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "waiting for load")
        sut.load { actualResult in
            switch (actualResult, expectedResult) {
            case let (.success(actualFeeds), .success(expectedFeeds)):
                XCTAssertEqual(actualFeeds, expectedFeeds, file: file, line: line)
            case let (.failure(actualError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(actualError, expectedError)
            default:
                XCTFail("Expect \(expectedResult), got \(actualResult) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private class FeedLoaderStub: FeedLoader {
        let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }
}
