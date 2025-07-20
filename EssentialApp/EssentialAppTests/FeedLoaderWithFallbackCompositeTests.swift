//
//  FeedLoaderWithFallbackCompositeTests.swift
//  EssentialApp
//
//  Created by Anthony on 8/7/25.
//

import XCTest
import EssentialFeed
import EssentialApp

final class FeedLoaderWithFallbackCompositeTests: XCTestCase, FeedLoaderTestCase {
    func test_load_deliversFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed().model
        let fallbackFeed = uniqueFeed().model
        
        let sut = makeSUT(primaryResult: .success([primaryFeed]), fallbackResult: .success([fallbackFeed]))
        
        expect(sut, toFinishWith: .success([primaryFeed]))
    }
    
    func test_load_deliversFallbackFeedsOnPrimaryLoaderFailure() {
        let primaryFailureError = anyNSError()
        let fallbackFeed = uniqueFeed().model
        let sut = makeSUT(primaryResult: .failure(primaryFailureError), fallbackResult:  .success([fallbackFeed]))
        
        expect(sut, toFinishWith: .success([fallbackFeed]))
    }
    
    func test_load_deliversErrorWhenBothLoadersFailWithError() {
        
        let sut = makeSUT(
            primaryResult: .failure(anyNSError()),
            fallbackResult:  .failure(anyNSError())
        )
        
        expect(sut, toFinishWith: .failure(anyNSError()))
    }
}

// MARK: - Helpers
extension FeedLoaderWithFallbackCompositeTests {
    
    func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedLoaderWithFallbackComposite {
        
        let primaryLoader = FeedLoaderStub(result: primaryResult)
        let fallbackLoader = FeedLoaderStub(result: fallbackResult)
        
        let composite = FeedLoaderWithFallbackComposite(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)
        
        trackMemoryLeaks(primaryLoader, file: file, line: line)
        trackMemoryLeaks(fallbackLoader, file: file, line: line)
        trackMemoryLeaks(composite, file: file, line: line)
        
        return composite
    }
}

