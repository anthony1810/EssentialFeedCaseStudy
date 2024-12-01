//
//  MainThreadDecorator.swift
//  EssentialFeed
//
//  Created by Anthony on 3/11/24.
//
import Foundation
import EssentialFeed

class MainThreadDecorator<T> {
    let decoratee: T
    
    init(_ decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(_ block: @escaping () -> Void) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async(execute: block)
            return
        }
       
        block()
    }
}

extension MainThreadDecorator: FeedLoaderProtocol where T == FeedLoaderProtocol {
    func load(completion: @escaping (FeedLoaderProtocol.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainThreadDecorator: FeedImageDataLoaderProtocol where T == FeedImageDataLoaderProtocol {
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoaderProtocol.Result) -> Void) -> any ImageLoadingDataTaskProtocol {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch {completion(result)}
        }
    }
}
