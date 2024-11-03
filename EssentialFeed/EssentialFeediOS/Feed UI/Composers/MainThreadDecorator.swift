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

extension MainThreadDecorator: FeedLoader where T == FeedLoader {
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
