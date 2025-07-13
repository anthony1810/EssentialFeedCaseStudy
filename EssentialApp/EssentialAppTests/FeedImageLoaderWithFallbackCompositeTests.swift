import XCTest
import EssentialFeed

final class FeedImageLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primary: FeedImageDataLoader
    private let fallback: FeedImageDataLoader
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        return primary.loadImageData(from: url, completion: completion)
    }
}

final class FeedImageLoaderWithFallbackCompositeTests: XCTestCase {
    func test_loadImageData_deliversPrimaryDataOnPrimarySuccess() {
        let primaryData = anydata()
        let fallbackData = anydata()
        
        let sut = makeSUT(primaryResult: .success(primaryData), fallbackResult: .success(fallbackData))
        
        let expectation = self.expectation(description: "wait for image data to load")
        _ = sut.loadImageData(from: anyURL()) { actualResult in
            if case .success(let actualData) = actualResult {
                XCTAssertEqual(actualData, primaryData)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Helpers
    private func makeSUT(
        primaryResult: FeedImageDataLoader.Result,
        fallbackResult: FeedImageDataLoader.Result,
        file: StaticString = #filePath,
        line: UInt = #line) -> FeedImageLoaderWithFallbackComposite {
            
            let primaryLoader = ImageLoaderStub(result: primaryResult)
            let fallbackLoader = ImageLoaderStub(result: fallbackResult)
            
            let sut = FeedImageLoaderWithFallbackComposite(
                primary: primaryLoader,
                fallback: fallbackLoader
            )
            
            trackMemoryLeaks(primaryLoader, file: file, line: line)
            trackMemoryLeaks(fallbackLoader, file: file, line: line)
            trackMemoryLeaks(sut, file: file, line: line)
            
            return sut
        }
    
    private class ImageLoaderStub: FeedImageDataLoader {
        private let result: FeedImageDataLoader.Result
        
        init(result: FeedImageDataLoader.Result) {
            self.result = result
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            completion(result)
            return Task()
        }
        
        private struct Task: FeedImageDataLoaderTask {
            func cancel() {}
        }
    }
}
