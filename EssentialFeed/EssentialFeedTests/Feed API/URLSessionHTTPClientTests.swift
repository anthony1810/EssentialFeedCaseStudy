//
//  URLSessionHTTPClientTests.swift
//  EssentialFeed
//
//  Created by Anthony on 26/1/25.
//

import Foundation
import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        
        URLProtocolStub.removeStub()
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
        let expectedError = anyNSError()
        
        XCTAssertNotNil(resultError(for: (nil, reponse: nil, error: expectedError)))
    }
    
    func test_getFromURL_deliversErrorOnAllInvalidCases() {
        XCTAssertNotNil(resultError(for: (nil, reponse: nil, error: nil)))
        XCTAssertNotNil(resultError(for: (nil, reponse: anyNonHTTPURLResponse(), error: nil)))
        XCTAssertNotNil(resultError(for: (anydata(), reponse: anyNonHTTPURLResponse(), error: nil)))
        XCTAssertNotNil(resultError(for: (anydata(), reponse: nil, error: anyNSError())))
        XCTAssertNotNil(resultError(for: (nil, reponse: anyNonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultError(for: (nil, reponse: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultError(for: (anydata(), reponse: anyNonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultError(for: (anydata(), reponse: anyNonHTTPURLResponse(), error: nil)))
    }
    
    func test_getFromURL_deliversSuccessOnNonEmptyDataAndResponse() {
        let response = anyHTTPURLResponse()
        let data = anydata()
        
        let receivedValue = resultValue(for: data, reponse: response, error: nil)
        
        XCTAssertEqual(receivedValue?.data, data)
        XCTAssertEqual(receivedValue?.res.statusCode, response.statusCode)
        XCTAssertEqual(receivedValue?.res.url, response.url)
    }
    
    func test_getFromURL_deliversSuccessOnNilDataAndNonNilResponse() {
        let response = anyHTTPURLResponse()
        
        let receivedValue = resultValue(for: nil, reponse: response, error: nil)
        
        XCTAssertNotNil(receivedValue?.data)
        XCTAssertEqual(receivedValue?.res.statusCode, response.statusCode)
        XCTAssertEqual(receivedValue?.res.url, response.url)
    }
    
    func test_getFromURL_deliversSuccessOnNonEmptyDataAndAnyResponse() {
        let response = anyHTTPURLResponse()
        let data = anydata()
        
        let receivedValue = resultValue(for: data, reponse: response, error: nil)
        
        XCTAssertEqual(receivedValue?.data, data)
        XCTAssertEqual(receivedValue?.res.statusCode, response.statusCode)
        XCTAssertEqual(receivedValue?.res.url, response.url)
    }
    
    func test_cancelGetFromURLTask_cancelsURLRequestTask() {
        let receivedError = self.resultError(taskHandler: { $0.cancel() }) as NSError?
    
        XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
    }
    
    // MARK: - Helpers
    @discardableResult
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)
        
        trackMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func resultError(
        for values: (data: Data?,
        reponse: URLResponse?,
        error: Error?)? = nil,
        taskHandler: (any HTTPClientTask) -> Void = { _ in },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Error? {
        let result = result(for: values, taskHandler: taskHandler)
        switch result {
        case let .success((data, res)):
            XCTFail("Expected failure but got success (\(data), \(res)) instead", file: file, line: line)
        case .failure(let error):
            return error
        }
        
        return nil
    }
    
    private func resultValue(
        for data: Data?,
        reponse: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (data: Data, res: HTTPURLResponse)? {
        let result = result(for: (data, reponse: reponse, error: error))
        switch result {
        case let .success((data, res)):
            return (data, res)
        default:
            XCTFail("Expect success but got \(result) instead")
        }
        
        return nil
    }
    
    private func result(
        for values: (data: Data?,
        reponse: URLResponse?,
        error: Error?)?,
        taskHandler: (HTTPClientTask) -> Void = { _ in },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> HTTPClient.Result {
        
        let url = anyURL()
        URLProtocolStub.stub(data: values?.data, response: values?.reponse, error: values?.error)
        
        var expectedResult: HTTPClient.Result?
        let exp = expectation(description: "wait for get completion")
        
        let task = makeSUT(file: file, line: line).get(from: url) { result in
            expectedResult = result
            exp.fulfill()
        }
        
        taskHandler(task)
        
        wait(for: [exp], timeout: 1.0)
        
        return expectedResult!
    }
    
    private class URLProtocolStub: URLProtocol {
        private static let queue = DispatchQueue(label: "URLSessionHTTPClientTests.URLProtocolStub")
        private static var stub: Stub? {
            get { queue.sync { URLProtocolStub._stub } }
            set { queue.sync { URLProtocolStub._stub = newValue }}
        }
        private static var _stub: Stub?
        
        private struct Stub {
            let onStartLoading: (URLProtocolStub) -> Void
        }
        
        static func stub(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
            stub = Stub(onStartLoading: { urlProtocol in
                guard let client = urlProtocol.client else { return }
                
                if let data {
                    client.urlProtocol(urlProtocol, didLoad: data)
                }
                
                if let response {
                    client.urlProtocol(urlProtocol, didReceive: response, cacheStoragePolicy: .notAllowed)
                }
                
                if let error  {
                    client.urlProtocol(urlProtocol, didFailWithError: error)
                } else {
                    client.urlProtocolDidFinishLoading(urlProtocol)
                }
            })
        }
        
        static func removeStub() {
            Self.stub = nil
        }
        
        static func observeRequest(_ block: @escaping (URLRequest) -> Void) {
            stub = Stub(onStartLoading: { urlProtocol in
                urlProtocol.client?.urlProtocolDidFinishLoading(urlProtocol)
                
                block(urlProtocol.request)
            })
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override func startLoading() {
            URLProtocolStub.stub?.onStartLoading(self)
        }
        
        override func stopLoading() {}
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
    }
}
