//
//  FeedImageDataMapperTests.swift
//  EssentialFeed
//
//  Created by Anthony on 5/4/25.
//

import XCTest
import EssentialFeed

class FeedImageDataMapperTests: XCTestCase {
    func test_map_throwsErrorOnHTTPStatusCodeOtherThan200() throws {
        let samples = [199, 201, 300, 400, 500]
        
        try samples.forEach { statusCode in
            XCTAssertThrowsError(
                try FeedImageDataMapper.map(
                    anydata(),
                    from: HTTPURLResponse(url: anyURL(), statusCode: statusCode)
                )
            )
        }
    }
    
    func test_map_deliversInvalidDataOn200HTTPResponseWithEmptyData() throws {
        let emptyData = Data()
        
        XCTAssertThrowsError(
            try FeedImageDataMapper.map(
                emptyData,
                from: HTTPURLResponse(url: anyURL(), statusCode: 200)
            )
        )
    }
    
    func test_map_deliversReceivedDataOn200HTTPResponseWithNonEmptyData() throws {
        let sampleData = anydata()
        
        let mappedData = try FeedImageDataMapper.map(
            sampleData,
            from: HTTPURLResponse(url: anyURL(), statusCode: 200)
        )
        
        XCTAssertEqual(mappedData, sampleData)
    }
}
