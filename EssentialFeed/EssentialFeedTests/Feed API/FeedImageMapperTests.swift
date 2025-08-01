//
//  FeedLoaderTests.swift
//  EssentialFeed
//
//  Created by Anthony on 23/1/25.
//

import XCTest
import EssentialFeed

class FeedImageMapperTests: XCTestCase {
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, statusCode in
            expect(sut, toFinishedWith: failure(.invalidData)) {
                client.complete(withStatusCode: statusCode, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJson() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        expect(sut, toFinishedWith: failure(.invalidData)) {
            client.complete(withStatusCode: 200, data: anyInvalidJson())
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJson() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        expect(sut, toFinishedWith: .success([])) {
            client.complete(withStatusCode: 200, data: makeItemsJson([]))
        }
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithValidJson() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
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
        
        expect(sut, toFinishedWith: .success([feedImage0, feedImage1])) {
            client.complete(withStatusCode: 200, data: makeItemsJson([itemJson0, itemJson1]))
        }
    }

    // MARK: - Helpers
    private func makeSUT(url: URL,file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let loader = RemoteFeedLoader(url: url, client: client)
        
        trackMemoryLeaks(client, file: file, line: line)
        trackMemoryLeaks(loader, file: file, line: line)
        
        return (loader, client)
    }
    
    private func expect(
        _ sut: RemoteFeedLoader,
        toFinishedWith expectedResult: RemoteFeedLoader.Result,
        when action: @escaping () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for load completion")
        
        sut.load { capturedResult in
            switch (capturedResult, expectedResult) {
            case let (.success(capturedItems), .success(expectedItems)):
                XCTAssertEqual(capturedItems, expectedItems, file: file, line: line)
            case let (.failure(capturedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(capturedError, expectedError, file: file, line: line)
            default:
                XCTFail("expected \(expectedResult) got \(capturedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        .failure(error)
    }
}

