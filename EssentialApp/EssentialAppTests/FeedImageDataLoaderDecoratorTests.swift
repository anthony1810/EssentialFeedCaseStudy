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
    
    private func expect(sut: FeedImageLoaderProtocol, toLoad url: URL, with expectedResult: FeedImageLoaderProtocol.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load")
        _ = sut.loadImageData(from: url, completion: { actualResult in
            switch (actualResult, expectedResult) {
            case let (.success(actualData), .success(expectedData)):
                XCTAssertEqual(actualData, expectedData, file: file, line: line)
            case let (.failure(actualError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(actualError, expectedError)
            default:
                XCTFail("Expect \(expectedResult), but got \(actualResult) instead")
            }
            exp.fulfill()
        })
        
        action()
        
        wait(for: [exp], timeout: 1.0)
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


