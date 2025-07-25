//
//  HTTPClientStub.swift
//  EssentialApp
//
//  Created by Anthony on 25/7/25.
//
import Foundation
import EssentialFeed

class HTTPClientStub: HTTPClient {
    private class Task: HTTPClientTask {
        func cancel() {}
    }
    private let stub: (URL) -> HTTPClient.Result
    
    init(stub: @escaping (URL) -> HTTPClient.Result) {
        self.stub = stub
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        completion(stub(url))
        
        return Task()
    }
    
    static var offline: HTTPClientStub {
        .init(stub: { _ in
                .failure(URLError(.notConnectedToInternet))
        })
    }
    
    static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
        HTTPClientStub { url in .success(stub(url))}
    }
}
