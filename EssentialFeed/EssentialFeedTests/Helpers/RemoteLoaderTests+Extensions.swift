//
//  RemoteLoaderTests+Extensions.swift
//  EssentialFeed
//
//  Created by Anthony on 6/10/24.
//
import Foundation
import XCTest
@testable import EssentialFeed

extension FeedItemMapperTests {
    func makeSUT(
        url: URL = URL(string: "https://a-url.com")!,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (HTTPClientSpy, EssentialFeed.RemoteFeedLoader) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(httpClient: client, url: url)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (client, sut)
    }
    
    func expect(
        sut: RemoteFeedLoader,
        toCompleteWith expectedResult: FeedLoaderProtocol.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        let exp = expectation(description: "wait for load completion")
        sut.load(completion: { actualResult in
            switch (actualResult, expectedResult) {
            case (.success(let actualItems), .success(let expectedItems)):
                XCTAssertEqual(actualItems, expectedItems)
            case (.failure(let actualError), .failure(let expectedError)):
                guard let remoteFeedActualError = actualError as? RemoteFeedLoader.Error,
                      let remoteFeedExpectedError = expectedError as? RemoteFeedLoader.Error else  {
                    XCTFail("Expected \(expectedError) but got \(actualError) instead", file: file, line: line)
                    return
                }
                
                XCTAssertEqual(remoteFeedActualError, remoteFeedExpectedError)
            default:  XCTFail("Expected \(expectedResult) but got \(actualResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        })
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func makeItems(
        id: UUID = UUID(),
        description: String? = nil,
        location: String? = nil,
        imageURL: URL
    ) -> (model: FeedImage, json: [String: Any]) {
        let model = FeedImage(id: id, description: description, location: location, imageURL: imageURL)
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues({ $0 })
        
        return (model, json)
    }
    
    func makeData(
        from items: [[String: Any]]
    ) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    func failure(_ error: RemoteFeedLoader.Error) -> FeedLoaderProtocol.Result {
        .failure(error)
    }
}

