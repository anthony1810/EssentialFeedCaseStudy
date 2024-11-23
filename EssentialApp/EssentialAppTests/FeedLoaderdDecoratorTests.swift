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
        let feedLoader = FeedLoaderStub(result: .success([feedImage]))
        let sut = FeedLoaderCacheDecorator(decoratee: feedLoader)
        
        expect(sut: sut, toFinishWith: .success([feedImage]))
    }
    
    func test_loadFeed_deliversErrorOnDecorateeFailure() {
        let error = makeAnyError()

        let feedLoader = FeedLoaderStub(result: .failure(error))
        let sut = FeedLoaderCacheDecorator(decoratee: feedLoader)
        
        expect(sut: sut, toFinishWith: .failure(error))
    }
    
}
