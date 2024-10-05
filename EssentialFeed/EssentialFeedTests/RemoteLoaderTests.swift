//
//  RemoteLoaderTests.swift
//  EssentialFeed
//
//  Created by Anthony on 5/10/24.
//

import XCTest
@testable import EssentialFeed

class RemoteLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFrçomURL() {
        
        // Given (Arrange)
        let (client, _) = makeSUT()
        
        // Then
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        let targetURL = URL(string: "https:/a-url.com")!
        let (client, sut) = makeSUT(url: targetURL)
        
        sut.load(completion: {_ in })
        
        XCTAssertEqual(client.requestedURLs, [targetURL])
    }
     
    func test_loadTwice_requestsDataFromURLTwice() {
        let targetURL = URL(string: "https:/a-url.com")!
        let (client, sut) = makeSUT()
        
        sut.load(completion: {_ in })
        sut.load(completion: {_ in })
        
        XCTAssertEqual(client.requestedURLs, [targetURL, targetURL])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (client, sut) = makeSUT()
        var capturedErrors = [RemoteFeedLoader.Error]()
        
        sut.load(completion: {
            if case let .error(error) = $0, let appError = error as? RemoteFeedLoader.Error {
                capturedErrors.append(appError)
            }
        })
        client.complete(with: NSError(domain: "test error", code: 0))
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_load_deliversErrorOnHTTPError() {
        let (client, sut) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
       
        samples.enumerated().forEach { index, statusCode in
            var capturedErrors = [RemoteFeedLoader.Error]()
            sut.load(completion: {
                if case let .error(error) = $0, let appError = error as? RemoteFeedLoader.Error {
                    capturedErrors.append(appError)
                }
            })
            client.complete(with: statusCode, at: index)
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJson() {
        let (client, sut) = makeSUT()
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load(completion: {
            if case let .error(error) = $0, let appError = error as? RemoteFeedLoader.Error {
                capturedErrors.append(appError)
            }
        })
        
        let invalidJson = Data("invalidJson".utf8)
        client.complete(with: 200, data: invalidJson)
        
        XCTAssertEqual(capturedErrors, [.invalidData])
    }
}

// MARK: - Helpers
extension RemoteLoaderTests {
    private func makeSUT(url: URL = URL(string: "https:/a-url.com")!) -> (HTTPClientSpy, EssentialFeed.RemoteFeedLoader) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(httpClient: client, url: url)
        
        return (client, sut)
    }
}


class HTTPClientSpy: HTTPClient {
    
    var requestedURLs: [URL] {
        messages.map(\.url)
    }
    
    var messages : [(url: URL, completion: (HTTPClientResult) -> Void)]
    
    init() {
        self.messages = []
    }
    
    func get(url: URL, completion: @escaping (EssentialFeed.HTTPClientResult) -> Void) {
        messages.append((url, completion))
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(with statusCode: Int, data: Data = Data(), at index: Int = 0) {
        let response = HTTPURLResponse(
            url: messages[index].url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        messages[index].completion(.success(response, data))
    }
}
