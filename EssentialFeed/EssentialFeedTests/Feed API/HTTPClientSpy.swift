//
//  HTTPClientSpy.swift
//  EssentialFeed
//
//  Created by Anthony on 6/10/24.
//
import Foundation
import EssentialFeed

class HTTPClientSpy: HTTPClient {
    
    private struct Task: HTTPClientTask {
        func cancel() {}
    }
    var requestedURLs: [URL] {
        messages.map(\.url)
    }
    
    var messages : [(url: URL, completion: (HTTPClient.Result) -> Void)]
    
    init() {
        self.messages = []
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        messages.append((url, completion))
        return Task()
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
        messages[index].completion(.success((response, data)))
    }
}
