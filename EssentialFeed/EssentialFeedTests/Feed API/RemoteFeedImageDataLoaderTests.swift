//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeed
//
//  Created by Anthony on 9/11/24.
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotPerformAnyURLReuqest() {
        
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestedURLs.count, 0)
    }
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        let (sut, client) = makeSUT()
        let url = makeAnyUrl()
        
        sut.loadImageData(from: url, completion: { _ in })
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataFromURL_requestsDataTwice() {
        let (sut, client) = makeSUT()
        let url = makeAnyUrl()
        
        sut.loadImageData(from: url, completion: { _ in })
        sut.loadImageData(from: url, completion: { _ in })
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let expectedError = makeAnyError()
        
        expect(sut, toCompleteWith: .failure(expectedError)) {
            client.didFinishLoadImageWithFailure(expectedError)
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOnNon200Response() {
        let (sut, client) = makeSUT()
        let expectedError = RemoteFeedImageDataLoader.Error.invalidData
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, statusCode in
            expect(sut, toCompleteWith: .failure(expectedError)) {
                client.didFinishLoadImageWithStatusCode(statusCode, data: self.makeAnyData(), at: index)
            }
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidImageDataOn200ResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        let expectedError = RemoteFeedImageDataLoader.Error.invalidData
        
        expect(sut, toCompleteWith: .failure(expectedError)) {
            client.didFinishLoadImageWithStatusCode(200, data: Data())
        }
    }
    
    func test_loadImageDataFromURL_deliversImageDataOn200ResponseWithValidData() {
        let (sut, client) = makeSUT()
        let expectedImageData = makeAnyData()
        
        expect(sut, toCompleteWith: .success(expectedImageData)) {
            client.didFinishLoadImageWithStatusCode(200, data: expectedImageData)
        }
    }
    
    func test_loadImageDataFromURL_doesNotDeliversResultWhenInstanceIsDeallocated() {
        let (_, client) = makeSUT()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
        
        var capturedResult: FeedImageLoaderProtocol.Result?
        sut?.loadImageData(from: makeAnyUrl(), completion: { capturedResult = $0 })
        sut = nil
        
        client.didFinishLoadImageWithStatusCode(200, data: makeAnyData())
        
        XCTAssertNil(capturedResult)
    }
    
    func test_cancelLoadImageDataURLTask_cancelClientURLRequest() {
        let (sut, client) = makeSUT()
        let imageURL = makeAnyUrl()
        
        let task = sut.loadImageData(from: imageURL, completion: {_ in })
        task.cancel()
        
        XCTAssertEqual(client.cancelledURLs, [imageURL])
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultWhenTaskIsCancelled() {
        let (sut, client) = makeSUT()
        let imageURL = makeAnyUrl()
        let nonEmptyData = makeAnyData()
        
        var receivedResults = [FeedImageLoaderProtocol.Result?]()
        let task = sut.loadImageData(from: imageURL, completion: { receivedResults.append($0) })
        task.cancel()
        
        client.didFinishLoadImageWithStatusCode(200, data: nonEmptyData)
        
        XCTAssertTrue(receivedResults.isEmpty, "Expect Received result to be empty")
    }
}

// MARK: - Helpers
extension RemoteFeedImageDataLoaderTests {
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: ClientSpy) {
        let client = ClientSpy()
        let loader = RemoteFeedImageDataLoader(client: client)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        
        return (loader, client)
    }
    
    func expect(
        _ sut: RemoteFeedImageDataLoader,
        toCompleteWith expectedResult: FeedImageLoaderProtocol.Result,
        when action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let url = makeAnyUrl()
        var result: FeedImageLoaderProtocol.Result?
        let exp = expectation(description: "Waiting for load image data completion")
       
        sut.loadImageData(from: url) { receivedResult in
            result = receivedResult
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        switch (result, expectedResult) {
        case let (.success(receivedData), .success(expectedData)):
            XCTAssertEqual(
                receivedData, expectedData,
                file: file,
                line: line
            )
        case let (.failure(receivedError as RemoteFeedImageDataLoader.Error?), .failure(expectedError as RemoteFeedImageDataLoader.Error?)):
            XCTAssertEqual(
                receivedError, expectedError,
                file: file,
                line: line
            )
        case let (.failure(receivedError as NSError?), .failure(expectedError as NSError?)):
            XCTAssertEqual(
                receivedError?.code, expectedError?.code,
                file: file,
                line: line
            )
        default:
            XCTFail(
                "expected \(expectedResult), got \(String(describing: result)) instead",
                file: file,
                line: line
            )
        }
    }
    
    final class ClientSpy: HTTPClient {
        
        private struct Task: HTTPClientTask {
            let callback: () -> Void
            func cancel() {
                callback()
            }
        }
    
        var requestedURLs: [URL] {
            messages.map(\.url)
        }
        
        private(set) var cancelledURLs = [URL]()
        private var messages: [(url: URL, completion:  (HTTPClient.Result) -> Void)] = []
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            messages.append((url, completion))
            
            return Task { [weak self] in
                self?.cancelledURLs.append(url)
            }
        }
        
        func didFinishLoadImageWithFailure(_ error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func didFinishLoadImageWithStatusCode(_ code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success((response, data)))
        }
    }
}
