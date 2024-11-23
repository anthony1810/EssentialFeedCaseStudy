//
//  ImageLoadingDataTaskProtocol.swift
//  EssentialFeed
//
//  Created by Anthony on 30/10/24.
//
import Foundation

public protocol ImageLoadingDataTaskProtocol {
    func cancel()
}

public protocol FeedImageDataLoaderProtocol {
    typealias Result = Swift.Result<Data?, Error>
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> ImageLoadingDataTaskProtocol
}
