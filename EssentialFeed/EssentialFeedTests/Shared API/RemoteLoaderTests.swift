//
//  RemoteLoaderTests.swift
//  EssentialFeed
//
//  Created by Anthony on 29/7/25.
//
import EssentialFeed
import Foundation
import XCTest

class RemoteLoaderTests: XCTestCase {
    typealias SUT = RemoteLoader<String>

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
    
    func test_load_deliversErrorOnMapperError() {
        let (sut, client) = makeSUT(url: anyURL(), mapper: {_, _ in
            throw anyNSError()
        })
        
        expect(sut, toFinishedWith: failure(.invalidData)) {
            client.complete(withStatusCode: 200, data: Data())
        }
    }
    
    func test_load_deliversMappedDataOnSuccess() {
        let resource = "a resource"
        let (sut, client) = makeSUT(url: anyURL(), mapper: { data, _ in
            String(data: data, encoding: .utf8)!
        })
        
        expect(sut, toFinishedWith: .success(resource)) {
            client.complete(withStatusCode: 200, data: Data(resource.utf8))
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
    private func makeSUT(
        url: URL,
        mapper: @escaping SUT.Mapper = {_, _ in "any"},
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: SUT, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let loader = SUT(
            url: url,
            client: client,
            mapper: mapper
        )
        
        trackMemoryLeaks(client, file: file, line: line)
        trackMemoryLeaks(loader, file: file, line: line)
        
        return (loader, client)
    }
    
    private func expect(
        _ sut: SUT,
        toFinishedWith expectedResult: SUT.Result,
        when action: @escaping () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for load completion")
        
        sut.load { capturedResult in
            switch (capturedResult, expectedResult) {
            case let (.success(capturedItems), .success(expectedItems)):
                XCTAssertEqual(capturedItems, expectedItems, file: file, line: line)
            case let (.failure(capturedError as SUT.Error), .failure(expectedError as SUT.Error)):
                XCTAssertEqual(capturedError, expectedError, file: file, line: line)
            default:
                XCTFail("expected \(expectedResult) got \(capturedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func failure(_ error: SUT.Error) -> SUT.Result {
        .failure(error)
    }
}

