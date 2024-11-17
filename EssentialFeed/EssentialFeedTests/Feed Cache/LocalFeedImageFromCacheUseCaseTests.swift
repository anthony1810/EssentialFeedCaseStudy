//
//  LocalFeedImageFromCacheUseCaseTests.swift
//  EssentialFeed
//
//  Created by Anthony on 17/11/24.
//

import Foundation
import EssentialFeed
import XCTest

class LocalFeedImageStoreSpy {
    private(set) var receivedMessages: [Message] = []
    private var completions = [(Result) -> Void]()
    enum Message: Equatable {
        case retrieveData(for: URL)
    }
    
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieveData(for url: URL, completion: @escaping (Result) -> Void) {
        receivedMessages.append(.retrieveData(for: url))
        completions.append(completion)
    }
    
    func complete(with result: Result, at index: Int = 0) {
        completions[index](result)
    }
}

final class LocalFeedImageDataLoader: FeedImageLoaderProtocol {
    private let store: LocalFeedImageStoreSpy
    
    enum Error: Swift.Error, Equatable {
        case failed
        case notFound
    }
    
    private class Task: ImageLoadingDataTaskProtocol {
        private var completion: ((FeedImageLoaderProtocol.Result) -> Void)?
        
        init(completion: @escaping ((FeedImageLoaderProtocol.Result) -> Void)) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageLoaderProtocol.Result) {
            self.completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
        }
        
        func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    init(store: LocalFeedImageStoreSpy) {
        self.store = store
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageLoaderProtocol.Result) -> Void) -> any ImageLoadingDataTaskProtocol {
        let task = Task(completion: completion)
        
        store.retrieveData(for: url, completion: { result in
            switch result {
            case .failure:
//                completion(.failure(Error.failed))
                task.complete(with: .failure(Error.failed))
            case let .success(data):
                if let data {
//                    completion(.success(data))
                    task.complete(with: .success(data))
                } else {
//                    completion(.failure(Error.notFound))
                    task.complete(with: .failure(Error.notFound))
                }
            }
        })
        
        return task
    }
}

class LocalFeedImageFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreating() {
        let (store, _) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadImageFromURL_messagesStoreWithURL() {
        let (store, sut) = makeSUT()
        let requestedURL = makeAnyUrl()
        
        _ = sut.loadImageData(from: requestedURL, completion: {_ in })
        
        XCTAssertEqual(store.receivedMessages, [.retrieveData(for: requestedURL)])
    }
    
    func test_loadImageFromURL_deliversErrorOnStoreError() {
        let (store, sut) = makeSUT()
        
        expect(sut: sut, toFinishWith: failed()) {
            store.complete(with: .failure(makeAnyError()))
        }
    }
    
    func test_loadImageFromURL_deliversNotFoundErrorOnNoData() {
        let (store, sut) = makeSUT()
        
        expect(sut: sut, toFinishWith: notFound()) {
            store.complete(with: .success(.none))
        }
    }
    
    func test_loadImageFromURL_deliversImageDataOnSuccess() {
        let (store, sut) = makeSUT()
        let imageData = makeAnyData()
        
        expect(sut: sut, toFinishWith: .success(imageData)) {
            store.complete(with: .success(imageData))
        }
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultWhenTaskIsCancelled() {
        let (store, sut) = makeSUT()
        let imageData = makeAnyData()
        
        var receivedResults = [FeedImageLoaderProtocol.Result?]()
        let task = sut.loadImageData(from: makeAnyUrl()) { result in
            receivedResults.append(result)
        }
        task.cancel()
        
        store.complete(with: .success(imageData))
        store.complete(with: .success(.none))
        store.complete(with: .failure(makeAnyError()))
        
        XCTAssertTrue(receivedResults.isEmpty, "Expect Received result to be empty")
    }
}

extension LocalFeedImageFromCacheUseCaseTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (store: LocalFeedImageStoreSpy, sut: LocalFeedImageDataLoader) {
        
        let store = LocalFeedImageStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (store, sut)
    }
    
    func notFound() -> LocalFeedImageDataLoader.Result {
        .failure(LocalFeedImageDataLoader.Error.notFound)
    }
    
    func failed() -> LocalFeedImageDataLoader.Result {
        .failure(LocalFeedImageDataLoader.Error.failed)
    }
    
    func expect(
        sut: LocalFeedImageDataLoader,
        toFinishWith expectedResult: FeedImageLoaderProtocol.Result,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
      
        var capturedResult: FeedImageLoaderProtocol.Result?
        let exp = expectation(description: "wait for loading image from cache")
        _ = sut.loadImageData(from: makeAnyUrl(), completion: { result in
            capturedResult = result
            exp.fulfill()
        })
       
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        switch (capturedResult, expectedResult) {
        case let (
            .failure(capturedError as LocalFeedImageDataLoader.Error),
            .failure(expectedError as LocalFeedImageDataLoader.Error)
        ):
            XCTAssertEqual(capturedError, expectedError, file: file, line: line)
        case let (.success(capturedData), .success(expectedData)):
            XCTAssertEqual(capturedData, expectedData, file: file, line: line)
        default: XCTFail("expected \(expectedResult), got \(String(describing: capturedResult)) result", file: file, line: line)
        }
    }
}
