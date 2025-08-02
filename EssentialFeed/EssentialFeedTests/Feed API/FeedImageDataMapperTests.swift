//
//  RemoteFeedImageDataLoaderTests.swift
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
    
    // MARK: - Helpers
    private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (RemoteFeedImageDataLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        
        trackMemoryLeaks(client, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return (sut, client)
    }
    
    func expect(
        _ sut: RemoteFeedImageDataLoader,
        toCompleteWith expectedResult: FeedImageDataLoader.Result?,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line) {
            let exp = expectation(description: "Wait for completion")
            _ = sut.loadImageData(from: anyURL()) { receivedResult in
                switch (expectedResult, receivedResult) {
                case let (.success(expectedData), .success(receivedData)):
                    XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                case let (.failure(expectedError as NSError), .failure(receivedError as NSError)):
                    XCTAssertEqual(expectedError, receivedError, file: file, line: line)
                default:
                    XCTFail(
                        "Expected result to be \(String(describing: expectedResult)), but got \(receivedResult) instead",
                        file: file,
                        line: line
                    )
                }
                exp.fulfill()
            }
            
            action()
            wait(for: [exp], timeout: 1.0)
    }  
}
