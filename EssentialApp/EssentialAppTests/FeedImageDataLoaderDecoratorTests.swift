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

final class FeedImageDataLoaderDecoratorTests: XCTestCase {
    
    func test_loadImageData_doesNotRequestImageURLWhenInit() {
        let (_, feedImageDataLoader) = makeSUT()
        
        XCTAssertEqual(feedImageDataLoader.loadedURLs,  [])
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
    
    private class FeedImageDataLoaderSpy: FeedImageLoaderProtocol {
        var messages = [(url: URL, completion: ((FeedImageLoaderProtocol.Result) -> Void))]()
        var loadedURLs: [URL] {
            messages.map(\.url)
        }
        private(set) var cancelledURLs = [URL]()
        
        private class Task: ImageLoadingDataTaskProtocol {
            let callback: () -> Void
            
            init(callback: @escaping () -> Void) {
                self.callback = callback
            }
            
            func cancel() {
                callback()
            }
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageLoaderProtocol.Result) -> Void) -> ImageLoadingDataTaskProtocol {
            messages.append((url, completion))
            
            return Task(callback: { [weak self] in
                self?.cancelledURLs.append(url)
            })
        }
        
        func completeLoad(with result: FeedImageLoaderProtocol.Result, at index: Int = 0) {
            messages[index].completion(result)
        }
    }
}


