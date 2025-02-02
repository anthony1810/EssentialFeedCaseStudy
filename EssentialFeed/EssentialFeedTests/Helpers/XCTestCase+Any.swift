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
-> (model: FeedImage, json: [String: Any]) {
    let feedImage = FeedImage(
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
    
    return (feedImage, itemJson0)
}

func uniqueFeed() -> (model: FeedImage, local: LocalFeedImage) {
    
    let model = FeedImage(id: UUID(), description: "any description", location: "any location", imageURL: anyURL())
    
    let local = LocalFeedImage(id: model.id, description: model.description, location: model.location, imageURL: model.url)
    
    return (model, local)
}

extension Date {
    func adding(days: Int) -> Date {
        NSCalendar(identifier: .gregorian)!.date(byAdding: .day, value: days, to: self)!
    }

    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
