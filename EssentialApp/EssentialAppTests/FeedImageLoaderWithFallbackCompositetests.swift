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
        var wrapped: ImageLoadingDataTaskProtocol?
        
        func cancel() {
            wrapped?.cancel()
        }
    }
    
    init(primary: FeedImageLoaderProtocol, fallback: FeedImageLoaderProtocol) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageLoaderProtocol.Result) -> Void) -> ImageLoadingDataTaskProtocol {
        let task = Task()

        task.wrapped = primary.loadImageData(from: url, completion: { [weak self] result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure:
                task.wrapped = self?.fallback.loadImageData(from: url, completion: completion)
            }
        })
        
        return task
    }
}

class FeedImageLoaderWithFallbackCompositetests: XCTestCase {
    
    func test_loadImageData_doesNotRequestImageURLWhenInit() {
        let (_, primary, fallback) = makeSUT()
        
        XCTAssertTrue(primary.loadedURLs.isEmpty)
        XCTAssertTrue(fallback.loadedURLs.isEmpty)
    }
    
    func test_loadImageData_loadsFromPrimaryFirst() {
     
        let expectedImageURL = makeAnyUrl()
        let (sut, primary, fallback) = makeSUT()
        
        _ = sut.loadImageData(from: expectedImageURL, completion: {_ in })
        
        XCTAssertEqual(primary.loadedURLs, [expectedImageURL])
        XCTAssertTrue(fallback.loadedURLs.isEmpty)
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
    
    func test_loadImageData_loadsfromFallBackOnPrimaryFails2() {
        let expectedImageURL = makeAnyUrl()
        let (sut, primary, fallback) = makeSUT()
        
        _ = sut.loadImageData(from: expectedImageURL, completion: {_ in })
        primary.completeLoad(with: .failure(makeAnyError()))
        
        XCTAssertEqual(fallback.loadedURLs,  [expectedImageURL])
    }
    
    func test_loadImageData_cancelsTaskCancelPrimaryLoad() {
        let expectedImageURL = makeAnyUrl()
        let (sut, primary, _) = makeSUT()
        
        let task = sut.loadImageData(from: expectedImageURL, completion: {_ in })
        task.cancel()
        primary.completeLoad(with: .success(makeAnyData()))
        
        XCTAssertEqual(primary.cancelledURLs,  [expectedImageURL])
    }
    
    func test_loadImageData_cencelsTaskCancelFallbackLoadOnPrimaryFailure() {
        let expectedImageURL = makeAnyUrl()
        let (sut, primary, fallback) = makeSUT()
        
        let task = sut.loadImageData(from: expectedImageURL, completion: {_ in })
        primary.completeLoad(with: .failure(makeAnyError()))
        task.cancel()
        
        XCTAssertEqual(fallback.cancelledURLs,  [expectedImageURL])
    }
    
    func test_loadImageData_deliversPrimaryDataOnPrimarySucceeds() {
        let expectedImageURL = makeAnyUrl()
        let expectedImageData = makeAnyData()
        let (sut, primary, fallback) = makeSUT()
        
        expect(sut: sut, toLoad: expectedImageURL, with: .success(expectedImageData)) {
            primary.completeLoad(with: .success(expectedImageData))
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
