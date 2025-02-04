//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Anthony on 4/2/25.
//
import Foundation

public final class CodableFeedStore {
    let storeUrl: URL
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    public init(storeUrl: URL) {
        self.storeUrl = storeUrl
    }
    
    private struct Cache: Codable {
        let items: [CodableFeedImage]
        let timestamp: Date
        var localFeedImages: [LocalFeedImage] {
            items.map(\.localFeedImage)
        }
    }
    
    private struct CodableFeedImage: Codable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let url: URL
        
        public init(id: UUID, description: String?, location: String?, imageURL: URL) {
            self.id = id
            self.description = description
            self.location = location
            self.url = imageURL
        }
        
        public init(from localFeedImage: LocalFeedImage) {
            self.id = localFeedImage.id
            self.description = localFeedImage.description
            self.location = localFeedImage.location
            self.url = localFeedImage.url
        }
        
        public var localFeedImage: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, imageURL: url)
        }
    }
    
    public func retrievalCachedFeed(completion: @escaping FeedStore.RetrievalCompletion) {
        do {
            if let encoded = try? Data(contentsOf: storeUrl) {
                let decoded = try decoder.decode(Cache.self, from: encoded)
                completion(.found(feed: decoded.localFeedImages, timestamp: decoded.timestamp))
            } else {
                completion(.empty)
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    public func insertCachedFeed(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let cache = Cache(items: items.map(CodableFeedImage.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeUrl)
        
        completion(nil)
    }
}
