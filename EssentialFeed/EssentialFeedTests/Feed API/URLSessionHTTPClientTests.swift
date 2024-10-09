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
    
    override class func setUp() {
        super.setUp()
        
        URLProtocolStub.startIntercepting()
    }
    
    override class func tearDown() {
        
        URLProtocolStub.stopIntercepting()
        
        super.tearDown()
    }
    
    func test_getFromURL_performGetRequestWithURL() {
        let url = makeAnyUrl()
        
        let exp = expectation(description: "wait for completion")
        
        URLProtocolStub.observeRequests { request in
            
            print("-> calling to verify observeRequests")
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            
            exp.fulfill()
        }
        
        makeSUT().get(from: url, completion: { _ in })
        
        wait(for: [exp], timeout: 1.0)
    }
    
//    func test_getFromURL_failsOnRequestError() {
//      
//        let url = makeAnyUrl()
//        let expectedError = makeAnyError()
//    
//        URLProtocolStub.stub(data: nil, urlResponse: nil, error: expectedError)
//        
//        let exp = expectation(description: "waiting for get completion")
//        makeSUT().get(from: url, completion: { result in
//            if case let .failure(error as NSError) = result {
//                XCTAssertEqual(error.code, expectedError.code)
//            } else {
//                XCTFail("expected \(expectedError) but got \(result) instead")
//            }
//            
//            exp.fulfill()
//        })
//        
//        wait(for: [exp], timeout: 1)
//    }
    
    // MARK: - Helpers
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut)
        return sut
    }
    
    func makeAnyError() -> NSError {
        NSError(domain: "any error", code: 1, userInfo: nil)
    }
    
    func makeAnyUrl() -> URL {
        URL(string: "https://any-url.com")!
    }
}

extension URLSessionHTTPClientTests {
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

