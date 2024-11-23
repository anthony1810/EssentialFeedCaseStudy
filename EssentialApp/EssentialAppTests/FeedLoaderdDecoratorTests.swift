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


final class FeedLoaderdDecoratorTests: XCTestCase {
    
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

extension FeedLoaderdDecoratorTests {
    func expect(sut: FeedLoaderCacheDecorator, toFinishWith expectedResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "waiting for load")
        sut.load { actualResult in
            switch (actualResult, expectedResult) {
            case let (.success(actualFeeds), .success(expectedFeeds)):
                XCTAssertEqual(actualFeeds, expectedFeeds, file: file, line: line)
            case let (.failure(actualError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(actualError, expectedError, file: file, line: line)
            default:
                XCTFail("Expect \(expectedResult), got \(actualResult) instead", file: file, line: line)
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
