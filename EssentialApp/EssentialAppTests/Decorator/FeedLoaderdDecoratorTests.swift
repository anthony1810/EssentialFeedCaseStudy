//
//  FeedLoaderdDecoratorTests.swift
//  EssentialApp
//
//  Created by Anthony on 23/11/24.
//

import Foundation
import XCTest
import EssentialFeed
import EssentialApp

final class FeedLoaderdDecoratorTests: XCTestCase, FeedLoaderTestCase {
    
    func test_loadFeed_deliversFeedOnDecorateeSuccess() {
        let feedImage = uniqueItem().domainModel
        let (sut, _) = makeSUT(loaderResult: .success([feedImage]))
        
        expect(sut: sut, toFinishWith: .success([feedImage]))
    }
    
    func test_loadFeed_deliversErrorOnDecorateeFailure() {
        let error = makeAnyError()
        let (sut, _) = makeSUT(loaderResult: .failure(error))
       
        expect(sut: sut, toFinishWith: .failure(error))
    }
    
    func test_loadFeed_cachesLoadedFeedsOnLoaderSuccess() {
        let feedImage = uniqueItem().domainModel
        let (sut, cache) = makeSUT(loaderResult: .success([feedImage]))
        
        sut.load(completion: {_ in })
        XCTAssertEqual(cache.messages, [.saved([feedImage])])
    }
    
    func test_loadFeed_doesNotCacheFeedsOnLoaderFailure() {
        let error = makeAnyError()
        let (sut, cache) = makeSUT(loaderResult: .failure(error))
        
        sut.load(completion: {_ in })
        XCTAssertEqual(cache.messages, [])
    }
    
}

extension FeedLoaderdDecoratorTests {
    private func makeSUT(loaderResult: FeedLoaderProtocol.Result, file: StaticString = #file, line: UInt = #line) -> (sut: FeedLoaderCacheDecorator, cache: CacheSpy) {
        let feedLoader = FeedLoaderStub(result: loaderResult)
        let cache = CacheSpy()
        let sut = FeedLoaderCacheDecorator(decoratee: feedLoader, cache: cache)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(feedLoader, file: file, line: line)
        trackForMemoryLeaks(cache)
        
        return (sut, cache)
    }
    
    private class CacheSpy: FeedCacheProtocol {
       
        enum Message: Equatable {
            case saved([FeedImage])
        }
        
        var messages: [Message] = []
        
        func save(_ items: [FeedImage], completion: @escaping (SaveResult) -> Void) {
            messages.append(.saved(items))
        }
    }
}
