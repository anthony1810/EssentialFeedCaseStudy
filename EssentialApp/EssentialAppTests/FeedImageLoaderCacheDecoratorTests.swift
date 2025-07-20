//
//  FeedImageLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Anthony on 20/7/25.
//

import Foundation
import XCTest
import EssentialFeed

final class FeedImageLoaderCacheDecorater: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    
    init(decoratee: FeedImageDataLoader) {
        self.decoratee = decoratee
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url, completion: completion)
    }
}

final class FeedImageLoaderCacheDecoratorTests: XCTestCase {
    func test_loadImage_deliversImageOnLoaderSuccess() {
        let feedImageData = anydata()
        let loaderSpy = ImageLoaderSpy(result: .success(feedImageData))
        let sut = FeedImageLoaderCacheDecorater(decoratee: loaderSpy)
        
        expect(sut, toFinishWith: .success(feedImageData)) {
            loaderSpy.completeAtIndex()
        }
    }
    
    func test_loadImage_deliversErrorOnLoaderFailure() {
        let error = anyNSError()
        let loaderSpy = ImageLoaderSpy(result: .failure(error))
        let sut = FeedImageLoaderCacheDecorater(decoratee: loaderSpy)
        
        expect(sut, toFinishWith: .failure(error)) {
            loaderSpy.completeAtIndex()
        }
    }
    
    // MARK: - Helpers
    private func expect(
        _ sut: FeedImageDataLoader,
        toFinishWith expectedResult: FeedImageDataLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let expectation = self.expectation(description: "wait for image data to load")
        _ = sut.loadImageData(from: anyURL()) { actualResult in
            switch (actualResult, expectedResult) {
            case (.success(let actualData), .success(let expectedData)):
                XCTAssertEqual(actualData, expectedData, file: file, line: line)
            case (.failure(let actualError as NSError), .failure(let expectedError as NSError)):
                XCTAssertEqual(actualError, expectedError, file: file, line: line)
            default:
                XCTFail("expected \(expectedResult), got \(actualResult)", file: file, line: line)
            }
            expectation.fulfill()
        }
        
        action()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    private class ImageLoaderSpy: FeedImageDataLoader {
        private struct Task: FeedImageDataLoaderTask {
            private var callback: (() -> Void)
            
            init(callback: @escaping () -> Void) {
                self.callback = callback
            }
            
            func cancel() {
                callback()
            }
        }
        
        private let result: FeedImageDataLoader.Result
        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        private(set) var cancelURLs: [URL] = []
        
        var loadedImageURLs: [URL] {
            messages.map { $0.url }
        }
        
        init(result: FeedImageDataLoader.Result) {
            self.result = result
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            messages.append((url, completion))
            return Task(callback: { [weak self] in
                self?.cancelURLs.append(url)
            })
        }
        
        func completeAtIndex(_ index: Int = 0) {
            messages[index].completion(result)
        }
      
    }
}
