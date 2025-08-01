//
//  FeedLoaderTests.swift
//  EssentialFeed
//
//  Created by Anthony on 23/1/25.
//

import XCTest
import EssentialFeed

class FeedImageMapperTests: XCTestCase {
    func test_map_deliversErrorOnNon200HTTPResponse() throws {
        let url = anyURL()
        
        let samples = [199, 201, 300, 400, 500]
        try samples.forEach { statusCode in
            let response = HTTPURLResponse(url: url, statusCode: statusCode)
            XCTAssertThrowsError(
                try FeedMapper.map(anydata(), res: response)
            )
        }
    }
    
    func test_map_deliversErrorOn200HTTPResponseWithInvalidJson() throws {
        let url = anyURL()
        
        XCTAssertThrowsError(
            try FeedMapper.map(anyInvalidJson(), res: HTTPURLResponse(url: url, statusCode: 200))
        )
    }
    
    func test_map_deliversNoItemsOn200HTTPResponseWithEmptyJson() throws {
        let url = anyURL()
        
        let mappedItems = try FeedMapper.map(makeItemsJson([]), res: HTTPURLResponse(url: url, statusCode: 200))
        XCTAssertEqual(mappedItems, [])
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithValidJson() throws {
        let url = anyURL()
        
        let (feedImage0, itemJson0) = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: anyURL()
        )
        
        let (feedImage1, itemJson1) = makeItem(
            id: UUID(),
            description: nil,
            location:  nil,
            imageURL: anyURL()
        )
        
        let mappedItems = try FeedMapper.map(makeItemsJson([itemJson0, itemJson1]), res: HTTPURLResponse(url: url, statusCode: 200))
        XCTAssertEqual(mappedItems, [feedImage0, feedImage1])
    }
    
    func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        .failure(error)
    }
}

