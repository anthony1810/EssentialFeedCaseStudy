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
        
        expect(sut, toFinishWith: .success(primaryData))
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
    
    private func expect(
        _ sut: FeedImageLoaderWithFallbackComposite,
        toFinishWith expectedResult: FeedImageDataLoader.Result,
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
        
        wait(for: [expectation], timeout: 1.0)
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
