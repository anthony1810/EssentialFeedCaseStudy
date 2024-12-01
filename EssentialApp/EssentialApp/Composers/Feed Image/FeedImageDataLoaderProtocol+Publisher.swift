//
//  FeedImageDataLoaderProtocol+Publisher.swift
//  EssentialApp
//
//  Created by Anthony on 1/12/24.
//
import UIKit
import EssentialFeed
import EssentialFeediOS
import RealmSwift
import Combine

public extension FeedImageDataLoaderProtocol {
    typealias Publisher = AnyPublisher<Data?, Error>
    
    func loadImageDataPublisher(from url: URL) -> Publisher {
        var task: ImageLoadingDataTaskProtocol?
        return Deferred {
            Future { promise in
                task = self.loadImageData(from: url, completion: promise)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}
