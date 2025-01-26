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
    func get(from url: URL, completion: @escaping (LoadResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_deliversErrorWhenDataTaskFailsWithError() {
        URLProtocolStub.startIntercepting()
        let url = anyURL()
        let expectedError = anyError()
        URLProtocolStub.stub(url: url, error: expectedError)
        
        let sut = URLSessionHTTPClient()
        
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
        
        URLProtocolStub.stopIntercepting()
    }
    
    // MARK: - Helpers
    private class URLProtocolStub: URLProtocol {
        var requestedURLs: [URL] = []
        private static var stubs: [URL: Stub] = [:]
        
        private struct Stub {
            var error: Error?
        }
        
        static func stub(url: URL, error: Error? = nil) {
            stubs[url] = Stub(error: error)
        }
        
        static func startIntercepting() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopIntercepting() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            
            return stubs[url] != nil
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else {
                return
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
    }
}
