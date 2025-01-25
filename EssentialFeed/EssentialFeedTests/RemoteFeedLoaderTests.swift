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
        
        expect(sut, toFinishedWith: .failure(.connectivity)) {
            client.complete(withError: anyError())
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, statusCode in
            expect(sut, toFinishedWith: .failure(.invalidData)) {
                client.complete(withStatusCode: statusCode, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJson() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        expect(sut, toFinishedWith: .failure(.invalidData)) {
            client.complete(withStatusCode: 200, data: anyInvalidJson())
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJson() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        let emptyJsonData = Data("{ \"items\": [] }".utf8)
        
        expect(sut, toFinishedWith: .success([])) {
            client.complete(withStatusCode: 200, data: emptyJsonData)
        }
    }

    // MARK: - Helpers
    private func makeSUT(url: URL) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let loader = RemoteFeedLoader(url: url, client: client)
        
        return (loader, client)
    }
    
    private func expect(
        _ sut: RemoteFeedLoader,
        toFinishedWith expectedResult: RemoteFeedLoader.Result,
        when action: @escaping () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var capturedResults: [RemoteFeedLoader.Result] = []
        sut.load { capturedResults.append($0) }
        action()
        
        XCTAssertEqual(capturedResults, [expectedResult], file: file, line: line)
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
