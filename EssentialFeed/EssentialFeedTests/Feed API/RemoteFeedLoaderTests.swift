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
        
        expect(sut, toFinishedWith: failure(.connectivity)) {
            client.complete(withError: anyError())
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, statusCode in
            expect(sut, toFinishedWith: failure(.invalidData)) {
                client.complete(withStatusCode: statusCode, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJson() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        expect(sut, toFinishedWith: failure(.invalidData)) {
            client.complete(withStatusCode: 200, data: anyInvalidJson())
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJson() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        expect(sut, toFinishedWith: .success([])) {
            client.complete(withStatusCode: 200, data: makeItemsJson([]))
        }
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithValidJson() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        let (feedImage0, itemJson0) = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: anyURL()
        )
        
        let (feedImage1, itemJson1) = makeItem(
            id: UUID(),
            description: nil,
            location:  nil,
            imageURL: anyURL()
        )
        
        expect(sut, toFinishedWith: .success([feedImage0, feedImage1])) {
            client.complete(withStatusCode: 200, data: makeItemsJson([itemJson0, itemJson1]))
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceIsDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: anyURL(), client: client)
        
        var receivedResult: RemoteFeedLoader.Result?
        sut?.load { result in
            receivedResult = result
        }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJson([]))
        
        XCTAssertNil(receivedResult, "Does not deliver result after instance is deallocated")
    }

    // MARK: - Helpers
    private func makeSUT(url: URL,file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let loader = RemoteFeedLoader(url: url, client: client)
        
        trackMemoryLeaks(client, file: file, line: line)
        trackMemoryLeaks(loader, file: file, line: line)
        
        return (loader, client)
    }
    
    private func expect(
        _ sut: RemoteFeedLoader,
        toFinishedWith expectedResult: RemoteFeedLoader.Result,
        when action: @escaping () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for load completion")
        
        sut.load { capturedResult in
            switch (capturedResult, expectedResult) {
            case let (.success(capturedItems), .success(expectedItems)):
                XCTAssertEqual(capturedItems, expectedItems, file: file, line: line)
            case let (.failure(capturedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(capturedError, expectedError, file: file, line: line)
            default:
                XCTFail("expected \(expectedResult) got \(capturedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        .failure(error)
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

func anydata() -> Data {
    Data("any data".utf8)
}

func makeItemsJson(_ items: [[String: Any]]) -> Data {
    let json = [
        "items": items
    ].compactMapValues { $0 }
    
    return try! JSONSerialization.data(withJSONObject: json)
}

func anyNonHTTPURLResponse() -> URLResponse {
    URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
}

func anyHTTPURLResponse() -> HTTPURLResponse {
    HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
}

func makeItem(
    id: UUID,
    description: String?,
    location: String?,
    imageURL: URL)
-> (model: FeedItem, json: [String: Any]) {
    let feedItem = FeedItem(
        id: id,
        description: description,
        location: location,
        imageURL: imageURL
    )
    
    let itemJson0: [String: Any] = [
        "id": id.uuidString,
        "description": description,
        "location": location,
        "image": imageURL.absoluteString
    ].compactMapValues { $0 }
    
    return (feedItem, itemJson0)
}
