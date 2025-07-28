//
//  LoadImageCommentFromRemoteUseCase.swift
//  EssentialFeed
//
//  Created by Anthony on 28/7/25.
//

import XCTest
import EssentialFeed

class LoadImageCommentFromRemoteUseCase: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT(url: anyURL())
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_load_requestsDataFromURL() {
        let requestURL = anyURL()
        let (sut, client) = makeSUT(url: requestURL)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [requestURL])
    }
    
    func test_loadTwice_requestsDataTwiceFromURL() {
        let requestURL = anyURL()
        let (sut, client) = makeSUT(url: requestURL)
        
        sut.load() {_ in }
        sut.load() {_ in }
        
        XCTAssertEqual(client.requestedURLs, [requestURL, requestURL])
    }
    
    func test_load_deliversErrorOnConnectionError() {
        let (sut, client) = makeSUT(url: anyURL())
        
        expect(sut, toFinishedWith: failure(.connectivity)) {
            client.complete(withError: anyNSError())
        }
    }
    
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
    
    func test_load_doesNotDeliverResultAfterSUTInstanceIsDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: anyURL(), client: client)
        
        var receivedResult: RemoteFeedLoader.Result?
        sut?.load { result in
            receivedResult = result
        }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJson([]))
        
        XCTAssertNil(receivedResult, "Does not deliver result after instance is deallocated")
    }

    // MARK: - Helpers
    private func makeSUT(url: URL,file: StaticString = #file, line: UInt = #line) -> (sut: RemoteImageCommentLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let loader = RemoteImageCommentLoader(url: url, client: client)
        
        trackMemoryLeaks(client, file: file, line: line)
        trackMemoryLeaks(loader, file: file, line: line)
        
        return (loader, client)
    }
    
    private func expect(
        _ sut: RemoteImageCommentLoader,
        toFinishedWith expectedResult: RemoteImageCommentLoader.Result,
        when action: @escaping () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for load completion")
        
        sut.load { capturedResult in
            switch (capturedResult, expectedResult) {
            case let (.success(capturedItems), .success(expectedItems)):
                XCTAssertEqual(capturedItems, expectedItems, file: file, line: line)
            case let (.failure(capturedError as RemoteImageCommentLoader.Error), .failure(expectedError as RemoteImageCommentLoader.Error)):
                XCTAssertEqual(capturedError, expectedError, file: file, line: line)
            default:
                XCTFail("expected \(expectedResult) got \(capturedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func failure(_ error: RemoteImageCommentLoader.Error) -> RemoteImageCommentLoader.Result {
        .failure(error)
    }
}

