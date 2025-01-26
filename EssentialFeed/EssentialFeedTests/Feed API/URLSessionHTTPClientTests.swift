//
//  URLSessionHTTPClientTests.swift
//  EssentialFeed
//
//  Created by Anthony on 26/1/25.
//

import Foundation
import XCTest
import EssentialFeed

class URLSessionHTTPClient: HTTPClient {
    
    struct UnexpecteRepresentationValue: Error {}
    
    func get(from url: URL, completion: @escaping (LoadResult) -> Void) {
        session.dataTask(with: url) { data, res, error in
            if let error {
                completion(.failure(error))
            } else if let data, let res = res as? HTTPURLResponse {
                completion(.success((data, res)))
            }else {
                completion(.failure(UnexpecteRepresentationValue()))
            }
        }.resume()
    }
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        URLProtocolStub.startIntercepting()
    }
    
    override func tearDown() {
        super.tearDown()
        
        URLProtocolStub.stopIntercepting()
    }
    
    func test_getFromURL_requestsDataFromURL() {
        let expectedUrl = anyURL()
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion")
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(expectedUrl, request.url)
            XCTAssertEqual(request.httpMethod, "GET")
            
            exp.fulfill()
        }
        
        sut.get(from: expectedUrl) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_deliversErrorWhenDataTaskFailsWithError() {
        let expectedError = anyError()
        
        XCTAssertNotNil(resultError(for: nil, reponse: nil, error: expectedError))
    }
    
    func test_getFromURL_deliversErrorOnAllInvalidCases() {
        XCTAssertNotNil(resultError(for: nil, reponse: nil, error: nil))
        XCTAssertNotNil(resultError(for: nil, reponse: anyNonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultError(for: anydata(), reponse: anyNonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultError(for: anydata(), reponse: nil, error: anyError()))
        XCTAssertNotNil(resultError(for: nil, reponse: anyNonHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultError(for: nil, reponse: anyHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultError(for: anydata(), reponse: anyNonHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultError(for: anydata(), reponse: anyNonHTTPURLResponse(), error: nil))
    }
    
    func test_getFromURL_deliversSuccessOnNonEmptyDataAndResponse() {
        let response = anyHTTPURLResponse()
        let data = anydata()
        
        let receivedValue = resultValue(for: data, reponse: response, error: nil)
        
        XCTAssertEqual(receivedValue?.data, data)
        XCTAssertEqual(receivedValue?.res.statusCode, response.statusCode)
        XCTAssertEqual(receivedValue?.res.url, response.url)
    }
    
    func test_getFromURL_deliversSuccessOnNilDataAndNonNilResponse() {
        let response = anyHTTPURLResponse()
        
        let receivedValue = resultValue(for: nil, reponse: response, error: nil)
        
        XCTAssertNotNil(receivedValue?.data)
        XCTAssertEqual(receivedValue?.res.statusCode, response.statusCode)
        XCTAssertEqual(receivedValue?.res.url, response.url)
    }
    
    func test_getFromURL_deliversSuccessOnNonEmptyDataAndAnyResponse() {
        let response = anyHTTPURLResponse()
        let data = anydata()
        
        let receivedValue = resultValue(for: data, reponse: response, error: nil)
        
        XCTAssertEqual(receivedValue?.data, data)
        XCTAssertEqual(receivedValue?.res.statusCode, response.statusCode)
        XCTAssertEqual(receivedValue?.res.url, response.url)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func resultError(
        for data: Data?,
        reponse: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Error? {
        let result = result(for: data, reponse: reponse, error: error)
        switch result {
        case let .success((data, res)):
            XCTFail("Expected failure but got success (\(data), \(res)) instead", file: file, line: line)
        case .failure(let error):
            return error
        }
        
        return nil
    }
    
    private func resultValue(
        for data: Data?,
        reponse: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (data: Data, res: HTTPURLResponse)? {
        let result = result(for: data, reponse: reponse, error: error)
        switch result {
        case let .success((data, res)):
            return (data, res)
        default:
            XCTFail("Expect success but got \(result) instead")
        }
        
        return nil
    }
    
    private func result(
        for data: Data?,
        reponse: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> HTTPClient.LoadResult {
        let url = anyURL()
        URLProtocolStub.stub(data: data, response: reponse, error: error)
        
        var expectedResult: HTTPClient.LoadResult?
        let exp = expectation(description: "wait for get completion")
        makeSUT(file: file, line: line).get(from: url) { result in
            expectedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return expectedResult!
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            var data: Data?
            var response: URLResponse?
            var error: Error?
        }
        
        static func stub(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func startIntercepting() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopIntercepting() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            Self.stub = nil
            Self.requestObserver = nil
        }
        
        static func observeRequest(_ block: @escaping (URLRequest) -> Void) {
            requestObserver = block
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override func startLoading() {
            
            if let data = Self.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = Self.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
            }
            
            if let error = Self.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
           
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
    }
}
