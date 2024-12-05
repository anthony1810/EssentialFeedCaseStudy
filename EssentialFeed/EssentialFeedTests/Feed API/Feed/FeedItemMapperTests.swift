//
//  RemoteLoaderTests.swift
//  EssentialFeed
//
//  Created by Anthony on 5/10/24.
//

import XCTest
@testable import EssentialFeed

class FeedItemMapperTests: XCTestCase {
    
    func test_map_deliversErrorOnHTTPError() throws {

        let emptyData = makeData(from: [])
        let samples = [199, 201, 300, 400, 500]
       
        try samples.forEach { statusCode in
            XCTAssertThrowsError(
                try FeedItemsMapper.map(makeAnyHTTPURLResponse(statusCode: statusCode), data: emptyData)
            )
        }
    }
    
    func test_map_deliversErrorOn200HTTPResponseWithInvalidJson() throws {
        let invalidJson = Data("invalidJson".utf8)
        
        XCTAssertThrowsError(
            try FeedItemsMapper.map(makeAnyHTTPURLResponse(statusCode: 200), data: invalidJson)
        )
    }
    
    func test_map_deliversEmptyArrayOn200HTTPResponseWithEmptyValidJson() throws {
        let emptyJsonItem = Data("{\"items\": []}".utf8)
        
        _ = try FeedItemsMapper.map(makeAnyHTTPURLResponse(statusCode: 200), data: emptyJsonItem)
    }
    
    func test_load_deliversItemsArrayOn200HTTPResponseWithValidJson() throws {
        let item1 = makeItems(
            imageURL: URL(string: "https://aurl.com")!)
        
        let item2 = makeItems(
            description: "this is a description",
            location: "this is a location",
            imageURL: URL(string: "https://aurl.com")!)
        
        let items = [item1, item2]
        
        let models = items.map(\.model)
        let jsons = items.map(\.json)
        
        
        let result = try FeedItemsMapper.map(makeAnyHTTPURLResponse(statusCode: 200), data: makeItemsJSON(jsons))
        
        XCTAssertEqual(result, models)
    }
}
