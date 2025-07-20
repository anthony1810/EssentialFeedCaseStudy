//
//  FeedImageLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Anthony on 20/7/25.
//

import Foundation
import XCTest
import EssentialFeed
public protocol FeedImageCache {
    typealias SaveResult = Swift.Result<Void, Error>
    func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void)
}

final class FeedImageLoaderCacheDecorater: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageCache
    
    init(decoratee: FeedImageDataLoader, cache: FeedImageCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url, completion: { [weak self] result in
            completion(
                result.map { data in
                    self?.saveIgnoringResult(data: data, for: url)
                    return data
                }
            )
        })
    }
    
    func saveIgnoringResult(data: Data, for url: URL) {
        cache.save(data, for: url) { _ in }
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
    
    func test_loadImage_cachesLoadedImageOnLoaderSuccess() {
        let feedImageData = anydata()
        let imageURL = anyURL()
        let cacheSpy = FeedImageCacheSpy()
        let (sut, loaderSpy) = makeSUT(loaderResult: .success(feedImageData), cacheSpy: cacheSpy)
        
        _ = sut.loadImageData(from: imageURL) { _ in }
        loaderSpy.completeAtIndex()
        
        XCTAssertEqual(cacheSpy.messages, [.save(url: imageURL, data: feedImageData)])
    }
    
    func test_loadImage_doesNotCacheLoadedImageOnLoaderFailure() {
        let error = anyNSError()
        let imageURL = anyURL()
        let cacheSpy = FeedImageCacheSpy()
        let (sut, loaderSpy) = makeSUT(loaderResult: .failure(error), cacheSpy: cacheSpy)
        
        _ = sut.loadImageData(from: imageURL) { _ in }
        loaderSpy.completeAtIndex()
        
        XCTAssertEqual(cacheSpy.messages, [])
    }
    
    // MARK: - Helpers
    private func makeSUT(
        loaderResult: FeedImageDataLoader.Result,
        cacheSpy: FeedImageCacheSpy = FeedImageCacheSpy(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: FeedImageDataLoader, loader: ImageLoaderSpy) {
        let loader = ImageLoaderSpy(result: loaderResult)
        let sut = FeedImageLoaderCacheDecorater(decoratee: loader, cache: cacheSpy)
        
        trackMemoryLeaks(loader, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(cacheSpy, file: file, line: line)
        
        return (sut, loader)
    }
    
    private class FeedImageCacheSpy: FeedImageCache {
        private(set) var messages = [Message]()
        enum Message: Equatable {
            case save(url: URL, data: Data)
        }
        func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
            messages.append(.save(url: url, data: data))
            completion(.success(()))
        }
    }
}
