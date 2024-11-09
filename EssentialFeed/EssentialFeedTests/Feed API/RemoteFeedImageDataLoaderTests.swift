//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeed
//
//  Created by Anthony on 9/11/24.
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoader {

    let client: Any
    
    init(client: Any) {
        self.client = client
    }

}

class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotPerformAnyURLReuqest() {
        
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestedURLs.count, 0)
    }
    
}

// MARK: - Helpers
extension RemoteFeedImageDataLoaderTests {
    
    private func makeSUT() -> (sut: RemoteFeedImageDataLoader, client: ClientSpy) {
        let client = ClientSpy()
        let loader = RemoteFeedImageDataLoader(client: client)
        
        return (loader, client)
    }
    
    private final class ClientSpy {
        var requestedURLs: [URL] = []
        
    }
}
