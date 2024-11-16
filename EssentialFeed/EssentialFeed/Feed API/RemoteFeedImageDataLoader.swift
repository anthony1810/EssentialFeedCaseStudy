//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Anthony on 16/11/24.
//
import Foundation

public final class RemoteFeedImageDataLoader {

    let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    private struct HTTPTaskWrapper: ImageLoadingDataTaskProtocol {
        let wrapped: HTTPClientTask
        
        func cancel() {
            wrapped.cancel()
        }
    }
    
    @discardableResult
    public func loadImageData(from url: URL, completion: @escaping (FeedImageLoaderProtocol.Result) -> Void) -> ImageLoadingDataTaskProtocol {
        HTTPTaskWrapper(wrapped: client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((res, data)):
                if  res.statusCode != 200 || data.isEmpty {
                    completion(.failure(Error.invalidData))
                } else {
                    completion(.success(data))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }

}
