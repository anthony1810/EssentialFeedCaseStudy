//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeed
//
//  Created by Anthony on 9/11/24.
//

import XCTest
import EssentialFeed

class FeedImageDataMapperTests: XCTestCase {
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOnNon200Response() throws {
       
        let samples = [199, 201, 300, 400, 500]
        try samples.forEach { statusCode in
            XCTAssertThrowsError(
                try FeedImageDataMapper.map(from: makeAnyHTTPURLResponse(statusCode: statusCode), data: makeAnyData())
            )
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidImageDataOn200ResponseWithEmptyData() {
        XCTAssertThrowsError(
            try FeedImageDataMapper.map(from: makeAnyHTTPURLResponse(), data: Data())
        )
    }
    
    func test_loadImageDataFromURL_deliversImageDataOn200ResponseWithValidData() throws {
        let expectedImageData = makeAnyData()
        _ = try FeedImageDataMapper.map(from: makeAnyHTTPURLResponse(), data: expectedImageData)
    }
}
