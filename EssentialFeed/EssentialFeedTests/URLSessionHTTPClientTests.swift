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
    
    init(session: URLSession) {
        self.session = session
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_createsDataTaskWithURL() {
        let url = anyURL()
        let session = URLSessionSpy()
        session.stub(url: url)
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(session.requestedURLs, [url])
    }
    
    func test_getFromURL_resumesDataTaskWithURL() {
        let url = anyURL()
        let dataTaskSpy = DataTaskSpy()
        let sessionSpy = URLSessionSpy()
        sessionSpy.stub(url: url, dataTask: dataTaskSpy)
        
        let sut = URLSessionHTTPClient(session: sessionSpy)
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(dataTaskSpy.resumeCalledCount, 1)
    }
    
    func test_getFromURL_deliversErrorWhenDataTaskFailsWithError() {
        let url = anyURL()
        let expectedError = anyError()
        let sessionSpy = URLSessionSpy()
        sessionSpy.stub(url: url, error: expectedError)
        
        let sut = URLSessionHTTPClient(session: sessionSpy)
        
        let exp = expectation(description: "wait for get completion")
        var receiveError: Error?
        sut.get(from: url) { result in
            if case let .failure(error) = result {
                receiveError = error
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receiveError as NSError?, expectedError as NSError?)
    }
    
    // MARK: - Helpers
    private class URLSessionSpy: URLSession {
        var requestedURLs: [URL] = []
        private var stubs: [URL: Stub] = [:]
        
        private struct Stub {
            var dataTask: URLSessionDataTask?
            var error: Error?
        }
        
        func stub(url: URL, dataTask: URLSessionDataTask? = nil, error: Error? = nil) {
            stubs[url] = Stub(dataTask: dataTask, error: error)
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            requestedURLs.append(url)
            
            guard let stub = stubs[url] else {
                fatalError("Found no stub for URL \(url)")
            }
            
            completionHandler(nil, nil, stub.error)
            return stub.dataTask ?? FakeDataTask()
        }
    }
    
    private class FakeDataTask: URLSessionDataTask {
        override func resume() {}
    }
    private class DataTaskSpy: URLSessionDataTask {
        var resumeCalledCount: Int = 0
        
        override func resume() {
            resumeCalledCount += 1
        }
    }
    
}
