//
//  FeedLoaderWithFallbackCompositeTests.swift
//  EssentialApp
//
//  Created by Anthony on 21/11/24.
//
import Foundation
import XCTest
import EssentialFeed
import EssentialApp

class FeedLoaderWithFallbackCompositeTests: XCTestCase, FeedLoaderTestCase {
    
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
    
    func test_loadFeed_deliversErrorWhenPrimaryAndFallbackFailures() {
        let expectedError = makeAnyError()
        
        let sut = makeSUT(primaryResult: .failure(expectedError), fallbackResult: .failure(expectedError))
        expect(sut: sut, toFinishWith: .failure(expectedError))
    }
}

extension FeedLoaderWithFallbackCompositeTests {
    func makeSUT(
        primaryResult: FeedLoaderProtocol.Result,
        fallbackResult: FeedLoaderProtocol.Result,
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
}
