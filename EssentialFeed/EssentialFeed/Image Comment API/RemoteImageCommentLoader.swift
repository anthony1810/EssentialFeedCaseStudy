//
//  RemoteImageCommentLoader.swift
//  EssentialFeed
//
//  Created by Anthony on 28/7/25.
//
import Foundation
public typealias RemoteImageCommentLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: ImageCommentMapper.map)
    }
}
