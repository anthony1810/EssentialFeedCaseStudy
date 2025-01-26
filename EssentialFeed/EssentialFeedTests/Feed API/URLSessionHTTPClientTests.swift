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
        session.dataTask(with: url) { a, b, error in
            if let error {
                completion(.failure(error))
            } else {
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
        let url = anyURL()
        let expectedError = anyError()
        URLProtocolStub.stub(error: expectedError)
        
        let sut = makeSUT()
        
        let exp = expectation(description: "wait for get completion")
        var receiveError: Error?
        sut.get(from: url) { result in
            if case let .failure(error) = result {
                receiveError = error
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNotNil(receiveError)
    }
    
    func test_getFromURL_deliversErrorOnAllNilValues() {
        let url = anyURL()
        URLProtocolStub.stub(data: nil, response: nil, error: nil)
        
        let sut = makeSUT()
        
        let exp = expectation(description: "wait for get completion")
        sut.get(from: url) { result in
            if case .success = result {
                XCTFail("Expected failure but got success instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackMemoryLeaks(sut, file: file, line: line)
        return sut
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
