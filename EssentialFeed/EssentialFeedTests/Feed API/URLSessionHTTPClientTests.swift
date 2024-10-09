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
    
    struct UnexpectedErrorRepresentation: Error {}
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data, urlResponse, error in
            if let error {
                completion(.failure(error))
            } else if let data, let urlResponse = urlResponse as? HTTPURLResponse {
                completion(.success(urlResponse, data))
            } else {
                completion(.failure(UnexpectedErrorRepresentation()))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = makeAnyUrl()
        let exp = expectation(description: "Wait for request")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let error = makeAnyError()
        guard let receivedError = resultErrorFor(data: nil, response: nil, error: error) else {
            XCTFail("Could not extract error from response")
            return
        }
        XCTAssertEqual(receivedError.code, error.code)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentations() {
        let httpURLResponse = makeAnyHTTPURLResponse()
        let anyURLResponse = makeAnyURLResponse()
        let receivedError = resultErrorFor(data: nil, response: nil, error: nil)
        
        XCTAssertNotNil(receivedError)
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyURLResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(data: Data(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: Data(), response: nil, error: receivedError))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyURLResponse, error: makeAnyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: httpURLResponse, error: makeAnyError()))
        XCTAssertNotNil(resultErrorFor(data: Data(), response: httpURLResponse, error: makeAnyError()))
        XCTAssertNotNil(resultErrorFor(data: Data(), response: anyURLResponse, error: makeAnyError()))
        XCTAssertNotNil(resultErrorFor(data: Data(), response: anyURLResponse, error: nil))
    }
    
    func test_getFromURL_returnsResponseOnValidDataAndHTTPURLResponse() {
        let data = Data("any data".utf8)
        let httpURLResponse = makeAnyHTTPURLResponse()
        let response = resultResponseFor(data: data, response: httpURLResponse, error: nil)?.0
        XCTAssertEqual(response?.url, httpURLResponse.url)
        XCTAssertEqual(response?.statusCode, httpURLResponse.statusCode)
    }
    
    func test_getFromURL_succeedsWithEmptyDataOnHttpURLResponseWithNilData() {
        let emptyData = Data()
        let result = resultResponseFor(data: emptyData, response: makeAnyHTTPURLResponse(), error: nil)
        XCTAssertEqual(result?.data, emptyData)
    }
    
    // MARK: - Helpers
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    func makeAnyError() -> NSError {
        NSError(domain: "any error", code: 1, userInfo: nil)
    }
    
    func makeAnyUrl() -> URL {
        URL(string: "https://any-url.com")!
    }
    
    func makeAnyURLResponse() -> URLResponse {
        URLResponse(url: makeAnyUrl(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    func makeAnyHTTPURLResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: makeAnyUrl(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    func resultResponseFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> (response: HTTPURLResponse, data: Data)? {
        
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        
        let exp = expectation(description: "Wait for completion")
        var receiveResponse: (HTTPURLResponse, Data)?
        
        sut.get(from: makeAnyUrl()) { result in
            switch result {
            case let .failure(error as NSError):
                XCTFail(
                    "Expected success, got failure \(error.localizedDescription) instead",
                    file: file,
                    line: line
                )
            case let .success(response, data):
                receiveResponse = (response, data)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receiveResponse
    }
    
    func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> NSError? {
        
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        
        let exp = expectation(description: "Wait for completion")
        var receivedError: NSError?
        
        sut.get(from: makeAnyUrl()) { result in
            switch result {
            case let .failure(error as NSError):
                receivedError = error
            default:
                XCTFail(
                    "Expected failure, got success instead",
                    file: file,
                    line: line
                )
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    
}

extension URLSessionHTTPClientTests {
    private class URLProtocolStub: URLProtocol {
           private static var stub: Stub?
           private static var requestObserver: ((URLRequest) -> Void)?
           
           private struct Stub {
               let data: Data?
               let response: URLResponse?
               let error: Error?
           }
           
           static func stub(data: Data?, response: URLResponse?, error: Error?) {
               stub = Stub(data: data, response: response, error: error)
           }
           
           static func observeRequests(observer: @escaping (URLRequest) -> Void) {
               requestObserver = observer
           }
           
           static func startInterceptingRequests() {
               URLProtocol.registerClass(URLProtocolStub.self)
           }
           
           static func stopInterceptingRequests() {
               URLProtocol.unregisterClass(URLProtocolStub.self)
               stub = nil
               requestObserver = nil
           }
           
           override class func canInit(with request: URLRequest) -> Bool {
               requestObserver?(request)
               return true
           }
           
           override class func canonicalRequest(for request: URLRequest) -> URLRequest {
               return request
           }
           
           override func startLoading() {
               if let data = URLProtocolStub.stub?.data {
                   client?.urlProtocol(self, didLoad: data)
               }
               
               if let response = URLProtocolStub.stub?.response {
                   client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
               }
               
               if let error = URLProtocolStub.stub?.error {
                   client?.urlProtocol(self, didFailWithError: error)
               }
               
               client?.urlProtocolDidFinishLoading(self)
           }
           
           override func stopLoading() {}
       }
}

