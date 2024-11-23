//
//  FeedImageDataLoaderSpy.swift
//  EssentialApp
//
//  Created by Anthony on 23/11/24.
//
import Foundation
import EssentialFeed

final class FeedImageDataLoaderSpy: FeedImageDataLoaderProtocol {
    var messages = [(url: URL, completion: ((FeedImageDataLoaderProtocol.Result) -> Void))]()
    var loadedURLs: [URL] {
        messages.map(\.url)
    }
    private(set) var cancelledURLs = [URL]()
    
    private class Task: ImageLoadingDataTaskProtocol {
        let callback: () -> Void
        
        init(callback: @escaping () -> Void) {
            self.callback = callback
        }
        
        func cancel() {
            callback()
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoaderProtocol.Result) -> Void) -> ImageLoadingDataTaskProtocol {
        messages.append((url, completion))
        
        return Task(callback: { [weak self] in
            self?.cancelledURLs.append(url)
        })
    }
    
    func completeLoad(with result: FeedImageDataLoaderProtocol.Result, at index: Int = 0) {
        messages[index].completion(result)
    }
}
