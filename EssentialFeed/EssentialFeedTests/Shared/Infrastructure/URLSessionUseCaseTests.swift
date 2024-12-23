//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Anthony on 6/10/24.
//

import Foundation
import XCTest
import EssentialFeed

class LoadFeedFromRemoteUseCaseTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        
        URLProtocolStub.removeStub()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = makeAnyUrl()
        let exp = expectation(description: "Wait for request")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let error = makeAnyError()
        guard let receivedError = resultErrorFor(data: nil, response: nil, error: error) else {
            XCTFail("Could not extract error from response")
            return
        }
        XCTAssertEqual(receivedError.code, error.code)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentations() {
        let httpURLResponse = makeAnyHTTPURLResponse()
        let anyURLResponse = makeAnyURLResponse()
        let receivedError = resultErrorFor(data: nil, response: nil, error: nil)
        
        XCTAssertNotNil(receivedError)
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyURLResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(data: Data(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: Data(), response: nil, error: receivedError))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyURLResponse, error: makeAnyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: httpURLResponse, error: makeAnyError()))
        XCTAssertNotNil(resultErrorFor(data: Data(), response: httpURLResponse, error: makeAnyError()))
        XCTAssertNotNil(resultErrorFor(data: Data(), response: anyURLResponse, error: makeAnyError()))
        XCTAssertNotNil(resultErrorFor(data: Data(), response: anyURLResponse, error: nil))
    }
    
    func test_getFromURL_returnsResponseOnValidDataAndHTTPURLResponse() {
        let data = Data("any data".utf8)
        let httpURLResponse = makeAnyHTTPURLResponse()
        let response = resultResponseFor(data: data, response: httpURLResponse, error: nil)?.0
        XCTAssertEqual(response?.url, httpURLResponse.url)
        XCTAssertEqual(response?.statusCode, httpURLResponse.statusCode)
    }
    
    func test_getFromURL_succeedsWithEmptyDataOnHttpURLResponseWithNilData() {
        let emptyData = Data()
        let result = resultResponseFor(data: emptyData, response: makeAnyHTTPURLResponse(), error: nil)
        XCTAssertEqual(result?.data, emptyData)
    }
    
    func test_cancelGetFromURL_cancelsRequest() {
        let receiveError = resultErrorFor(data: makeAnyData(), response: makeAnyHTTPURLResponse(), error: makeAnyError(), taskHandler: { $0.cancel() })
        
        XCTAssertNotNil(receiveError)
    }
    
    // MARK: - Helpers
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    func resultResponseFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> (response: HTTPURLResponse, data: Data)? {
        let result = resultFor((data: data, response: response, error: error))
        
        switch result {
        case let .failure(error as NSError):
            XCTFail(
                "Expected success, got failure \(error.localizedDescription) instead",
                file: file,
                line: line
            )
            return nil
        case let .success((response, data)):
            return (response, data)
        }
    }
    
    func resultErrorFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        taskHandler: (HTTPClientTask) -> Void = { _ in },
        file: StaticString = #file,
        line: UInt = #line
    ) -> NSError? {
        
        let result = resultFor((data: data, response: response, error: error))
        
        switch result {
        case let .failure(error as NSError):
            return error
        default:
            XCTFail(
                "Expected failure, got success instead",
                file: file,
                line: line
            )
            return nil
        }
    }
    
    func resultFor(
        _ values: (data: Data?, response: URLResponse?, error: Error?)?,
        taskHandler: (HTTPClientTask) -> Void = { _ in },
        file: StaticString = #file,
        line: UInt = #line
    ) -> HTTPClient.Result {
        
        values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
        
        let sut = makeSUT(file: file, line: line)
        
        let exp = expectation(description: "Wait for completion")
        var receiveResult: HTTPClient.Result!
        
        taskHandler(sut.get(from: makeAnyUrl()) { result in
            receiveResult = result
            
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
        return receiveResult
    }
}
