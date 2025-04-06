//
//  HTTPClientSpy.swift
//  EssentialFeed
//
//  Created by Anthony on 6/4/25.
//
import Foundation
import EssentialFeed

final class HTTPClientSpy: HTTPClient {
    typealias Message = (url: URL, completion: (HTTPClient.Result) -> Void)
    var messages: [Message] = []
    
    var requestedURLs: [URL] {
        messages.map(\.url)
    }
    var cancelledImageURLs: [URL] = []
    
    private class Task: HTTPClientTask {
        let callback: (() -> Void)
        
        init(callback: @escaping () -> Void) {
            self.callback = callback
        }
        func cancel() {
            callback()
        }
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        messages.append((url, completion))
        
        return Task { [weak self] in
            self?.cancelledImageURLs.append(url)
        }
    }
    
    func complete(withError error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode statusCode: Int, data: Data = Data(), at index: Int = 0) {
        let res = HTTPURLResponse(url: requestedURLs[index], statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        messages[index].completion(.success((data, res)))
    }
}
