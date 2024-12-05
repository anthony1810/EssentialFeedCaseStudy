//
//  LoadFeedCommentsFromRemoteUsecases.swift
//  EssentialFeed
//
//  Created by Anthony on 2/12/24.
//

import XCTest
@testable import EssentialFeed

class FeedCommentItemsMapperTests: XCTestCase {
    
    func test_load_deliversErrorOnHTTPError() throws {
        let emptyData = makeData(from: [])
        
        let samples = [199, 150, 300, 400, 500]
       
        try samples.forEach { statusCode in
            XCTAssertThrowsError(
                try FeedCommentItemsMapper.map(makeAnyHTTPURLResponse(statusCode: statusCode), data: emptyData)
            )
        }
    }
    
    func test_load_deliversErrorOn2xxHTTPResponseWithInvalidJson() throws {
        let invalidJson = Data("invalidJson".utf8)
        
        let samples = [199, 150, 300, 400, 500]
        try samples.forEach { statusCode in
            XCTAssertThrowsError(
                try FeedCommentItemsMapper.map(makeAnyHTTPURLResponse(statusCode: statusCode), data: invalidJson)
            )
        }
    }
    
    func test_load_deliversEmptyArrayOn2xxHTTPResponseWithEmptyValidJson() throws {
        let emptyJsonItem = Data("{\"items\": []}".utf8)
        
        let samples = [200, 201, 250, 280, 299]
        try samples.forEach { statusCode in
            _ = try FeedCommentItemsMapper.map(makeAnyHTTPURLResponse(statusCode: statusCode), data: emptyJsonItem)
        }
    }
    
    func test_load_deliversItemsArrayOn2xxHTTPResponseWithValidJson() throws {
        
        let item1 = makeItems(message: "a message", createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"), username: "a username")
        
        let item2 = makeItems(message: "another message", createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"), username: "another username")
        
        let items = [item1, item2]
        
        let models = items.map(\.model)
        let jsons = items.map(\.json)
        
        let samples = [200, 201, 250, 280, 299]
        try samples.forEach { statusCode in
            let result = try FeedCommentItemsMapper.map(makeAnyHTTPURLResponse(statusCode: statusCode), data: makeItemsJSON(jsons))
            XCTAssertEqual(result, models)
        }
    }
}

extension FeedCommentItemsMapperTests {
    func makeItems(
        id: UUID = UUID(),
        message: String,
        createdAt: (date: Date, iso: String),
        username: String
    ) -> (model: ImageComment, json: [String: Any]) {
        
        let model = ImageComment(
            id: id,
            message: message,
            createdAt: createdAt.date,
            author: username
        
        )
        let json: [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.iso,
            "author": [
                "username": username
            ]
        ]
        
        return (model, json)
    }
    
    func makeData(
        from items: [[String: Any]]
    ) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
}

