//
//  Untitled.swift
//  EssentialFeed
//
//  Created by Anthony on 9/10/24.
//
import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedErrorRepresentation: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
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
