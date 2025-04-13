//
//  LoadFeedImageFromCacheUseCaseTests.swift
//  EssentialFeed
//
//  Created by Anthony on 8/4/25.
//

import Foundation
import EssentialFeed
import XCTest

final class LoadFeedImageFromCacheUseCaseTests: XCTestCase {
    func test_init_deosNotRequestdatafromCache() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages.count, 0)
    }
    
    func test_loadImageDataFromURL_requestsDataFromCache() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url, completion: { _ in })
        
        XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: url)])
    }
    
    func test_loadImageDataFrom_deliversErrorOnStoreFailure() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        expect(sut, toFinishWith: failed(), from: url) {
            store.completeRetrieval(with: .failure(anyNSError()))
        }
    }
    
    func test_loadImageDataFromURL_deliversNotFoundErrorOnStoreSuccessWithNoData() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        expect(sut, toFinishWith: notFound(), from: url) {
            store.completeRetrieval(with: .success(nil))
        }
    }
    
    func test_loadImageDataFromURL_deliversDataOnStoreSuccessWithData() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        let expectedData = anydata()
        
        expect(sut, toFinishWith: .success(expectedData), from: url) {
            store.completeRetrieval(with: .success(expectedData))
        }
    }
    
    func test_loadImageDataFromURL_doesNotDeliversDataAfterCancellingTask() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        var receivedResult: LocalFeedImageDataLoader.Result?
        
        let task = sut.loadImageData(from: url) { receivedResult = $0 }
        task.cancel()
        
        store.completeRetrieval(with: .success(anydata()))
        store.completeRetrieval(with: .success(.none))
        store.completeRetrieval(with: failed())
        store.completeRetrieval(with: notFound())
        
        XCTAssertNil(receivedResult)
    }
    
    func test_loadImageDataFromURL_doesNotDeliversDataAfterSUTDeinit() {
        let store = FeedStoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        var receivedResults = [LocalFeedImageDataLoader.Result]()
        
        _ = sut?.loadImageData(from: anyURL()) { receivedResults.append($0) }
        sut = nil
        
        store.completeRetrieval(with: failed())
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_saveImageDataForURL_requestsImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        let data = anydata()
        
        sut.save(data, for: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.insert(dataFor: url)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(
        _ sut: LocalFeedImageDataLoader,
        toFinishWith expectedResult: FeedImageDataStore.RetrievalResult,
        from url: URL,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Waiting for load")
        _ = sut.loadImageData(from: url, completion: { actualResult in
            switch (actualResult, expectedResult) {
            case (.success(let actualData), .success(let expectedData)):
                XCTAssertEqual(actualData, expectedData, file: file, line: line)
            case (.failure(let actualError as LocalFeedImageDataLoader.LoadError), .failure(let expectedError as LocalFeedImageDataLoader.LoadError)):
                XCTAssertEqual(actualError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(actualResult) instead", file: file, line: line)
            }
            exp.fulfill()
        })
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failed() -> FeedImageDataStore.RetrievalResult {
        .failure(LocalFeedImageDataLoader.LoadError.failed)
    }
    
    private func notFound() -> FeedImageDataStore.RetrievalResult {
        .failure(LocalFeedImageDataLoader.LoadError.notFound)
    }
    
    private class FeedStoreSpy: FeedImageDataStore {
        enum Message: Equatable {
            case retrieve(dataFor: URL)
            case insert(dataFor: URL)
        }
        
        var receivedMessages: [Message] = []
        var completions: [(FeedImageDataStore.RetrievalResult) -> Void]  = []
        
        func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
            receivedMessages.append(.retrieve(dataFor: url))
            completions.append(completion)
        }
        
        func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
            receivedMessages.append(.insert(dataFor: url))
        }
        
        func completeRetrieval(with result: FeedImageDataStore.RetrievalResult, at index: Int = 0) {
            completions[index](result)
        }
    }
}
