//
//  ImageCommentMapperTests.swift
//  EssentialFeed
//
//  Created by Anthony on 28/7/25.
//

import XCTest
import EssentialFeed

class ImageCommentMapperTests: XCTestCase {

    func test_map_deliversErrorOnNon2xxHTTPResponse() throws {
        let samples = [199, 150, 300, 400, 500]
        try samples.forEach { statusCode in
            XCTAssertThrowsError(
                try ImageCommentMapper.map(anydata(), res: HTTPURLResponse(url: anyURL(), statusCode: statusCode))
            )
        }
    }
    
    func test_map_deliversErrorOn2xxHTTPResponseWithInvalidJSON() throws {
        let invalidJSON = Data("invalid json".utf8)
        let samples = [200, 201, 250, 280, 299]
        
        try samples.forEach { statusCode in
            XCTAssertThrowsError(
                try ImageCommentMapper.map(invalidJSON, res: HTTPURLResponse(url: anyURL(), statusCode: statusCode))
            )
        }
    }
    
    func test_map_deliversNoItemsOn2xxHTTPResponseWithEmptyJSONList() throws {let emptyListJSON = makeItemsJson([])
        let samples = [200, 201, 250, 280, 299]
        
        try samples.forEach { statusCode in
            let mappedData = try ImageCommentMapper.map(emptyListJSON, res: HTTPURLResponse(url: anyURL(), statusCode: statusCode))
            XCTAssertEqual(mappedData, [])
        }
    }
    
    func test_map_deliversItemsOn2xxHTTPResponseWithJSONItems() throws {
        let item1 = makeItem(
            id: UUID(),
            message: "a message",
            createdAt:(Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
            username: "a username"
            )
        
        let item2 = makeItem(
            id: UUID(),
            message: "another message",
            createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
            username: "another username")
        
        let items = [item1.model, item2.model]
        let json = makeItemsJson([item1.json, item2.json])
        let samples = [200, 201, 250, 280, 299]
        
        try samples.forEach { statusCode in
            let mappedData = try ImageCommentMapper.map(json, res: HTTPURLResponse(url: anyURL(), statusCode: statusCode))
            XCTAssertEqual(mappedData, items)
        }
    }
    
    // MARK: - Helpers
    private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (model: ImageComment, json: [String: Any]) {
        let item = ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)
        
        let json = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.iso8601String,
            "author": [
                "username": username
            ]
        ].compactMapValues { $0 }
        
        return (item, json)
    }
}
