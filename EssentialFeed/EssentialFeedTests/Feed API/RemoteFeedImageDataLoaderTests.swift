//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeed
//
//  Created by Anthony on 5/4/25.
//

import XCTest
import EssentialFeed

final class RemoteFeedImageDataLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) {
        client.get(from: url, completion: { result in
            if case let .failure(error) = result {
                completion(.failure(error))
            }
        })
    }
}

class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT(url: anyURL())
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_loadImageData_requestsDataFromURL() {
        let expectedURL = anyURL()
        let (sut, client) = makeSUT()
    
        sut.loadImageData(from: expectedURL) { _ in }
        XCTAssertEqual(client.requestedURLs, [expectedURL])
        
        sut.loadImageData(from: expectedURL) { _ in }
        sut.loadImageData(from: expectedURL) { _ in }
        XCTAssertEqual(client.requestedURLs, [expectedURL, expectedURL, expectedURL])
    }
    
    func test_loadImageData_returnsErrorOnClientError() {
        let (sut, client) = makeSUT()
        var receivedError: Error?
        
        let exp = expectation(description: "Wait for completion")
        sut.loadImageData(from: anyURL()) { result in
            if case let .failure(error) = result {
                receivedError = error
            }
            exp.fulfill()
        }
        client.complete(withError: anyNSError())
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNotNil(receivedError)
    }

    
    // MARK: - Helpers
    private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (RemoteFeedImageDataLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        
        trackMemoryLeaks(client, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        typealias Message = (url: URL, completion: (HTTPClient.Result) -> Void)
        var messages: [Message] = []
        var requestedURLs: [URL] {
            messages.map(\.url)
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(withError error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
    }
        
}
