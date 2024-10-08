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
        let targetURL = URL(string: "https://a-url.com")!
        let (client, sut) = makeSUT(url: targetURL)
        
        sut.load(completion: {_ in })
        sut.load(completion: {_ in })
        
        XCTAssertEqual(client.requestedURLs, [targetURL, targetURL])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (client, sut) = makeSUT()
        
        expect(sut: sut, toCompleteWith: failure(.connectivity)) {
            client.complete(with: NSError(domain: "test error", code: 0))
        }
    }
    
    func test_load_deliversErrorOnHTTPError() {
        let (client, sut) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
       
        samples.enumerated().forEach { index, statusCode in
            expect(sut: sut, toCompleteWith: failure(.invalidData)) {
                let emptyData = makeData(from: [])
                client.complete(with: statusCode, data: emptyData, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJson() {
        let (client, sut) = makeSUT()
        
        expect(sut: sut, toCompleteWith: failure(.invalidData)) {
            let invalidJson = Data("invalidJson".utf8)
            client.complete(with: 200, data: invalidJson)
        }
    }
    
    func test_load_deliversEmptyArrayOn200HTTPResponseWithEmptyValidJson() {
        let (client, sut) = makeSUT()
        
        expect(sut: sut, toCompleteWith: .success([])) {
            let emptyJsonItem = Data("{\"items\": []}".utf8)
            client.complete(with: 200, data: emptyJsonItem)
        }
    }
    
    func test_load_deliversItemsArrayOn200HTTPResponseWithValidJson() {
        let (client, sut) = makeSUT()
        
        let item1 = makeItems(
            imageURL: URL(string: "https://aurl.com")!)
        
        let item2 = makeItems(
            description: "this is a description",
            location: "this is a location",
            imageURL: URL(string: "https://aurl.com")!)
        
        let items = [item1, item2]
        
        let models = items.map(\.model)
        let jsons = items.map(\.json)
        
        expect(sut: sut, toCompleteWith: .success(models)) {
            client.complete(with: 200, data: makeData(from: jsons))
        }
    }
    
    func test_load_StopDeliverItemsWhenRemoteFeedLoaderInstanceDeallocated() {
        
        let url = URL(string: "https://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(httpClient: client, url: url)
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load(completion: {
            capturedResults.append($0)
        })
        
        sut = nil
        XCTAssertTrue(sut == nil, "Feed Loader has already been deallocated")
        
        client.complete(with: 200, data: makeData(from: []))
        
        XCTAssertTrue(capturedResults.isEmpty, "NO result should be return if Feed Loader has already been deallocated")
    }
}
