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
        XCTAssertEqual(client.requestedURL, nil)
    }
    
    func test_load_requestDataFromURL() {
        let targetURL = URL(string: "https:/a-url.com")!
        let (client, sut) = makeSUT(url: targetURL)
        
        sut.load(completion: {_ in })
        
        XCTAssertEqual(client.requestedURL, targetURL)
    }
    
    private func makeSUT(url: URL = URL(string: "https:/a-url.com")!) -> (HTTPClient, FeedLoader) {
        let client = HTTPClientSpy(requestedURL: nil)
        let sut = RemoteFeedLoader(httpClient: client, url: url)
        
        return (client, sut)
    }
}


class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    
    init(requestedURL: URL? = nil) {
        self.requestedURL = requestedURL
    }
    
    func get(url: URL) {
        requestedURL = url
    }
}
