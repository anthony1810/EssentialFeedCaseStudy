import XCTest
import EssentialFeed

final class FeedImageLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primary: FeedImageDataLoader
    private let fallback: FeedImageDataLoader
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapped: FeedImageDataLoaderTask?
        
        func cancel() {
            wrapped?.cancel()
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = TaskWrapper()
        
        task.wrapped = primary.loadImageData(from: url) { [weak self] primaryResult in
            switch primaryResult {
            case .success:
                completion(primaryResult)
                
            case .failure:
                task.wrapped = self?.fallback.loadImageData(from: url, completion: completion)
            }
        }
        
        return task
    }
}

final class FeedImageLoaderWithFallbackCompositeTests: XCTestCase {
    func test_loadImageData_doesNotLoadImageDataOnInitialization() {
        let (_, primary, fallback) = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(anydata()))
        
        XCTAssertEqual(primary.loadedImageURLs.count, 0)
        XCTAssertEqual(fallback.loadedImageURLs.count, 0)
    }
    
    func test_loadImageData_loadsImageDataFromPrimaryFirst() {
        let imageURL = anyURL()
        let (sut, primary, fallback) = makeSUT(
            primaryResult: .success(anydata()),
            fallbackResult: .failure(anyNSError())
        )
        
        _ = sut.loadImageData(from: imageURL) { _ in }
        
        XCTAssertEqual(primary.loadedImageURLs, [imageURL])
        XCTAssertTrue(fallback.loadedImageURLs.isEmpty)
    }
    
    func test_loadImageData_deliversPrimaryDataOnPrimarySuccess() {
        let primaryData = anydata()
        let fallbackData = anydata()
        
        let (sut, primary, _) = makeSUT(primaryResult: .success(primaryData), fallbackResult: .success(fallbackData))
        
        expect(sut, toFinishWith: .success(primaryData), when: {
            primary.completeAtIndex()
        })
    }
    
    func test_loadImageData_deliversFallbackDataOnPrimaryFailure() {
        let primaryError = anyNSError()
        let fallbackData = anydata()
        
        let (sut, primary, fallback) = makeSUT(primaryResult: .failure(primaryError), fallbackResult: .success(fallbackData))
        
        expect(sut, toFinishWith: .success(fallbackData), when: {
            primary.completeAtIndex()
            fallback.completeAtIndex()
        })
    }
    
    func test_loadImageData_deliversErrorWhenBothPrimaryAndFallbackFail() {
        let (sut, primary, fallback) = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .failure(anyNSError()))
        
        expect(sut, toFinishWith: .failure(anyNSError()), when: {
            primary.completeAtIndex()
            fallback.completeAtIndex()
        })
    }
    
    func test_cancelLoadImageData_cancelsPrimaryLoaderTask() {
        let (sut, primaryLoader, fallbackLoader) = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .failure(anyNSError()))
        
        let task = sut.loadImageData(from: anyURL()) { _ in }
        task.cancel()
        
        XCTAssertEqual(primaryLoader.cancelURLs.count, 1)
        XCTAssertEqual(fallbackLoader.cancelURLs.count, 0)
    }
    
    func test_cancelLoadImageData_cancelsFallbackLoaderTask() {
        let (sut, primaryLoader, fallbackLoader) = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .failure(anyNSError()))
        
        let task = sut.loadImageData(from: anyURL()) { _ in }
        primaryLoader.completeAtIndex()
        task.cancel()
        
        XCTAssertEqual(primaryLoader.cancelURLs.count, 0)
        XCTAssertEqual(fallbackLoader.cancelURLs.count, 1)
    }
    
    // MARK: - Helpers
    private func makeSUT(
        primaryResult: FeedImageDataLoader.Result,
        fallbackResult: FeedImageDataLoader.Result,
        file: StaticString = #filePath,
        line: UInt = #line) -> (sut: FeedImageLoaderWithFallbackComposite, primary: ImageLoaderStub, fallback: ImageLoaderStub) {
            
            let primaryLoader = ImageLoaderStub(result: primaryResult)
            let fallbackLoader = ImageLoaderStub(result: fallbackResult)
            
            let sut = FeedImageLoaderWithFallbackComposite(
                primary: primaryLoader,
                fallback: fallbackLoader
            )
            
            trackMemoryLeaks(primaryLoader, file: file, line: line)
            trackMemoryLeaks(fallbackLoader, file: file, line: line)
            trackMemoryLeaks(sut, file: file, line: line)
            
            return (sut, primaryLoader, fallbackLoader)
        }
    
    private func expect(
        _ sut: FeedImageLoaderWithFallbackComposite,
        toFinishWith expectedResult: FeedImageDataLoader.Result,
        when action: () -> Void,
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
        
        action()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    private class ImageLoaderStub: FeedImageDataLoader {
        private struct Task: FeedImageDataLoaderTask {
            private var callback: (() -> Void)
            
            init(callback: @escaping () -> Void) {
                self.callback = callback
            }
            
            func cancel() {
                callback()
            }
        }
        
        private let result: FeedImageDataLoader.Result
        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        private(set) var cancelURLs: [URL] = []
        
        var loadedImageURLs: [URL] {
            messages.map { $0.url }
        }
        
        init(result: FeedImageDataLoader.Result) {
            self.result = result
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            messages.append((url, completion))
            return Task(callback: { [weak self] in
                self?.cancelURLs.append(url)
            })
        }
        
        func completeAtIndex(_ index: Int = 0) {
            messages[index].completion(result)
        }
      
    }
}
