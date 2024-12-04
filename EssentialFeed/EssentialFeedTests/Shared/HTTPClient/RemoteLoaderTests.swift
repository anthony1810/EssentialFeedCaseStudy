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
    
    func test_load_deliversMappedDataWithValidData() {
        
        let expectedResource = "any resource"
        let (client, sut) = makeSUT(mapper: {_, data in
            String(data: data, encoding: .utf8)!
        })
        
        expect(sut: sut, toCompleteWith: .success(expectedResource)) {
            client.complete(with: 200, data: Data(expectedResource.utf8))
        }
    }

    func test_load_StopDeliverItemsWhenRemoteLoaderInstanceDeallocated() {
        
        let url = URL(string: "https://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteLoader? = RemoteLoader<String>(httpClient: client, url: url, mapper: {_, _ in "any "})
        var capturedResults = [RemoteLoader<String>.Result]()
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
        mapper: @escaping RemoteLoader<String>.Mapper = {_, _ in "any resource"},
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (HTTPClientSpy, RemoteLoader<String>) {
        let client = HTTPClientSpy()
        let sut = RemoteLoader<String>(httpClient: client, url: url, mapper: mapper)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (client, sut)
    }
    
    func expect(
        sut: RemoteLoader<String>,
        toCompleteWith expectedResult: RemoteLoader<String>.Result,
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
    
    func makeData(
        from items: [[String: Any]]
    ) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    func failure(_ error: RemoteLoader<String>.Error) -> RemoteLoader<String>.Result {
        .failure(error)
    }
}

