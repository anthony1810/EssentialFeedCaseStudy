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
    private let cache: FeedCache
    
    init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load(completion: { [weak self] result in
            completion(
                result.map { feed in
                    self?.cache.save(feed) { _ in }
                    return feed
                }
            )
        })
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
    
    func test_load_cachesLoadedFeedOnSuccess() {
        let feed = uniqueFeed().model
        let cacheSpy = CacheSpy()
        let sut = makeSUT(loaderResult: .success([feed]), cacheSpy: cacheSpy)
        sut.load {_ in }
        
        XCTAssertEqual(cacheSpy.messages, [.save([feed])])
    }
    
    func test_load_doesNotCacheLoadedFeedOnFailure() {
        let cacheSpy = CacheSpy()
        let sut = makeSUT(loaderResult: .failure(anyNSError()), cacheSpy: cacheSpy)
        sut.load { _ in }
        
        XCTAssertEqual(cacheSpy.messages, [])
    }
    
    // MARK: - Helpers
    private func makeSUT(
        loaderResult: FeedLoader.Result,
        cacheSpy: CacheSpy = CacheSpy(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> FeedLoader {
        let loader = FeedLoaderStub(result: loaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cacheSpy)
        
        trackMemoryLeaks(cacheSpy, file: file, line: line)
        trackMemoryLeaks(loader, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private class CacheSpy: FeedCache {
        private(set) var messages = [Message]()
        enum Message: Equatable {
            case save([FeedImage])
        }
        func save(_ items: [FeedImage], completion: @escaping (SaveResult) -> Void) {
            messages.append(.save(items))
        }
    }
}
