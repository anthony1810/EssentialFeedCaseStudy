//
//  FeedImageDataLoaderDecoratorTests.swift
//  EssentialApp
//
//  Created by Anthony on 23/11/24.
//

import Foundation
import XCTest
import EssentialFeed
import EssentialApp

final class FeedImageDataLoaderDecoratorTests: XCTestCase, FeedImageDataLoaderTest {
    
    func test_loadImageData_doesNotRequestImageURLWhenInit() {
        let (_, feedImageDataLoader, _) = makeSUT()
        
        XCTAssertEqual(feedImageDataLoader.loadedURLs,  [])
    }
    
    func test_loadImageData_loadsImageURLFromLoader() {
        let (sut, feedImageDataLoader, _) = makeSUT()
        let expectedImageURL = makeAnyUrl()
        
        _ = sut.loadImageData(from: expectedImageURL, completion: { _ in })
        
        XCTAssertEqual(feedImageDataLoader.loadedURLs, [expectedImageURL])
    }
    
    func test_loadImageData_loadsImageDataOnLoaderSuccess() {
        let expectedImageURL = makeAnyUrl()
        let expectedData = makeAnyData()
        let (sut, feedImageDataLoader, _) = makeSUT()
        
        expect(sut: sut, toLoad: expectedImageURL, with: .success(expectedData)) {
            feedImageDataLoader.completeLoad(with: .success(expectedData))
        }
    }
    
    func test_loadImageData_deliversErrorOnLoaderFailure() {
        let expectedImageURL = makeAnyUrl()
        let expectedError = makeAnyError()
        let (sut, feedImageDataLoader, _) = makeSUT()
        
        expect(sut: sut, toLoad: expectedImageURL, with: .failure(expectedError)) {
            feedImageDataLoader.completeLoad(with: .failure(expectedError))
        }
    }
    
    func test_cancelLoadImageData_cancelImageLoadingOnLoader() {
        let (sut, feedImageDataLoader, _) = makeSUT()
        let expectedImageURL = makeAnyUrl()
        
        let task = sut.loadImageData(from: expectedImageURL, completion: { _ in })
        task.cancel()
        
        XCTAssertEqual(feedImageDataLoader.cancelledURLs, [expectedImageURL])
    }
    
    func test_loadImageData_cachesImageDataOnLoaderSuccess() {
        let (sut, feedImageDataLoader, cacheSpy) = makeSUT()
        let expectedImageURL = makeAnyUrl()
        let expectedImageData = makeAnyData()
        
      _ = sut.loadImageData(from: expectedImageURL, completion: { _ in })
        feedImageDataLoader.completeLoad(with: .success(expectedImageData))
        
        XCTAssertEqual(cacheSpy.messages, [.saved(expectedImageData, expectedImageURL)])
    }
    
    func test_loadImageData_doesNotCacheImageDataOnLoaderFailure() {
        let (sut, feedImageDataLoader, cacheSpy) = makeSUT()
        
      _ = sut.loadImageData(from: makeAnyUrl(), completion: { _ in })
        feedImageDataLoader.completeLoad(with: .failure(makeAnyError()))
        
        XCTAssertEqual(cacheSpy.messages, [])
    }
    
}

extension FeedImageDataLoaderDecoratorTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageLoaderProtocol, feedImageDataLoader: FeedImageDataLoaderSpy, cacheSpy: CacheSpy) {
        
        let cacheSpy = CacheSpy()
        let feedImageDataLoader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderDecorator(decoratee: feedImageDataLoader, cache: cacheSpy)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(feedImageDataLoader, file: file, line: line)
        trackForMemoryLeaks(cacheSpy, file: file, line: line)
        
        return (sut, feedImageDataLoader, cacheSpy)
    }
    
    private class CacheSpy: FeedImageDataCacheProtocol {
        enum Message: Equatable {
            case saved(Data, URL)
        }
        
        var messages: [Message] = []
        
        func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
            messages.append(.saved(data, url))
        }
    }
}


