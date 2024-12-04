//
//  RemoteLoaderTests.swift
//  EssentialFeed
//
//  Created by Anthony on 4/12/24.
//

import XCTest
@testable import EssentialFeed

class RemoteLoaderTests: XCTestCase {
    
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
    
    func test_load_deliversErrorOnMapperError() {
        let (client, sut) = makeSUT(mapper: { _, _ in
            throw makeAnyError()
        })
        
        expect(sut: sut, toCompleteWith: failure(.invalidData)) {
            client.complete(with: 200, data: makeAnyData())
        }
    }
    
    func test_load_deliversEmptyArrayOnHTTPResponseWithEmptyValidJson() {
        let (client, sut) = makeSUT()
        
        expect(sut: sut, toCompleteWith: .success([])) {
            let emptyJsonItem = Data("{\"items\": []}".utf8)
            client.complete(with: 200, data: emptyJsonItem)
        }
    }

    func test_load_StopDeliverItemsWhenRemoteLoaderInstanceDeallocated() {
        
        let url = URL(string: "https://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteLoader? = RemoteLoader(httpClient: client, url: url)
        var capturedResults = [RemoteLoader.Result]()
        sut?.load(completion: {
            capturedResults.append($0)
        })
        
        sut = nil
        XCTAssertTrue(sut == nil, "Feed Loader has already been deallocated")
        
        client.complete(with: 200, data: makeData(from: []))
        
        XCTAssertTrue(capturedResults.isEmpty, "NO result should be return if Feed Loader has already been deallocated")
    }
}

extension RemoteLoaderTests {
    
   
    func makeSUT(
        url: URL = URL(string: "https://a-url.com")!,
        mapper: @escaping RemoteLoader.Mapper = {_, _ in .success([])},
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (HTTPClientSpy, RemoteLoader) {
        let client = HTTPClientSpy()
        let sut = RemoteLoader(httpClient: client, url: url)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (client, sut)
    }
    
    func expect(
        sut: RemoteLoader,
        toCompleteWith expectedResult: RemoteLoader.Result,
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
                let remoteFeedActualError = actualError as RemoteLoader.Error
                let remoteFeedExpectedError = expectedError as RemoteLoader.Error
                
                XCTAssertEqual(remoteFeedActualError, remoteFeedExpectedError, file: file, line: line)
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
    
    func failure(_ error: RemoteLoader.Error) -> RemoteLoader.Result {
        .failure(error)
    }
}

