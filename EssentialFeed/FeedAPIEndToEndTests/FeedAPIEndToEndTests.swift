//
//  FeedAPIEndToEndTests.swift
//  FeedAPIEndToEndTests
//
//  Created by Anthony on 10/10/24.
//

import XCTest
import EssentialFeed

final class FeedAPIEndToEndTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_endToEndFeedResult_matchesFixedTestSampleData() throws {
        let url = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let httpclient = URLSessionHTTPClient()
        let loader = RemoteFeedLoader(httpClient: httpclient, url: url)
        
        var capturedResult: LoadFeedResult?
        let expectation = self.expectation(description: "Loaded")
        loader.load { result in
            capturedResult = result
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
            switch capturedResult {
            case let .success(feeds):
                XCTAssertEqual(feeds.count, 8)
                XCTAssertEqual(feeds[0], self.expectItem(at: 0))
                XCTAssertEqual(feeds[1], self.expectItem(at: 1))
                XCTAssertEqual(feeds[2], self.expectItem(at: 2))
                XCTAssertEqual(feeds[3], self.expectItem(at: 3))
                XCTAssertEqual(feeds[4], self.expectItem(at: 4))
                XCTAssertEqual(feeds[5], self.expectItem(at: 5))
                XCTAssertEqual(feeds[6], self.expectItem(at: 6))
                XCTAssertEqual(feeds[7], self.expectItem(at: 7))
            case let .failure(error):
                XCTFail("Expect success, got \(error)")
            case .none:
                XCTFail("Expect success, got none results")
            }
        }
    }
    
    func expectItem(at index: Int) -> FeedItem {
        FeedItem(
            id: id(at: index),
            description: description(at: index),
            location: location(at: index),
            imageURL: imageURL(at: index)
        )
    }
    
    private func id(at index: Int) -> UUID {
        return UUID(uuidString: [
            "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
            "BA298A85-6275-48D3-8315-9C8F7C1CD109",
            "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
            "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
            "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
            "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
            "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
            "F79BD7F8-063F-46E2-8147-A67635C3BB01"
        ][index])!
    }
    
    
    private func description(at index: Int) -> String? {
        return [
            "Description 1",
            nil,
            "Description 3",
            nil,
            "Description 5",
            "Description 6",
            "Description 7",
            "Description 8"
        ][index]
    }
    
    private func location(at index: Int) -> String? {
        return [
            "Location 1",
            "Location 2",
            nil,
            nil,
            "Location 5",
            "Location 6",
            "Location 7",
            "Location 8"
        ][index]
    }
    
    private func imageURL(at index: Int) -> URL {
        return URL(string: "https://url-\(index+1).com")!
    }
}
