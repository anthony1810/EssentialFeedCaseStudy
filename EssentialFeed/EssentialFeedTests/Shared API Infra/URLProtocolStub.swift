//
//  URLProtocolStub.swift
//  EssentialFeed
//
//  Created by Anthony on 6/4/25.
//
import Foundation

final class URLProtocolStub: URLProtocol {
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
