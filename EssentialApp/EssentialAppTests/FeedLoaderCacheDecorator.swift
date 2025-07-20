//
//  FeedLoaderCacheDecorator.swift
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
        let loader = FeedLoaderStub(result: .success([feed]))
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
        
        expect(sut, toFinishWith: .success([feed]))
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        let expectedError = anyNSError()
        let loader = FeedLoaderStub(result: .failure(expectedError))
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
        
        expect(sut, toFinishWith: .failure(expectedError))
    }
    
    // MARK: - Helpers
}
