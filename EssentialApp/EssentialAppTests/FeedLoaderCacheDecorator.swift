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

final class FeedLoaderCacheDecoratorTests: XCTestCase {
    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed().model
        let loader = LoaderStub(result: .success([feed]))
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
        
        expect(sut, toFinishWith: .success([feed]))
    }
    
    // MARK: - Helpers
    func expect(
        _ sut: FeedLoader,
    toFinishWith expectedResult: FeedLoader.Result,
    file: StaticString = #file,
    line: UInt = #line
    ) {
        let expectation = XCTestExpectation(description: "Wait for load")
        sut.load { actualResult in
            switch (actualResult, expectedResult) {
                case (.success(let actual), .success(let expected)):
                    XCTAssertEqual(actual, expected, file: file, line: line)
            case  (.failure(let actual as NSError), .failure(let expected as NSError)):
                XCTAssertEqual(actual, expected, file: file, line: line)
                default:
                    XCTFail("Expected \(expectedResult), got \(actualResult) instead", file: file, line: line)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    private class LoaderStub: FeedLoader {
        private let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }
}
