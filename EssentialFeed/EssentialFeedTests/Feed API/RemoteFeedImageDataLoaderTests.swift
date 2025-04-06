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
    
    enum Error: Swift.Error {
        case invalidData
    }
    
    private class Task: FeedImageDataLoaderTask {
        private let callback: () -> Void
        
        init(callback: @escaping () -> Void) {
            self.callback = callback
        }
        
        func cancel() {
            callback()
        }
    }
    
    @discardableResult
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = client.get(from: url, completion: { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, res)):
                if res.statusCode == 200 {
                    completion(.success(data))
                } else {
                    completion(.failure(Error.invalidData))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        })
        
        return Task { task.cancel() }
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
        let expectedError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(expectedError)) {
            client.complete(withError: expectedError)
        }
    }
    
    func test_loadImageData_returnsDataOnSuccess() {
        let (sut, client) = makeSUT()
        let expectedData = anydata()
        
        expect(sut, toCompleteWith: .success(expectedData)) {
            client.complete(withStatusCode: 200, data: expectedData)
        }
    }
    
    func test_loadImageData_returnsErrorOnHTTPStatusCodeOtherThan200() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, statusCode in
            expect(sut, toCompleteWith: .failure(RemoteFeedImageDataLoader.Error.invalidData)) {
                client.complete(withStatusCode: 404, at: index)
            }
        }
    }
    
    func test_loadImageData_doesNotDeliverDataAfterInstanceDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageDataLoader? = .init(client: client)
        var result: FeedImageDataLoader.Result?
        
        sut?.loadImageData(from: anyURL(), completion: { result = $0 })
        sut = nil
        client.complete(withStatusCode: 200)
        
        XCTAssertNil(result)
    }
    
    func test_cancelLoadImageData_cancelsPendingRequest() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url, completion: { _ in })
        XCTAssertTrue(client.cancelledImageURLs.isEmpty, "make sure loading image is not being cancelled until ")
        
        task.cancel()
        XCTAssertEqual(client.cancelledImageURLs , [url], "Expect the URL to be cancelled")
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (RemoteFeedImageDataLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        
        trackMemoryLeaks(client, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return (sut, client)
    }
    
    func expect(
        _ sut: RemoteFeedImageDataLoader,
        toCompleteWith expectedResult: FeedImageDataLoader.Result?,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line) {
            let exp = expectation(description: "Wait for completion")
            sut.loadImageData(from: anyURL()) { receivedResult in
                switch (expectedResult, receivedResult) {
                case let (.success(expectedData), .success(receivedData)):
                    XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                case let (.failure(expectedError as NSError), .failure(receivedError as NSError)):
                    XCTAssertEqual(expectedError, receivedError, file: file, line: line)
                default:
                    XCTFail(
                        "Expected result to be \(String(describing: expectedResult)), but got \(receivedResult) instead",
                        file: file,
                        line: line
                    )
                }
                exp.fulfill()
            }
            
            action()
            wait(for: [exp], timeout: 1.0)
    }
    
    private class HTTPClientSpy: HTTPClient {
        typealias Message = (url: URL, completion: (HTTPClient.Result) -> Void)
        var messages: [Message] = []
        
        var requestedURLs: [URL] {
            messages.map(\.url)
        }
        var cancelledImageURLs: [URL] = []
        
        private class Task: HTTPClientTask {
            let callback: (() -> Void)
            
            init(callback: @escaping () -> Void) {
                self.callback = callback
            }
            func cancel() {
                callback()
            }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            messages.append((url, completion))
            
            return Task { [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }
        
        func complete(withError error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode statusCode: Int, data: Data = Data(), at index: Int = 0) {
            let res = HTTPURLResponse(url: requestedURLs[index], statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success((data, res)))
        }
    }
        
}
