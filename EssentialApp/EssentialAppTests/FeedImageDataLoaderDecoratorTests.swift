//
//  FeedImageDataLoaderDecoratorTests.swift
//  EssentialApp
//
//  Created by Anthony on 23/11/24.
//

import Foundation
import XCTest
import EssentialFeed

final class FeedImageDataLoaderDecorator: FeedImageLoaderProtocol {
    let decoratee: FeedImageLoaderProtocol
    
    init(decoratee: FeedImageLoaderProtocol) {
        self.decoratee = decoratee
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageLoaderProtocol.Result) -> Void) -> any ImageLoadingDataTaskProtocol {
        
        decoratee.loadImageData(from: url, completion: completion)
    }
}

final class FeedImageDataLoaderDecoratorTests: XCTestCase, FeedImageDataLoaderTest {
    
    func test_loadImageData_doesNotRequestImageURLWhenInit() {
        let (_, feedImageDataLoader) = makeSUT()
        
        XCTAssertEqual(feedImageDataLoader.loadedURLs,  [])
    }
    
    func test_loadImageData_loadsImageURLFromLoader() {
        let (sut, feedImageDataLoader) = makeSUT()
        let expectedImageURL = makeAnyUrl()
        
        _ = sut.loadImageData(from: expectedImageURL, completion: { _ in })
        
        XCTAssertEqual(feedImageDataLoader.loadedURLs, [expectedImageURL])
    }
    
    func test_loadImageData_loadsImageDataOnLoaderSuccess() {
        let expectedImageURL = makeAnyUrl()
        let expectedData = makeAnyData()
        let (sut, feedImageDataLoader) = makeSUT()
        
        expect(sut: sut, toLoad: expectedImageURL, with: .success(expectedData)) {
            feedImageDataLoader.completeLoad(with: .success(expectedData))
        }
    }
    
    func test_loadImageData_deliversErrorOnLoaderFailure() {
        let expectedImageURL = makeAnyUrl()
        let expectedError = makeAnyError()
        let (sut, feedImageDataLoader) = makeSUT()
        
        expect(sut: sut, toLoad: expectedImageURL, with: .failure(expectedError)) {
            feedImageDataLoader.completeLoad(with: .failure(expectedError))
        }
    }
    
    func test_cancelLoadImageData_cancelImageLoadingOnLoader() {
        let (sut, feedImageDataLoader) = makeSUT()
        let expectedImageURL = makeAnyUrl()
        
        let task = sut.loadImageData(from: expectedImageURL, completion: { _ in })
        task.cancel()
        
        XCTAssertEqual(feedImageDataLoader.cancelledURLs, [expectedImageURL])
    }
    
}

extension FeedImageDataLoaderDecoratorTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageLoaderProtocol, feedImageDataLoader: FeedImageDataLoaderSpy) {
        
        let feedImageDataLoader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderDecorator(decoratee: feedImageDataLoader)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(feedImageDataLoader, file: file, line: line)
        
        return (sut, feedImageDataLoader)
    }
}


