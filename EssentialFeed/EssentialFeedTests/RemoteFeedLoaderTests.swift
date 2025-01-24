//
//  FeedLoaderTests.swift
//  EssentialFeed
//
//  Created by Anthony on 23/1/25.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT(url: anyURL())
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_load_requestsDataFromURL() {
        let requestURL = anyURL()
        let (sut, client) = makeSUT(url: requestURL)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [requestURL])
    }
    
    func test_loadTwice_requestsDataTwiceFromURL() {
        let requestURL = anyURL()
        let (sut, client) = makeSUT(url: requestURL)
        
        sut.load() {_ in }
        sut.load() {_ in }
        
        XCTAssertEqual(client.requestedURLs, [requestURL, requestURL])
    }
    
    func test_load_deliversErrorOnConnectionError() {
        let (sut, client) = makeSUT(url: anyURL())
        
        var receivedErrors = [RemoteFeedLoader.Error?]()
        sut.load { receivedErrors.append($0) }
        client.complete(withError: anyError())
        
        XCTAssertEqual(receivedErrors, [RemoteFeedLoader.Error.connectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, statusCode in
            var receivedErrors = [RemoteFeedLoader.Error?]()
            sut.load { receivedErrors.append($0) }
            client.complete(withStatusCode: statusCode, at: index)
            XCTAssertEqual(receivedErrors, [RemoteFeedLoader.Error.invalidData])
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJson() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        var receivedErrors: [RemoteFeedLoader.Error?] = []
        sut.load { receivedErrors.append($0) }
        client.complete(withStatusCode: 200, data: anyInvalidJson())
        
        XCTAssertEqual(receivedErrors, [RemoteFeedLoader.Error.invalidData])
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let loader = RemoteFeedLoader(url: url, client: client)
        
        return (loader, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        typealias Message = (url: URL, completion:(Result<(Data, HTTPURLResponse), Error>) -> Void)
        
        var messages = [Message]()
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(withError error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode statusCode: Int, data: Data = Data(), at index: Int = 0) {
            messages[index].completion(
                .success(
                    (data,
                    HTTPURLResponse(
                        url: requestedURLs[index],
                        statusCode: statusCode,
                        httpVersion: nil, headerFields: nil)!)
                )
            )
        }
    }
    
}

func anyURL() -> URL {
    URL(string: "https://example.com")!
}

func anyError() -> Swift.Error {
    NSError(domain: "Test", code: 0, userInfo: nil)
}

func anyInvalidJson() -> Data {
    Data("any json".utf8)
}
