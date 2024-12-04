//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Anthony on 5/10/24.
//
import Foundation

public typealias RemoteFeedLoader = RemoteLoader<[FeedImage]>
public extension RemoteFeedLoader {
    convenience init(httpClient: HTTPClient, url: URL) {
        self.init(httpClient: httpClient, url: url, mapper: FeedItemsMapper.map)
    }
}

