//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeed
//
//  Created by Anthony on 5/4/25.
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT(url: anyURL())
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_loadImageData_requestsDataFromURL() {
        let expectedURL = anyURL()
        let (sut, client) = makeSUT()
    
        _ = sut.loadImageData(from: expectedURL) { _ in }
        XCTAssertEqual(client.requestedURLs, [expectedURL])
        
        _ = sut.loadImageData(from: expectedURL) { _ in }
        _ = sut.loadImageData(from: expectedURL) { _ in }
        XCTAssertEqual(client.requestedURLs, [expectedURL, expectedURL, expectedURL])
    }
    
    func test_loadImageData_deliversErrorOnEmptyData() {
        let (sut, client) = makeSUT()
        let emptyData = Data()
        
        expect(sut, toCompleteWith: .failure(RemoteFeedImageDataLoader.Error.invalidData)) {
            client.complete(withStatusCode: 200, data: emptyData)
        }
    }
    
    func test_loadImageData_deliversConnectivityErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(RemoteFeedImageDataLoader.Error.connectivity)) {
            client.complete(withError: anyNSError())
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
        
        _ = sut?.loadImageData(from: anyURL(), completion: { result = $0 })
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
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("non-empty data".utf8)
        
        var receivedResult: FeedImageDataLoader.Result?
        let task = sut.loadImageData(from: anyURL()) { receivedResult = $0 }
        task.cancel()
        
        client.complete(withStatusCode: 200, data: nonEmptyData)
        client.complete(withStatusCode: 404, data: anydata())
        client.complete(withError: anyNSError())
        
        XCTAssertNil(receivedResult)
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
            _ = sut.loadImageData(from: anyURL()) { receivedResult in
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
}
