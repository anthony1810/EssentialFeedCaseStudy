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
        let url = makeAnyUrl()
        let expectedError = makeAnyError()
        
        var result: FeedImageLoaderProtocol.Result?
        let exp = expectation(description: "Waiting for load image data completion")
       
        sut.loadImageData(from: url) { receivedResult in
            result = receivedResult
            exp.fulfill()
        }
        client.didFinishLoadImageWithFailure(expectedError)
        
        wait(for: [exp], timeout: 1.0)
        
        if case .failure(let error) = result {
            XCTAssertEqual((error as NSError?)?.code, expectedError.code)
        } else {
            XCTFail("expected .failure, got .success")
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
    
    final class ClientSpy: HTTPClient {
    
        var requestedURLs: [URL] {
            messages.map(\.url)
        }
        var messages: [(url: URL, completion:  (HTTPClient.Result) -> Void)] = []
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }
        
        func didFinishLoadImageWithFailure(_ error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
    }
}
