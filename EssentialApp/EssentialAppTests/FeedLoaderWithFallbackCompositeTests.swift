//
//  FeedLoaderWithFallbackCompositeTests.swift
//  EssentialApp
//
//  Created by Anthony on 8/7/25.
//

import XCTest
import EssentialFeed

final class FeedLoaderWithFallbackComposite: FeedLoader {
    private let primaryLoader: FeedLoader
    private let fallbackLoader: FeedLoader
    
    init(primaryLoader: FeedLoader, fallbackLoader: FeedLoader) {
        self.primaryLoader = primaryLoader
        self.fallbackLoader = fallbackLoader
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primaryLoader.load(completion: { primaryCompletion in
            if case let .success(feeds) = primaryCompletion {
                completion(.success(feeds))
            } else {
                self.fallbackLoader.load(completion: completion)
            }
        })
    }
}

final class FeedLoaderWithFallbackCompositeTests: XCTestCase {
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
}

// MARK: - Helpers
extension FeedLoaderWithFallbackCompositeTests {
    
    func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedLoaderWithFallbackComposite {
        
        let primaryLoader = LoaderStub(result: primaryResult)
        let fallbackLoader = LoaderStub(result: fallbackResult)
        
        let composite = FeedLoaderWithFallbackComposite(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)
        
        trackMemoryLeaks(primaryLoader, file: file, line: line)
        trackMemoryLeaks(fallbackLoader, file: file, line: line)
        trackMemoryLeaks(composite, file: file, line: line)
        
        return composite
    }
    
    func expect(
    _ sut: FeedLoaderWithFallbackComposite,
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
    
    func uniqueFeed() -> (model: FeedImage, local: LocalFeedImage) {
        
        let model = FeedImage(id: UUID(), description: "any description", location: "any location", imageURL: anyURL())
        
        let local = LocalFeedImage(id: model.id, description: model.description, location: model.location, imageURL: model.url)
        
        return (model, local)
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
    
    func anyNSError() -> NSError {
        NSError(domain: "Test", code: 0, userInfo: nil)
    }
    
    func anyURL() -> URL {
        URL(string: "https://example.com")!
    }
}

extension XCTestCase {
    func trackMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Potential memory leak", file: file, line: line)
        }
    }
}
