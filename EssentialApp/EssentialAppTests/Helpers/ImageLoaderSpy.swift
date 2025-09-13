//
//  ImageLoaderSpy.swift
//  EssentialApp
//
//  Created by Anthony on 20/7/25.
//
//import Foundation
//import EssentialFeed
//
//class ImageLoaderSpy: FeedImageDataLoader {
//    private let result: FeedImageDataLoader.Result
//    private var messages: FeedImageDataLoader.Result?
//    private(set) var cancelURLs: [URL] = []
//    
//    var loadedImageURLs: [URL] {
//        messages.map { $0.url }
//    }
//    
//    init(result: FeedImageDataLoader.Result) {
//        self.result = result
//    }
//    
//    func loadImageData(from url: URL) throws -> Data {
//        messages.append((url, completion))
//        return Task(callback: { [weak self] in
//            self?.cancelURLs.append(url)
//        })
//    }
//    
//    func completeAtIndex(_ index: Int = 0) {
//        messages[index].completion(result)
//    }
//}
