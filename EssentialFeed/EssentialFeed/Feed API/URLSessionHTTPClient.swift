//
//  Untitled.swift
//  EssentialFeed
//
//  Created by Anthony on 9/10/24.
//
import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedErrorRepresentation: Error {}
    
    struct HTTPClientTaskWrapper: HTTPClientTask {
        var wrapped: URLSessionTask?
        
        func cancel() {
            wrapped?.cancel()
        }
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url) { data, urlResponse, error in
            if let error {
                completion(.failure(error))
            } else if let data, let urlResponse = urlResponse as? HTTPURLResponse {
                completion(.success((urlResponse, data)))
            } else {
                completion(.failure(UnexpectedErrorRepresentation()))
            }
        }
        task.resume()
        
        return HTTPClientTaskWrapper(wrapped: task)
    }
}
