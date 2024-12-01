//
//  FeedLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Anthony on 21/11/24.
//
import Foundation
import EssentialFeed

public final class FeedLoaderWithFallbackComposite: FeedLoaderProtocol {
    let primary: FeedLoaderProtocol
    let fallback: FeedLoaderProtocol
    
    public init(primary: FeedLoaderProtocol, fallback: FeedLoaderProtocol) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public func load(completion: @escaping (FeedLoaderProtocol.Result) -> Void) {
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
