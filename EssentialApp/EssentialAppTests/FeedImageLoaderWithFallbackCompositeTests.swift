import XCTest
import EssentialFeed
import EssentialApp

final class FeedImageLoaderWithFallbackCompositeTests: XCTestCase, FeedImageDataLoaderTestable {
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
        line: UInt = #line) -> (sut: FeedImageLoaderWithFallbackComposite, primary: ImageLoaderSpy, fallback: ImageLoaderSpy) {
            
            let primaryLoader = ImageLoaderSpy(result: primaryResult)
            let fallbackLoader = ImageLoaderSpy(result: fallbackResult)
            
            let sut = FeedImageLoaderWithFallbackComposite(
                primary: primaryLoader,
                fallback: fallbackLoader
            )
            
            trackMemoryLeaks(primaryLoader, file: file, line: line)
            trackMemoryLeaks(fallbackLoader, file: file, line: line)
            trackMemoryLeaks(sut, file: file, line: line)
            
            return (sut, primaryLoader, fallbackLoader)
        }
}
