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
        session.dataTask(with: url) { _, _, _ in }.resume()
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
    
    // MARK: - Helpers
    private class URLSessionSpy: URLSession {
        var requestedURLs: [URL] = []
        private var stubs: [URL: URLSessionDataTask] = [:]
        
        func stub(url: URL, dataTask: URLSessionDataTask) {
            stubs[url] = dataTask
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            requestedURLs.append(url)
            
            return stubs[url] ?? FakeDataTask()
        }
    }
    
    private class FakeDataTask: URLSessionDataTask {}
    private class DataTaskSpy: URLSessionDataTask {
        var resumeCalledCount: Int = 0
        
        override func resume() {
            resumeCalledCount += 1
        }
    }
    
}
