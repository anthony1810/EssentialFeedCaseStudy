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
    
//    func test_getFromURL_resumeDataTaskWithURL() {
//        let url = URL(string: "https://any-url.com")!
//        let task = SessionDataTaskSpy()
//        
//        let session = URLSessionSpy()
//        session.stub(url: url, task: task)
//        
//        let sut = URLSessionHTTPClient(session: session)
//        
//        sut.get(from: url, completion: { _ in })
//        
//        XCTAssertEqual(task.resumeCount, 1)
//    }
    
    func test_getFromURL_failsOnRequestError() {
        URLProtocolStub.startIntercepting()
        
        let url = URL(string: "https://any-url.com")!
        let expectedError = NSError(domain: "any error", code: 1, userInfo: nil)
    
        URLProtocolStub.stub(url: url, error: expectedError)
        
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
        
        private static var stubs = [URL: Stub]()
        
        private struct Stub {
            let error: Error?
        }
        
        static func stub(url: URL, error: Error? = nil) {
            print("-> stub error = \(error)")
            stubs[url] = Stub(error: error)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            
            let canInit = Self.stubs[url] != nil
            print("-> canInit canInit = \(canInit)")
            return canInit
        }
        
        class override func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = Self.stubs[url] else { return }
            
            if let error = stub.error {
                print("-> startLoading error = \(error)")
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
            Self.stubs.removeAll()
        }
    }
}

