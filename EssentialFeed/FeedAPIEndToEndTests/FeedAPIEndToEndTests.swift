//
//  FeedAPIEndToEndTests.swift
//  FeedAPIEndToEndTests
//
//  Created by Anthony on 10/10/24.
//

import XCTest
import EssentialFeed

final class FeedAPIEndToEndTests: XCTestCase {
    
    func test_endToEndFeedResult_matchesFixedTestSampleData() throws {
        let loader = RemoteLoader(httpClient: empheralURLSessionHTTPClient(), url: feedTestServerURL, mapper: FeedItemsMapper.map)
        
        trackForMemoryLeaks(loader)
        
        var capturedResult: FeedLoaderProtocol.Result?
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
    
    func test_endtoEndTestServerGETFeedImageResult_matchesFixedTestSampleData() throws {
        let testServerURL =  feedTestServerURL.appendingPathComponent("/73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6/image")
        
        switch getFeedImageResult(from: testServerURL) {
        case .success(let imageData)?:
            XCTAssertEqual(imageData?.isEmpty, false, "Expected received image data to be non-empty")
        case .failure(let error):
            XCTFail("Expected image loader to succeed, but received error: \(error) instead")
        default:
            XCTFail("Expected image loader to succeed, but received unexpected result instead")
        }
    }
}

extension FeedAPIEndToEndTests {
    func expectItem(at index: Int) -> FeedImage {
        FeedImage(
            id: id(at: index),
            description: description(at: index),
            location: location(at: index),
            imageURL: imageURL(at: index)
        )
    }
    
    func getFeedImageResult(from url: URL) -> FeedImageDataLoaderProtocol.Result? {
        let loader = RemoteFeedImageDataLoader(client: empheralURLSessionHTTPClient())
        
        trackForMemoryLeaks(loader)
        
        let expectation = expectation(description: "Waiting for image loader")
        var result: RemoteFeedImageDataLoader.Result?
        _ = loader.loadImageData(
            from: url,
            completion: {
                result = $0
                expectation.fulfill()
            }
        )
        wait(for: [expectation], timeout: 5.0)
        
        return result
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
    
    private var feedTestServerURL: URL {
        return URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
    }
    
    private func empheralURLSessionHTTPClient(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        trackForMemoryLeaks(client, file: file, line: line)
        
        return client
    }
}
