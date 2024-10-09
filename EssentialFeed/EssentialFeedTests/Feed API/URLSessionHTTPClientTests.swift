//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Anthony on 6/10/24.
//

import Foundation
import XCTest
import EssentialFeed


class URLSessionHTTPClient {
    let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_performGetRequestWithURL() {
        URLProtocolStub.startIntercepting()
        
        let url = URL(string: "https://any-url.com")!
        
        let exp = expectation(description: "wait for completion")
        
        URLSessionHTTPClient().get(from: url, completion: { _ in })
        
        URLProtocolStub.observeRequests { request in
            
            print("-> calling to verify observeRequests")
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        URLProtocolStub.stopIntercepting()
    }
    
    func test_getFromURL_failsOnRequestError() {
        URLProtocolStub.startIntercepting()
        
        let url = URL(string: "https://any-url.com")!
        let expectedError = NSError(domain: "any error", code: 1, userInfo: nil)
    
        URLProtocolStub.stub(data: nil, urlResponse: nil, error: expectedError)
        
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "waiting for get completion")
        sut.get(from: url, completion: { result in
            if case let .failure(error as NSError) = result {
                XCTAssertEqual(error.code, expectedError.code)
            } else {
                XCTFail("expected \(expectedError) but got \(result) instead")
            }
            
            exp.fulfill()
        })
        
        sut.get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1)
        
        URLProtocolStub.stopIntercepting()
    }
    
    // MARK: - Helpers
    class URLProtocolStub: URLProtocol {
        
        private static var stub: Stub?
        private static var observer: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, urlResponse: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: urlResponse, error: error)
        }
        
        static func observeRequests(_ observer: @escaping (URLRequest) -> Void) {
            print("-> set observeRequests")
            Self.observer = observer
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            print("-> call observeRequests  url = \(request.url) and method = \(request.httpMethod)")
            Self.observer?(request)
            return true
        }
        
        class override func canonicalRequest(for request: URLRequest) -> URLRequest {
            
            return request
        }
        
        override func startLoading() {
            guard let stub = Self.stub else { return }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
        
        class func startIntercepting() {
            URLProtocol.registerClass(self)
        }
        
        class func stopIntercepting() {
            URLProtocol.unregisterClass(self)
            Self.stub = nil
            Self.observer = nil
        }
    }
}

