//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialApp
//
//  Created by Anthony on 20/7/25.
//

import XCTest
import EssentialFeed

final class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    
    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load(completion: completion)
    }
}

final class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {
    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed().model
        let sut = makeSUT(loaderResult: .success([feed]))
        
        expect(sut, toFinishWith: .success([feed]))
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        let expectedError = anyNSError()
        let sut = makeSUT(loaderResult: .failure(expectedError))
        
        expect(sut, toFinishWith: .failure(expectedError))
    }
    
    // MARK: - Helpers
    func makeSUT(loaderResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedLoader {
        let loader = FeedLoaderStub(result: loaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
        trackMemoryLeaks(loader)
        trackMemoryLeaks(sut)
        
        return sut
    }
}
