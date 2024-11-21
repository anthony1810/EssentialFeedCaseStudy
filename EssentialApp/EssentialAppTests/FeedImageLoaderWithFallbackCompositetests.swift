//
//  FeedImageLoaderWithFallbackCompositetests.swift
//  EssentialApp
//
//  Created by Anthony on 21/11/24.
//

import Foundation
import XCTest
import EssentialFeed

class FeedImageDataLoaderWithFallbackComposite: FeedImageLoaderProtocol {
    
    let primary: FeedImageLoaderProtocol
    let fallback: FeedImageLoaderProtocol
    
    private class Task: ImageLoadingDataTaskProtocol {
        func cancel() {
            
        }
    }
    
    init(primary: FeedImageLoaderProtocol, fallback: FeedImageLoaderProtocol) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageLoaderProtocol.Result) -> Void) -> ImageLoadingDataTaskProtocol {
        _ = primary.loadImageData(from: url, completion: { [weak self] result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure:
                _ = self?.fallback.loadImageData(from: url, completion: completion)
            }
        })
        return Task()
    }
}

class FeedImageLoaderWithFallbackCompositetests: XCTestCase {
    
    func test_loadImageData_doesNotRequestImageURLWhenInit() {
        let (_, primary, fallback) = makeSUT()
        
        XCTAssertTrue(primary.requestedURLs.isEmpty)
        XCTAssertTrue(fallback.requestedURLs.isEmpty)
    }
    
    func test_loadImageData_loadsFromPrimaryFirst() {
     
        let expectedImageURL = makeAnyUrl()
        let (sut, primary, fallback) = makeSUT()
        
        _ = sut.loadImageData(from: expectedImageURL, completion: {_ in })
        
        XCTAssertEqual(primary.requestedURLs, [expectedImageURL])
        XCTAssertTrue(fallback.requestedURLs.isEmpty)
    }
    
    func test_loadImageData_loadsFromFallBackOnPrimaryFails() {
        let expectedImageURL = makeAnyUrl()
        let expectedData = makeAnyData()
        let (sut, primary, fallback) = makeSUT()
        
        expect(sut: sut, toLoad: expectedImageURL, with: .success(expectedData)) {
            primary.completeLoad(with: .failure(makeAnyError()))
            fallback.completeLoad(with: .success(expectedData))
        }
    }
}

extension FeedImageLoaderWithFallbackCompositetests {
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoaderWithFallbackComposite, primary: LoaderSpy, fallback: LoaderSpy) {
        let primary = LoaderSpy()
        let fallback = LoaderSpy()
        
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primary, fallback: fallback)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(primary, file: file, line: line)
        trackForMemoryLeaks(fallback, file: file, line: line)
        
        return (sut, primary, fallback)
    }
    
    func expect(sut: FeedImageDataLoaderWithFallbackComposite, toLoad url: URL, with expectedResult: FeedImageLoaderProtocol.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
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
    
    private class LoaderSpy: FeedImageLoaderProtocol {
        var messages = [(url: URL, completion: ((FeedImageLoaderProtocol.Result) -> Void))]()
        var requestedURLs: [URL] {
            messages.map(\.url)
        }
        
        private class Task: ImageLoadingDataTaskProtocol {
            func cancel() {
                
            }
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageLoaderProtocol.Result) -> Void) -> ImageLoadingDataTaskProtocol {
            messages.append((url, completion))
            
            return Task()
        }
        
        func completeLoad(with result: FeedImageLoaderProtocol.Result, at index: Int = 0) {
            messages[index].completion(result)
        }
    }
}
