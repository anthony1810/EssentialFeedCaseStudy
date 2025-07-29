//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Anthony on 24/1/25.
//
import Foundation
public typealias RemoteFeedLoader = RemoteLoader<[FeedImage]>

public extension RemoteFeedLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: FeedMapper.map)
    }
}
