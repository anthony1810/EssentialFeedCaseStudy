//
//  RemoteLoaderTests+Extensions.swift
//  EssentialFeed
//
//  Created by Anthony on 6/10/24.
//
import Foundation
import XCTest
@testable import EssentialFeed

extension RemoteLoaderTests {
    func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (HTTPClientSpy, EssentialFeed.RemoteFeedLoader) {
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

