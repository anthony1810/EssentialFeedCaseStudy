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
        
        expect(sut: sut, toCompleteWith: .failure(.connectivity)) {
            client.complete(with: NSError(domain: "test error", code: 0))
        }
    }
    
    func test_load_deliversErrorOnHTTPError() {
        let (client, sut) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
       
        samples.enumerated().forEach { index, statusCode in
            expect(sut: sut, toCompleteWith: .failure(.invalidData)) {
                client.complete(with: statusCode, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJson() {
        let (client, sut) = makeSUT()
        
        expect(sut: sut, toCompleteWith: .failure(.invalidData)) {
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
}

// MARK: - Helpers
extension RemoteLoaderTests {
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (HTTPClientSpy, EssentialFeed.RemoteFeedLoader) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(httpClient: client, url: url)
        
        return (client, sut)
    }
    
    func expect(
        sut: RemoteFeedLoader,
        toCompleteWith result: RemoteFeedLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        var capturedResults = [RemoteFeedLoader.Result]()
        
        sut.load(completion: {
            capturedResults.append($0)
        })
        
        action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
    
    func makeItems(
        id: UUID = UUID(),
        description: String? = nil,
        location: String? = nil,
        imageURL: URL
    ) -> (model: FeedItem, json: [String: Any]) {
        let model = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues({ $0 })
        
        return (model, json)
    }
    
    func makeData(
        from items: [[String: Any]]
    ) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
}


class HTTPClientSpy: HTTPClient {
    
    var requestedURLs: [URL] {
        messages.map(\.url)
    }
    
    var messages : [(url: URL, completion: (HTTPClientResult) -> Void)]
    
    init() {
        self.messages = []
    }
    
    func get(url: URL, completion: @escaping (EssentialFeed.HTTPClientResult) -> Void) {
        messages.append((url, completion))
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(with statusCode: Int, data: Data = Data(), at index: Int = 0) {
        let response = HTTPURLResponse(
            url: messages[index].url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        messages[index].completion(.success(response, data))
    }
}
