//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Anthony on 2/12/24.
//

import Foundation

public final class RemoteImageCommentsLoader {
    let httpClient: HTTPClient
    let url: URL
    
    public typealias Result = Swift.Result<[ImageComment], Error>
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(httpClient: HTTPClient, url: URL) {
        self.httpClient = httpClient
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        httpClient.get(from: self.url, completion: { [weak self] httpCompletion in
            guard let self else { return }
            switch httpCompletion {
            case .success((let res, let data)):
                completion(self.toRemoteFeedItemResult(from: res, data: data))
            case .failure:
                completion(.failure(Self.Error.connectivity))
            }
        })
    }
    
    func toRemoteFeedItemResult(from res: HTTPURLResponse, data: Data) -> Result {
        do {
            let result = try FeedCommentItemsMapper.map(res, data: data)
            return .success(result)
        } catch {
            print(error)
            return .failure(.invalidData)
        }
    }
}
