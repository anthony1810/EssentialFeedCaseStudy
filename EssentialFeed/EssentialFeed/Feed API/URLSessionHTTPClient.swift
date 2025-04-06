//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Anthony on 26/1/25.
//
import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnexpecteRepresentationValue: Error {}
    struct HTTPClientTaskWrapper: HTTPClientTask {
        let wrapped: URLSessionDataTask
        
        func cancel() {
            wrapped.cancel()
        }
    }
    
    @discardableResult
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url) { data, res, error in
            
            completion(Result {
                if let error {
                    throw error
                } else if let data, let res = res as? HTTPURLResponse {
                   return (data, res)
                } else {
                    throw UnexpecteRepresentationValue()
                }
            })
        }
        
        task.resume()
        
        return HTTPClientTaskWrapper(wrapped: task)
    }
}
