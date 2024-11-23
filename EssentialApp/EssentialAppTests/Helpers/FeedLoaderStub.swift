//
//  FeedLoaderStub.swift
//  EssentialApp
//
//  Created by Anthony on 23/11/24.
//
import EssentialFeed

class FeedLoaderStub: FeedLoaderProtocol {
    let result: FeedLoaderProtocol.Result
    
    init(result: FeedLoaderProtocol.Result) {
        self.result = result
    }
    
    func load(completion: @escaping (FeedLoaderProtocol.Result) -> Void) {
        completion(result)
    }
}
