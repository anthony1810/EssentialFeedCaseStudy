//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Anthony on 16/11/24.
//
import Foundation

public final class RemoteFeedImageDataLoader: FeedImageLoaderProtocol {

    let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private final class HTTPTaskWrapper: ImageLoadingDataTaskProtocol {
        
        var wrapped: HTTPClientTask?
        private var completion: ((FeedImageLoaderProtocol.Result) -> Void)?
        
        init(completion: @escaping ((FeedImageLoaderProtocol.Result) -> Void)) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageLoaderProtocol.Result) {
            self.completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }
        
        func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageLoaderProtocol.Result) -> Void) -> ImageLoadingDataTaskProtocol {
        let task = HTTPTaskWrapper(completion: completion)
        
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result
                .mapError { _ in Error.connectivity }
                .flatMap { (reponse, data) in
                    let isValid = reponse.isOK && !data.isEmpty
                    return isValid ? .success(data) : .failure(Error.invalidData)
                }
            )
        }
        
        return task
    }

}
