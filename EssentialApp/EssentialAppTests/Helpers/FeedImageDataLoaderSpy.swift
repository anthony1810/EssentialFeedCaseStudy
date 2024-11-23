//
//  FeedImageDataLoaderSpy.swift
//  EssentialApp
//
//  Created by Anthony on 23/11/24.
//
import Foundation
import EssentialFeed

final class FeedImageDataLoaderSpy: FeedImageLoaderProtocol {
    var messages = [(url: URL, completion: ((FeedImageLoaderProtocol.Result) -> Void))]()
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
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageLoaderProtocol.Result) -> Void) -> ImageLoadingDataTaskProtocol {
        messages.append((url, completion))
        
        return Task(callback: { [weak self] in
            self?.cancelledURLs.append(url)
        })
    }
    
    func completeLoad(with result: FeedImageLoaderProtocol.Result, at index: Int = 0) {
        messages[index].completion(result)
    }
}
