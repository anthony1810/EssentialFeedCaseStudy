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
    
    init(session: URLSession) {
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
    
    func test_getFromURL_resumeDataTaskWithURL() {
        let url = URL(string: "https://any-url.com")!
        let task = SessionDataTaskSpy()
        
        let session = URLSessionSpy()
        session.stub(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url, completion: { _ in })
        
        XCTAssertEqual(task.resumeCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "https://any-url.com")!
        let task = SessionDataTaskSpy()
        let expectedError = NSError(domain: "any error", code: 0)
        
        let session = URLSessionSpy()
        session.stub(url: url, task: task, error: expectedError)
        
        let sut = URLSessionHTTPClient(session: session)
        
        let exp = expectation(description: "waiting for get completion")
        sut.get(from: url, completion: { result in
            if case let .failure(error as NSError) = result {
                XCTAssertEqual(error, expectedError)
            } else {
                XCTFail("expected \(expectedError) but got \(result) instead")
            }
            
            exp.fulfill()
        })
        
        sut.get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    class URLSessionSpy: URLSession {
        
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let dataTask: URLSessionDataTask
            let error: Error?
            
            init(dataTask: URLSessionDataTask, error: Error? = nil) {
                self.dataTask = dataTask
                self.error = error
            }
        }
        
        func stub(url: URL, task: URLSessionDataTask = FakeSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(dataTask: task, error: error)
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
            
            guard let stub = stubs[url] else {
                XCTFail("Could not get stub for this \(url)")
                return FakeSessionDataTask()
            }
            
            completionHandler(nil, nil, stub.error)
            return stub.dataTask
        }
    }

    class FakeSessionDataTask: URLSessionDataTask {
        override func resume() { }
    }
    
    class SessionDataTaskSpy: URLSessionDataTask {
        var resumeCount: Int = 0
        
        override func resume() {
            resumeCount += 1
        }
    }
}

