//
//  LoadFeedCommentsFromRemoteUsecases.swift
//  EssentialFeed
//
//  Created by Anthony on 2/12/24.
//

import XCTest
@testable import EssentialFeed

class LoadFeedCommentsFromRemoteUseCase: XCTestCase {
    
    func test_init_doesNotRequestDataFrçomURL() {
        
        // Given (Arrange)
        let (client, _) = makeSUT()
        
        // Then
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        let targetURL = URL(string: "https:/a-url.com")!
        let (client, sut) = makeSUT(url: targetURL)
        
        sut.load(completion: {_ in })
        
        XCTAssertEqual(client.requestedURLs, [targetURL])
    }
     
    func test_loadTwice_requestsDataFromURLTwice() {
        let targetURL = URL(string: "https://a-url.com")!
        let (client, sut) = makeSUT(url: targetURL)
        
        sut.load(completion: {_ in })
        sut.load(completion: {_ in })
        
        XCTAssertEqual(client.requestedURLs, [targetURL, targetURL])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (client, sut) = makeSUT()
        
        expect(sut: sut, toCompleteWith: failure(.connectivity)) {
            client.complete(with: NSError(domain: "test error", code: 0))
        }
    }
    
    func test_load_deliversErrorOnHTTPError() {
        let (client, sut) = makeSUT()
        
        let samples = [199, 150, 300, 400, 500]
       
        samples.enumerated().forEach { index, statusCode in
            expect(sut: sut, toCompleteWith: failure(.invalidData)) {
                let emptyData = makeData(from: [])
                client.complete(with: statusCode, data: emptyData, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn2xxHTTPResponseWithInvalidJson() {
        let (client, sut) = makeSUT()
        
        let samples = [199, 150, 300, 400, 500]
        samples.enumerated().forEach { index, statusCode in
            expect(sut: sut, toCompleteWith: failure(.invalidData)) {
                let invalidJson = Data("invalidJson".utf8)
                client.complete(with: statusCode, data: invalidJson, at: index)
            }
        }
    }
    
    func test_load_deliversEmptyArrayOn2xxHTTPResponseWithEmptyValidJson() {
        let (client, sut) = makeSUT()
        
        let samples = [200, 201, 250, 280, 299]
        samples.enumerated().forEach { index, statusCode in
            expect(sut: sut, toCompleteWith: .success([])) {
                let emptyJsonItem = Data("{\"items\": []}".utf8)
                client.complete(with: 200, data: emptyJsonItem, at: index)
            }
        }
    }
    
    func test_load_deliversItemsArrayOn2xxHTTPResponseWithValidJson() {
        let (client, sut) = makeSUT()
        
        let item1 = makeItems(message: "a message", createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"), username: "a username")
        
        let item2 = makeItems(message: "another message", createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"), username: "another username")
        
        let items = [item1, item2]
        
        let models = items.map(\.model)
        let jsons = items.map(\.json)
        
        let samples = [200, 201, 250, 280, 299]
        samples.enumerated().forEach { index, statusCode in
            expect(sut: sut, toCompleteWith: .success(models)) {
                client.complete(with: statusCode, data: makeData(from: jsons), at: index)
            }
        }
    }
    
    func test_load_StopDeliverItemsWhenRemoteImageCommentsLoaderInstanceDeallocated() {
        
        let url = URL(string: "https://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteImageCommentsLoader? = RemoteImageCommentsLoader(httpClient: client, url: url)
        var capturedResults = [RemoteImageCommentsLoader.Result]()
        sut?.load(completion: {
            capturedResults.append($0)
        })
        
        sut = nil
        XCTAssertTrue(sut == nil, "Feed Loader has already been deallocated")
        
        client.complete(with: 200, data: makeData(from: []))
        
        XCTAssertTrue(capturedResults.isEmpty, "NO result should be return if Feed Loader has already been deallocated")
    }
}

extension LoadFeedCommentsFromRemoteUseCase {
    func makeSUT(
        url: URL = URL(string: "https://a-url.com")!,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (HTTPClientSpy, EssentialFeed.RemoteImageCommentsLoader) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentsLoader(httpClient: client, url: url)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (client, sut)
    }
    
    func expect(
        sut: RemoteImageCommentsLoader,
        toCompleteWith expectedResult: RemoteImageCommentsLoader.Result,
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
                guard let remoteFeedActualError = actualError as? RemoteImageCommentsLoader.Error,
                let remoteFeedExpectedError = expectedError as? RemoteImageCommentsLoader.Error
                else {
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
        message: String,
        createdAt: (date: Date, iso: String),
        username: String
    ) -> (model: ImageComment, json: [String: Any]) {
        
        let model = ImageComment(
            id: id,
            message: message,
            createdAt: createdAt.date,
            author: username
        
        )
        let json: [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.iso,
            "author": [
                "username": username
            ]
        ]
        
        return (model, json)
    }
    
    func makeData(
        from items: [[String: Any]]
    ) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
        .failure(error)
    }
}

