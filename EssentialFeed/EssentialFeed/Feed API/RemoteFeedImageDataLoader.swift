//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Anthony on 6/4/25.
//

import Foundation

public final class RemoteFeedImageDataLoader: FeedImageDataLoader {
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case invalidData
        case connectivity
    }
    
    private class HTTPClientTaskWrapper: FeedImageDataLoaderTask {
        
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        var wrapped: HTTPClientTask?
        
        init(completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            self.completion?(result)
        }
        
        func cancel() {
            preventFurtherCalls()
            wrapped?.cancel()
        }
        
        private func preventFurtherCalls() {
            self.completion = nil
        }
    }
    
    @discardableResult
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion: completion)
        task.wrapped = client.get(from: url, completion: { [weak self] result in
            guard self != nil else { return }
            
            task.complete(
                with: result
                    .mapError { _ in Error.connectivity }
                    .flatMap { data, res in
                        let isValid = res.statusCode == 200 && !data.isEmpty
                        return isValid ? .success(data) : .failure(Error.invalidData)
                    }
            )
        })
        
        return task
    }
}
