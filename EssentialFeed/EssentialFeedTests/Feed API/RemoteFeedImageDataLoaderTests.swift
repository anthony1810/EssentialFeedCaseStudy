//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeed
//
//  Created by Anthony on 9/11/24.
//

import XCTest
import EssentialFeed

final class RemoteFeedImageDataLoader {

    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageLoaderProtocol.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success: break
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}

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
        
        expect(sut: sut, toCompleteWith: .failure(expectedError)) {
            client.didFinishLoadImageWithFailure(expectedError)
        }
    }
}

// MARK: - Helpers
extension RemoteFeedImageDataLoaderTests {
    
    func makeSUT() -> (sut: RemoteFeedImageDataLoader, client: ClientSpy) {
        let client = ClientSpy()
        let loader = RemoteFeedImageDataLoader(client: client)
        
        return (loader, client)
    }
    
    func expect(
        sut: RemoteFeedImageDataLoader,
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
    
        var requestedURLs: [URL] {
            messages.map(\.url)
        }
        
        private var messages: [(url: URL, completion:  (HTTPClient.Result) -> Void)] = []
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }
        
        func didFinishLoadImageWithFailure(_ error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
    }
}
