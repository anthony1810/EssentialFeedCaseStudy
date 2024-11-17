//
//  LocalFeedImageFromCacheUseCaseTests.swift
//  EssentialFeed
//
//  Created by Anthony on 17/11/24.
//

import Foundation
import EssentialFeed
import XCTest

class RealmFeedImageStoreSpy {
    private(set) var receivedMessages: [Message] = []
    private var completions = [(Result) -> Void]()
    enum Message: Equatable {
        case retrieveData(for: URL)
    }
    
    typealias Result = Swift.Result<Data, Error>
    
    func retrieveData(for url: URL, completion: @escaping (Result) -> Void) {
        receivedMessages.append(.retrieveData(for: url))
        completions.append(completion)
    }
    
    func complete(with result: Result, at index: Int = 0) {
        completions[index](result)
    }
}

final class LocalFeedImageDataLoader: FeedImageLoaderProtocol {
    private let store: RealmFeedImageStoreSpy
    
    enum Error: Swift.Error {
        case failed
    }
    
    private class Task: ImageLoadingDataTaskProtocol {
        func cancel() {}
    }
    
    init(store: RealmFeedImageStoreSpy) {
        self.store = store
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageLoaderProtocol.Result) -> Void) -> any ImageLoadingDataTaskProtocol {
        store.retrieveData(for: url, completion: { result in
            completion(.failure(Error.failed))
        })
        return Task()
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
        
        expect(sut: sut, toFinishWith: .failure(makeAnyError())) {
            store.complete(with: .failure(makeAnyError()))
        }
    }
}

extension LocalFeedImageFromCacheUseCaseTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (store: RealmFeedImageStoreSpy, sut: LocalFeedImageDataLoader) {
        
        let store = RealmFeedImageStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(store)
        
        return (store, sut)
    }
    
    func expect(sut: LocalFeedImageDataLoader, toFinishWith expectedResult: FeedImageLoaderProtocol.Result, when action: () -> Void) {
      
        var capturedResult: FeedImageLoaderProtocol.Result?
        let exp = expectation(description: "wait for loading image from cache")
        _ = sut.loadImageData(from: makeAnyUrl(), completion: { result in
            capturedResult = result
            exp.fulfill()
        })
       
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        switch (capturedResult, expectedResult) {
        case (.failure, .failure):
            break
        case let (.success(capturedData), .success(expectedData)):
            XCTAssertEqual(capturedData, expectedData)
        default: XCTFail("expected \(expectedResult), got \(String(describing: capturedResult)) result")
        }
    }
}
