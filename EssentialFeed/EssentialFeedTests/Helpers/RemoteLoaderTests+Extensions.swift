//
//  RemoteLoaderTests+Extensions.swift
//  EssentialFeed
//
//  Created by Anthony on 6/10/24.
//
import Foundation
import XCTest
@testable import EssentialFeed

extension FeedItemMapperTests {
    func makeItems(
        id: UUID = UUID(),
        description: String? = nil,
        location: String? = nil,
        imageURL: URL
    ) -> (model: FeedImage, json: [String: Any]) {
        let model = FeedImage(id: id, description: description, location: location, imageURL: imageURL)
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

