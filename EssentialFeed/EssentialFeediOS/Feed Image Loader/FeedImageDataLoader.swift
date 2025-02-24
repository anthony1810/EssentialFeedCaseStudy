//
//  FeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Anthony on 24/2/25.
//
import Foundation

public protocol ImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> ImageDataLoaderTask
}
