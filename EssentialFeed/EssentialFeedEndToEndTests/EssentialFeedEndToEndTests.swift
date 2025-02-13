//
//  EssentialFeedEndToEndTests.swift
//  EssentialFeedEndToEndTests
//
//  Created by Anthony on 26/1/25.
//

import XCTest
import EssentialFeed

final class EssentialFeedEndToEndTests: XCTestCase {
    
    func test_getFeedResult_matchesFixedTestAccountData() {
        guard let receivedResult = getFeedResult() else {
            XCTFail("Expect success, got nil")
            return
        }
        
        switch receivedResult {
        case .success(let items):
            XCTAssertEqual(items[0], expectedItemAt(0))
            XCTAssertEqual(items[1], expectedItemAt(1))
            XCTAssertEqual(items[2], expectedItemAt(2))
            XCTAssertEqual(items[3], expectedItemAt(3))
            XCTAssertEqual(items[4], expectedItemAt(4))
            XCTAssertEqual(items[5], expectedItemAt(5))
            XCTAssertEqual(items[6], expectedItemAt(6))
            XCTAssertEqual(items[7], expectedItemAt(7))
        case .failure(let error):
            XCTFail("Expect success, got \(error)")
        }
    }
    
    private func getFeedResult(file: StaticString = #filePath, line: UInt = #line) -> FeedLoader.Result? {
        let testServerURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteFeedLoader(url: testServerURL, client: client)
        
        trackMemoryLeaks(client, file: file, line: line)
        trackMemoryLeaks(loader,  file: file, line: line)
        
        let exp = expectation(description: "wait for feed loading")
        
        var receivedResult: FeedLoader.Result?
        loader.load { receivedResult = $0; exp.fulfill() }
        
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }
}

func expectedItemAt(_ index: Int) -> FeedImage {
    FeedImage(
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

