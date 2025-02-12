//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Anthony on 4/2/25.
//
import Foundation

public final class CodableFeedStore: FeedStore {
    let storeUrl: URL
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue")
    
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
    
    public func retrievalCachedFeed(completion: @escaping RetrievalCompletion) {
        queue.async { [weak self] in
            guard let self else { return }
            
            completion(Result {
                if let encoded = try? Data(contentsOf: self.storeUrl) {
                    let decoded = try self.decoder.decode(Cache.self, from: encoded)
                    return (feed: decoded.localFeedImages, timestamp: decoded.timestamp)
                } else {
                    return .none
                }
            })
        }
    }
    
    public func insertCachedFeed(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            
            completion(
                Result {
                    let cache = Cache(items: items.map(CodableFeedImage.init), timestamp: timestamp)
                    let encoded = try self.encoder.encode(cache)
                    try encoded.write(to: self.storeUrl)
                }
            )
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        queue.async(flags: .barrier) { [storeUrl] in
            guard FileManager.default.fileExists(atPath: storeUrl.path) else {
                return completion(.success(()))
            }
            
            completion(Result{ try FileManager.default.removeItem(at: storeUrl) })
        }
    }
}
