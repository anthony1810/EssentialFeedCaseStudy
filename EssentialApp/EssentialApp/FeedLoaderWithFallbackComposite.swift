//
//  FeedLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Anthony on 21/11/24.
//
import Foundation
import EssentialFeed

public final class FeedLoaderWithFallbackComposite: FeedLoader {
    let primary: FeedLoader
    let fallback: FeedLoader
    
    public init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load { [weak self] primaryResult in
            switch primaryResult {
            case .success:
                completion(primaryResult)
            case .failure:
                self?.fallback.load(completion: completion)
            }
        }
    }
}
