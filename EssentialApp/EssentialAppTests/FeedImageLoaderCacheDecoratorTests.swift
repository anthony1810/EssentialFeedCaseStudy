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

final class FeedImageLoaderCacheDecoratorTests: XCTestCase, FeedImageDataLoaderTestable  {
    func test_loadImage_deliversImageOnLoaderSuccess() {
        let feedImageData = anydata()
        let (sut, loaderSpy) = makeSUT(loaderResult: .success(feedImageData))
        
        expect(sut, toFinishWith: .success(feedImageData)) {
            loaderSpy.completeAtIndex()
        }
    }
    
    func test_loadImage_deliversErrorOnLoaderFailure() {
        let error = anyNSError()
        let (sut, loaderSpy) = makeSUT(loaderResult: .failure(error))
        
        expect(sut, toFinishWith: .failure(error)) {
            loaderSpy.completeAtIndex()
        }
    }
    
    // MARK: - Helpers
    private func makeSUT(loaderResult: FeedImageDataLoader.Result, file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoader, loader: ImageLoaderSpy) {
        let loader = ImageLoaderSpy(result: loaderResult)
        let sut = FeedImageLoaderCacheDecorater(decoratee: loader)
        
        trackMemoryLeaks(loader, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
}
