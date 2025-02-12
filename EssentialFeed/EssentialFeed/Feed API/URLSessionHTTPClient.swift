//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Anthony on 26/1/25.
//
import Foundation

public class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnexpecteRepresentationValue: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: url) { data, res, error in
            if let error {
                completion(.failure(error))
            } else if let data, let res = res as? HTTPURLResponse {
                completion(.success((data, res)))
            }else {
                completion(.failure(UnexpecteRepresentationValue()))
            }
        }.resume()
    }
}
