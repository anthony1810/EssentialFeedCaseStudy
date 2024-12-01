//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Anthony on 21/11/24.
//
import Foundation
import EssentialFeed

final public class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoaderProtocol {
    
    let primary: FeedImageDataLoaderProtocol
    let fallback: FeedImageDataLoaderProtocol
    
    private class Task: ImageLoadingDataTaskProtocol {
        var wrapped: ImageLoadingDataTaskProtocol?
        
        func cancel() {
            wrapped?.cancel()
        }
    }
    
    public init(primary: FeedImageDataLoaderProtocol, fallback: FeedImageDataLoaderProtocol) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoaderProtocol.Result) -> Void) -> ImageLoadingDataTaskProtocol {
        let task = Task()

        task.wrapped = primary.loadImageData(from: url, completion: { [weak self] result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure:
                task.wrapped = self?.fallback.loadImageData(from: url, completion: completion)
            }
        })
        
        return task
    }
}
