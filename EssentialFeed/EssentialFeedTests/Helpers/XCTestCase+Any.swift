//
//  XCTestCase+Any.swift
//  EssentialFeed
//
//  Created by Anthony on 28/1/25.
//
import Foundation
import EssentialFeed

func anyURL() -> URL {
    URL(string: "https://example.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "Test", code: 0, userInfo: nil)
}

func anyInvalidJson() -> Data {
    Data("any json".utf8)
}

func anydata() -> Data {
    Data("any data".utf8)
}

func makeItemsJson(_ items: [[String: Any]]) -> Data {
    let json = [
        "items": items
    ].compactMapValues { $0 }
    
    return try! JSONSerialization.data(withJSONObject: json)
}

func anyNonHTTPURLResponse() -> URLResponse {
    URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
}

func anyHTTPURLResponse() -> HTTPURLResponse {
    HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
}

func makeItem(
    id: UUID,
    description: String?,
    location: String?,
    imageURL: URL)
-> (model: FeedItem, json: [String: Any]) {
    let feedItem = FeedItem(
        id: id,
        description: description,
        location: location,
        imageURL: imageURL
    )
    
    let itemJson0: [String: Any] = [
        "id": id.uuidString,
        "description": description,
        "location": location,
        "image": imageURL.absoluteString
    ].compactMapValues { $0 }
    
    return (feedItem, itemJson0)
}

func uniqueFeed() -> (model: FeedItem, local: LocalFeedItem) {
    
    let model = FeedItem(id: UUID(), description: "any description", location: "any location", imageURL: anyURL())
    
    let local = LocalFeedItem(id: model.id, description: model.description, location: model.location, imageURL: model.imageURL)
    
    return (model, local)
}
