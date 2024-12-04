//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Anthony on 2/12/24.
//

import Foundation

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>
public extension RemoteImageCommentsLoader {
    convenience init(httpClient: HTTPClient, url: URL) {
        self.init(httpClient: httpClient, url: url, mapper: FeedCommentItemsMapper.map)
    }
}
