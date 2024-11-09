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
    
    func loadImageData(from url: URL, completion: @escaping (Any) -> Void) {
        client.get(from: url) { _ in }
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
}

// MARK: - Helpers
extension RemoteFeedImageDataLoaderTests {
    
    func makeSUT() -> (sut: RemoteFeedImageDataLoader, client: ClientSpy) {
        let client = ClientSpy()
        let loader = RemoteFeedImageDataLoader(client: client)
        
        return (loader, client)
    }
    
    final class ClientSpy: HTTPClient {
    
        var requestedURLs: [URL] = []
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            requestedURLs.append(url)
        }
    }
}
