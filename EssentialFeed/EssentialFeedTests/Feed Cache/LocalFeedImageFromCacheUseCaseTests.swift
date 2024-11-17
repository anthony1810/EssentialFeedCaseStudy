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
    enum Message: Equatable {
        case retrieveData(for: URL)
    }
    
    func retrieveData(for url: URL) {
        receivedMessages.append(.retrieveData(for: url))
    }
}

final class LocalFeedImageDataLoader: FeedImageLoaderProtocol {
    private let store: RealmFeedImageStoreSpy
    
    private class Task: ImageLoadingDataTaskProtocol {
        func cancel() {}
    }
    
    init(store: RealmFeedImageStoreSpy) {
        self.store = store
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageLoaderProtocol.Result) -> Void) -> any ImageLoadingDataTaskProtocol {
        store.retrieveData(for: url)
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
        
}

extension LocalFeedImageFromCacheUseCaseTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (store: RealmFeedImageStoreSpy, sut: LocalFeedImageDataLoader) {
        
        let store = RealmFeedImageStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(store)
        
        return (store, sut)
    }
}
