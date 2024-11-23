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

final class FeedLoaderCacheDecorator: FeedLoader {
    let decoratee: FeedLoader
    
    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load(completion: completion)
    }
}


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
    
}

extension FeedLoaderdDecoratorTests {
    func makeSUT(loaderResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> (sut: FeedLoaderCacheDecorator, loader: FeedLoaderStub) {
        let feedLoader = FeedLoaderStub(result: loaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: feedLoader)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(feedLoader, file: file, line: line)
        
        return (sut, feedLoader)
    }
}
