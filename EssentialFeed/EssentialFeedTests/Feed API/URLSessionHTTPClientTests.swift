//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Anthony on 6/10/24.
//

import Foundation
import XCTest
import EssentialFeed

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

class URLSessionHTTPClient {
    let session: HTTPSession
    
    init(session: HTTPSession) {
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
    class URLSessionSpy: HTTPSession {
        
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let dataTask: HTTPSessionTask
            let error: Error?
            
            init(dataTask: HTTPSessionTask, error: Error? = nil) {
                self.dataTask = dataTask
                self.error = error
            }
        }
        
        func stub(url: URL, task: HTTPSessionTask = FakeSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(dataTask: task, error: error)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> HTTPSessionTask {
            
            guard let stub = stubs[url] else {
                XCTFail("Could not get stub for this \(url)")
                return FakeSessionDataTask()
            }
            
            completionHandler(nil, nil, stub.error)
            return stub.dataTask
        }
    }

    class FakeSessionDataTask: HTTPSessionTask {
        func resume() { }
    }
    
    class SessionDataTaskSpy: HTTPSessionTask {
        var resumeCount: Int = 0
        
        func resume() {
            resumeCount += 1
        }
    }
}

