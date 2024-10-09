//
//  HTTPClientSpy.swift
//  EssentialFeed
//
//  Created by Anthony on 6/10/24.
//
import Foundation
import EssentialFeed

class HTTPClientSpy: HTTPClient {
    
    var requestedURLs: [URL] {
        messages.map(\.url)
    }
    
    var messages : [(url: URL, completion: (HTTPClientResult) -> Void)]
    
    init() {
        self.messages = []
    }
    
    func get(from url: URL, completion: @escaping (EssentialFeed.HTTPClientResult) -> Void) {
        messages.append((url, completion))
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(with statusCode: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(
            url: messages[index].url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        messages[index].completion(.success(response, data))
    }
}
